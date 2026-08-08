import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/app_currency.dart';
import '../../../../core/domain/country_dial_code.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../billing/presentation/providers/billing_providers.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../clients/presentation/providers/client_providers.dart';
import '../../../clients/presentation/widgets/client_avatar.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../billing/domain/entities/facture_entity.dart';
import '../../../printing/domain/entities/invoice_ticket_data.dart';
import '../../../printing/presentation/utils/invoice_print_flow.dart';
import '../../../produits/domain/entities/produit_entity.dart';
import '../../../produits/presentation/providers/produit_providers.dart';
import '../../../shell/presentation/widgets/primary_bottom_navigation.dart';
import '../../domain/entities/commande_entity.dart';
import '../../domain/entities/ligne_commande_entity.dart';
import '../providers/commande_providers.dart';

class CommandeDetailScreen extends ConsumerStatefulWidget {
  const CommandeDetailScreen({super.key, required this.commandeId});

  final String commandeId;

  @override
  ConsumerState<CommandeDetailScreen> createState() =>
      _CommandeDetailScreenState();
}

class _CommandeDetailScreenState extends ConsumerState<CommandeDetailScreen> {
  int _tabIndex = 0;
  late final ConfettiController _confettiController;
  late final AudioPlayer _paymentSoundPlayer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2200),
    );
    _paymentSoundPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _paymentSoundPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commande = ref.watch(commandeProvider(widget.commandeId));
    final lines =
        ref.watch(commandeLinesProvider(widget.commandeId)).valueOrNull ??
        const <LigneCommandeEntity>[];
    final state = ref.watch(commandeControllerProvider);

    ref.listen(commandeControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    return commande.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Commande')),
            body: const Center(child: Text('Commande introuvable')),
          );
        }

        final isCanceled = item.isCanceled;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Scaffold(
              extendBody: true,
              backgroundColor: Colors.white,
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCanceled)
                    _ActionsBar(
                      commande: item,
                      onPrint: () => _printInvoice(item),
                      onCollectPayment: () => _collectPayment(item),
                    ),
                  const PrimaryBottomNavigation(location: Routes.dashboard),
                ],
              ),
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _DetailHeader(
                      commande: item,
                      onBack: () => context.canPop()
                          ? context.pop()
                          : context.go(Routes.dashboard),
                      onMore: () => _showActionsSheet(context, item),
                      onPrint: () => _printInvoice(item),
                      onCollectPayment: () => _collectPayment(item),
                    ),
                    _SegmentedTabs(
                      selectedIndex: _tabIndex,
                      onChanged: (index) => setState(() => _tabIndex = index),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _tabIndex,
                        children: [
                          _ProductsTab(
                            lines: lines,
                            totalLineCount: lines.length,
                            isCanceled: isCanceled,
                            isLoading: state.isLoading,
                            onAddProduct: () =>
                                _onAddProductPressed(context, item),
                            onIncrement: (line) => ref
                                .read(commandeControllerProvider.notifier)
                                .addProduitLine(
                                  commandeId: widget.commandeId,
                                  produitId: line.produitId,
                                ),
                            onDecrement: (line) => ref
                                .read(commandeControllerProvider.notifier)
                                .decrementLine(lineId: line.id),
                            onRemove: (line) => ref
                                .read(commandeControllerProvider.notifier)
                                .removeLine(lineId: line.id),
                          ),
                          _DetailsTab(
                            commande: item,
                            lines: lines,
                            isCanceled: isCanceled,
                            onViewProducts: () => setState(() => _tabIndex = 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 24,
                maxBlastForce: 22,
                minBlastForce: 8,
                gravity: 0.4,
                colors: const [
                  AppColors.violetPrincipal,
                  AppColors.bleuRoyal,
                  AppColors.cyan,
                  AppColors.violetClair,
                ],
              ),
            ),
          ],
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Commande')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Commande')),
        body: Center(child: Text(error.toString())),
      ),
    );
  }

  void _onAddProductPressed(BuildContext context, CommandeEntity commande) {
    if (commande.isEditable) {
      _showAddProductSheet(context);
      return;
    }

    final message = switch (commande.statusKey) {
      CommandeStatus.cloturee =>
        'Cette commande est déjà clôturée et payée.',
      CommandeStatus.annulees => 'Cette commande est déjà annulée.',
      CommandeStatus.aPayer =>
        'Cette commande est à payer et ne peut plus être modifiée.',
      _ => 'Cette commande ne peut plus être modifiée.',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddProductSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (_) => _AddProductSheet(commandeId: widget.commandeId),
    );
  }

  Future<void> _printInvoice(CommandeEntity commande) async {
    final confirmed = await confirmPrintInvoice(context, ref);
    if (!confirmed || !mounted) return;

    final establishment = await ref.read(currentEstablishmentProvider.future);
    final lines = await ref.read(commandeLinesProvider(commande.id).future);
    final client = commande.clientId != null
        ? await ref.read(clientByIdProvider(commande.clientId!).future)
        : null;
    final facture = await ref.read(
      factureForActivityProvider(
        BillingActivityRef(type: BillingActivityType.commande, id: commande.id),
      ).future,
    );

    if (!mounted) return;

    final data = InvoiceTicketData(
      establishmentName: establishment?.name ?? 'Facture',
      establishmentPhone: establishment?.phone,
      logoBase64: establishment?.logoBase64,
      headerLines: establishment?.invoiceHeaderLines ?? const [],
      footerLines: establishment?.invoiceFooterLines ?? const [],
      reference: facture?.reference ?? commande.reference,
      date: facture?.issuedAt ?? DateTime.now(),
      clientName: client?.name,
      clientPhone: client?.displayPhone,
      lines: [
        for (final line in lines)
          InvoiceTicketLine(
            label: line.label,
            quantity: line.quantity,
            unitPrice: line.unitPrice,
            lineAmount: line.lineAmount,
          ),
      ],
      totalAmount: facture?.totalAmount ?? commande.totalAmount,
      paidAmount: facture?.paidAmount,
      balanceDue: facture?.balanceDue,
      currency: facture?.currency ?? AppCurrency.cdf,
      statusLabel: facture?.status.label ?? commande.statusLabel,
    );

    final success = await printInvoiceTicket(context, ref, data);
    if (success && commande.isEditable) {
      await ref
          .read(commandeControllerProvider.notifier)
          .markAwaitingPayment(commandeId: commande.id);
    }
  }

  Future<void> _collectPayment(CommandeEntity commande) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _PaymentConfirmationDialog(totalAmount: commande.totalAmount),
    );
    if (confirmed != true || !mounted) return;

    await ref
        .read(commandeControllerProvider.notifier)
        .registerPayment(commandeId: commande.id);
    if (!mounted) return;
    if (ref.read(commandeControllerProvider).hasError) return;

    await _celebratePayment();
  }

  Future<void> _celebratePayment() async {
    HapticFeedback.mediumImpact();
    _confettiController.play();
    // Best-effort : un souci de plugin audio (plateforme, permissions,
    // sortie audio indisponible) ne doit jamais faire échouer le paiement.
    unawaited(
      _paymentSoundPlayer
          .play(AssetSource('audio/cash_success.wav'))
          .catchError((_) {}),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement encaissé — commande clôturée.')),
    );
  }

  void _showActionsSheet(BuildContext context, CommandeEntity commande) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: const Text('Imprimer'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _printInvoice(commande);
                  },
                ),
                if (commande.canCollectPayment)
                  ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Encaisser le paiement'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _collectPayment(commande);
                    },
                  ),
                if (commande.canBeCanceled)
                  ListTile(
                    leading: const Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFFEF2E2E),
                    ),
                    title: const Text('Annuler la commande'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      ref
                          .read(commandeControllerProvider.notifier)
                          .cancelCommande(commandeId: widget.commandeId);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.commande,
    required this.onBack,
    required this.onMore,
    required this.onPrint,
    required this.onCollectPayment,
  });

  final CommandeEntity commande;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback onPrint;
  final VoidCallback onCollectPayment;

  @override
  Widget build(BuildContext context) {
    final title = commande.context ?? commande.reference;
    final accent = _accentForTitle(title);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
      child: Row(
        children: [
          _CircleActionButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
            iconSize: 32,
          ),
          const SizedBox(width: 18),
          CircleAvatar(
            radius: 34,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(_iconForTitle(title), color: accent, size: 36),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF101529),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                if (title != commande.reference) ...[
                  const SizedBox(height: 4),
                  Text(
                    commande.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF707792),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CircleActionButton(
            icon: Icons.print_outlined,
            onTap: onPrint,
            iconSize: 30,
          ),
          if (commande.canCollectPayment) ...[
            const SizedBox(width: 14),
            _CircleActionButton(
              icon: Icons.payments_outlined,
              onTap: onCollectPayment,
              iconSize: 30,
            ),
          ],
          const SizedBox(width: 14),
          _CircleActionButton(
            icon: Icons.more_horiz_rounded,
            onTap: onMore,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  static IconData _iconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('livraison')) return Icons.delivery_dining_outlined;
    if (lower.contains('emporter')) return Icons.shopping_bag_outlined;
    return Icons.table_restaurant_outlined;
  }

  static Color _accentForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('livraison')) return AppColors.cyan;
    if (lower.contains('emporter')) return AppColors.bleuRoyal;
    return AppColors.violetPrincipal;
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8EF)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Produits',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            _TabButton(
              label: 'Détails',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.violetPrincipal
                      : const Color(0xFF707792),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: selected ? 1 : 0,
              child: Container(
                height: 3,
                width: double.infinity,
                color: AppColors.violetPrincipal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({
    required this.lines,
    required this.totalLineCount,
    required this.isCanceled,
    required this.isLoading,
    required this.onAddProduct,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final List<LigneCommandeEntity> lines;
  final int totalLineCount;
  final bool isCanceled;
  final bool isLoading;
  final VoidCallback onAddProduct;
  final ValueChanged<LigneCommandeEntity> onIncrement;
  final ValueChanged<LigneCommandeEntity> onDecrement;
  final ValueChanged<LigneCommandeEntity> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 230),
      children: [
        const Text(
          'Lignes',
          style: TextStyle(fontSize: 1, color: Colors.transparent),
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                'Liste des produits',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF101529),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6E8EF)),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                '$totalLineCount',
                style: const TextStyle(
                  color: Color(0xFF707792),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onAddProduct,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violetPrincipal,
                    side: const BorderSide(color: Color(0xFFE6E8EF)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 28),
                  label: const Text(
                    'Ajouter un produit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (isCanceled) ...[
          const Text(
            'Commande annulée : les produits ont été remis en stock.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
        ],
        _LineListCard(
          lines: lines,
          isCanceled: isCanceled,
          isLoading: isLoading,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          onRemove: onRemove,
        ),
        const SizedBox(height: 86),
        const _EmptyProductsHint(
          title: 'Ajoutez des produits à la commande',
          subtitle: 'Les articles apparaîtront ici',
        ),
      ],
    );
  }
}

class _LineListCard extends StatelessWidget {
  const _LineListCard({
    required this.lines,
    required this.isCanceled,
    required this.isLoading,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final List<LigneCommandeEntity> lines;
  final bool isCanceled;
  final bool isLoading;
  final ValueChanged<LigneCommandeEntity> onIncrement;
  final ValueChanged<LigneCommandeEntity> onDecrement;
  final ValueChanged<LigneCommandeEntity> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EF)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          if (lines.isEmpty)
            const SizedBox(height: 164)
          else
            for (var index = 0; index < lines.length; index++) ...[
              _ProductLineTile(
                line: lines[index],
                isCanceled: isCanceled,
                isLoading: isLoading,
                onIncrement: () => onIncrement(lines[index]),
                onDecrement: () => onDecrement(lines[index]),
                onRemove: () => onRemove(lines[index]),
              ),
              if (index < lines.length - 1)
                const Divider(height: 1, color: Color(0xFFE6E8EF)),
            ],
        ],
      ),
    );
  }
}

class _ProductLineTile extends StatelessWidget {
  const _ProductLineTile({
    required this.line,
    required this.isCanceled,
    required this.isLoading,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final LigneCommandeEntity line;
  final bool isCanceled;
  final bool isLoading;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  static final _amountFormat = NumberFormat('#,##0', 'fr');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 20, 14),
        child: Row(
          children: [
            _ProductThumb(label: line.label),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF101529),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 13),
                  if (line.quantity > 1)
                    Text(
                      '${line.quantity} x ${_amountFormat.format(line.unitPrice)} FC',
                      style: const TextStyle(
                        color: Color(0xFF707792),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      '${_amountFormat.format(line.unitPrice)} FC',
                      style: const TextStyle(
                        color: Color(0xFF707792),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            _QuantityStepper(
              quantity: line.quantity,
              disabled: isCanceled || isLoading,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
            const SizedBox(width: 28),
            SizedBox(
              width: 116,
              child: Text(
                '${_amountFormat.format(line.lineAmount)} FC',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF101529),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            if (!isCanceled)
              IconButton(
                tooltip: 'Retirer',
                onPressed: isLoading ? null : onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFF1616),
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final isDrink = lower.contains('coca') || lower.contains('jus');
    final color = _colorFor(lower);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: Center(
        child: isDrink
            ? Text(
                lower.contains('coca') ? 'Coca' : 'Jus',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              )
            : Icon(Icons.restaurant_menu_rounded, color: color, size: 36),
      ),
    );
  }

  static Color _colorFor(String label) {
    if (label.contains('poulet')) return AppColors.violetPrincipal;
    if (label.contains('riz')) return AppColors.violetClair;
    if (label.contains('alloco')) return AppColors.bleuRoyal;
    if (label.contains('coca')) return AppColors.cyan;
    return AppColors.bleuSaas;
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.disabled,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool disabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E8EF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: disabled ? null : onDecrement,
          ),
          Container(width: 1, color: const Color(0xFFE6E8EF)),
          Expanded(
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Color(0xFF101529),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE6E8EF)),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: disabled ? null : onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 45,
        height: double.infinity,
        child: Icon(icon, color: AppColors.violetPrincipal, size: 24),
      ),
    );
  }
}

class _EmptyProductsHint extends StatelessWidget {
  const _EmptyProductsHint({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 72,
          color: AppColors.violetPrincipal.withValues(alpha: 0.22),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF101529),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF707792),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Barre d'actions du bas, commune aux deux onglets ("Produits" et
/// "Détails") : total de la commande, impression de la facture et
/// encaissement du paiement.
class _ActionsBar extends StatelessWidget {
  const _ActionsBar({
    required this.commande,
    required this.onPrint,
    required this.onCollectPayment,
  });

  final CommandeEntity commande;
  final VoidCallback onPrint;
  final VoidCallback onCollectPayment;

  static final _amountFormat = NumberFormat('#,##0', 'fr');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8EF)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: Color(0xFF707792),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_amountFormat.format(commande.totalAmount)} FC',
                  style: const TextStyle(
                    color: Color(0xFF101529),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (commande.isClosed) ...[const Spacer(), const _PaidBadge()],
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.violetPrincipal,
                        side: const BorderSide(
                          color: AppColors.violetPrincipal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.print_outlined, size: 22),
                      label: const Text('Imprimer facture'),
                    ),
                  ),
                ),
                if (commande.canCollectPayment) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: onCollectPayment,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.vertPrincipal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        icon: const Icon(Icons.payments_outlined, size: 22),
                        label: const Text('Encaisser paiement'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaidBadge extends StatelessWidget {
  const _PaidBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.vertPrincipal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.vertPrincipal,
            size: 15,
          ),
          SizedBox(width: 5),
          Text(
            'Payée',
            style: TextStyle(
              color: AppColors.vertPrincipal,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentConfirmationDialog extends StatelessWidget {
  const _PaymentConfirmationDialog({required this.totalAmount});

  final double totalAmount;

  static final _amountFormat = NumberFormat('#,##0', 'fr');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Encaisser le paiement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Le total à encaisser est :',
            style: TextStyle(color: Color(0xFF707792), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${_amountFormat.format(totalAmount)} FC',
            style: const TextStyle(
              color: Color(0xFF101529),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.vertPrincipal,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Argent encaissé'),
        ),
      ],
    );
  }
}

class _DetailsTab extends ConsumerStatefulWidget {
  const _DetailsTab({
    required this.commande,
    required this.lines,
    required this.isCanceled,
    required this.onViewProducts,
  });

  final CommandeEntity commande;
  final List<LigneCommandeEntity> lines;
  final bool isCanceled;
  final VoidCallback onViewProducts;

  @override
  ConsumerState<_DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends ConsumerState<_DetailsTab> {
  static final _defaultCountry = SupportedCountries.all.firstWhere(
    (country) => country.isoCode == 'CD',
  );

  late CountryDialCode _country = _defaultCountry;
  final _localController = TextEditingController();

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  Future<void> _selectClient(ClientEntity client) async {
    await ref
        .read(commandeControllerProvider.notifier)
        .attachClient(commandeId: widget.commande.id, clientId: client.id);
    if (!mounted) return;
    if (!ref.read(commandeControllerProvider).hasError) {
      setState(_localController.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientId = widget.commande.clientId;
    final clientAsync = clientId == null
        ? null
        : ref.watch(clientByIdProvider(clientId));
    final enabled = !widget.isCanceled;
    final digits = PhoneAuthMapper.normalize(_localController.text);
    final suggestions = digits.isEmpty
        ? const <ClientEntity>[]
        : (ref.watch(clientsProvider).valueOrNull ?? const <ClientEntity>[])
              .where((client) => client.whatsappPhone.contains(digits))
              .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 230),
      children: [
        Text(
          'Client (optionnel)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF101529),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        _PhoneEntryField(
          country: _country,
          controller: _localController,
          enabled: enabled,
          onCountryChanged: (country) => setState(() => _country = country),
          onChanged: (_) => setState(() {}),
        ),
        if (enabled && digits.isNotEmpty) ...[
          const SizedBox(height: 10),
          _ClientSuggestionsPanel(
            clients: suggestions,
            onSelect: _selectClient,
          ),
        ],
        if (clientAsync != null) ...[
          const SizedBox(height: 18),
          clientAsync.when(
            data: (client) => client == null
                ? const SizedBox.shrink()
                : _SelectedClientCard(
                    client: client,
                    onRemove: enabled
                        ? () => ref
                              .read(commandeControllerProvider.notifier)
                              .detachClient(widget.commande.id)
                        : null,
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          children: [
            Text(
              'Résumé des articles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF101529),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6E8EF)),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                '${widget.lines.length} articles',
                style: const TextStyle(
                  color: Color(0xFF707792),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: widget.onViewProducts,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF101529),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ArticlesSummaryCard(
          lines: widget.lines,
          totalAmount: widget.commande.totalAmount,
        ),
        if (widget.isCanceled) ...[
          const SizedBox(height: 18),
          const Text(
            'Commande annulée : les produits ont été remis en stock.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF707792),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _PhoneEntryField extends StatelessWidget {
  const _PhoneEntryField({
    required this.country,
    required this.controller,
    required this.enabled,
    required this.onCountryChanged,
    required this.onChanged,
  });

  final CountryDialCode country;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<CountryDialCode> onCountryChanged;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<CountryDialCode>(
              value: country,
              isDense: true,
              onChanged: enabled
                  ? (value) {
                      if (value != null) onCountryChanged(value);
                    }
                  : null,
              selectedItemBuilder: (_) {
                return SupportedCountries.all
                    .map(
                      (c) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.flagEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c.displayCode,
                            style: const TextStyle(
                              color: Color(0xFF101529),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList();
              },
              items: SupportedCountries.all
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        '${c.flagEmoji} ${c.displayCode} ${c.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: const Color(0xFFE6E8EF)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '81 234 5678',
                hintStyle: TextStyle(
                  color: Color(0xFF9AA0B7),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF101529),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Résultats affichés en direct sous le champ téléphone, au fil de la
/// saisie — même traitement visuel que `_TablePickerSheet` (carte
/// arrondie, fond gris clair) pour une expérience cohérente entre la
/// sélection de table et celle du client.
class _ClientSuggestionsPanel extends StatelessWidget {
  const _ClientSuggestionsPanel({
    required this.clients,
    required this.onSelect,
  });

  final List<ClientEntity> clients;
  final ValueChanged<ClientEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: clients.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Text(
                'Aucun client trouvé avec ce numéro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF707792),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: clients.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return _ClientSuggestionTile(
                    client: client,
                    index: index,
                    onTap: () => onSelect(client),
                  );
                },
              ),
            ),
    );
  }
}

class _ClientSuggestionTile extends StatelessWidget {
  const _ClientSuggestionTile({
    required this.client,
    required this.index,
    required this.onTap,
  });

  final ClientEntity client;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 160 + (index.clamp(0, 5) * 30)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  ClientAvatar(client: client),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF101529),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          client.displayPhone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF707792),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.violetPrincipal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedClientCard extends StatelessWidget {
  const _SelectedClientCard({required this.client, required this.onRemove});

  final ClientEntity client;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFEDEEF3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF101529),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF101529),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.displayPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF707792),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: 'Retirer le client',
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFF707792),
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}

class _ArticlesSummaryCard extends StatelessWidget {
  const _ArticlesSummaryCard({required this.lines, required this.totalAmount});

  final List<LigneCommandeEntity> lines;
  final double totalAmount;

  static final _amountFormat = NumberFormat('#,##0', 'fr');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EF)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          if (lines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucun article dans cette commande.',
                style: TextStyle(
                  color: Color(0xFF707792),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF101529),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${line.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF707792),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: Text(
                        '${_amountFormat.format(line.lineAmount)} FC',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF101529),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE6E8EF)),
          ),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Color(0xFF101529),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${_amountFormat.format(totalAmount)} FC',
                style: const TextStyle(
                  color: Color(0xFF101529),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddProductSheet extends ConsumerStatefulWidget {
  const _AddProductSheet({required this.commandeId});

  final String commandeId;

  @override
  ConsumerState<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<_AddProductSheet> {
  final _searchController = TextEditingController();
  final Map<String, int> _selectedQuantities = {};
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedQuantities.isEmpty) return;
    final controller = ref.read(commandeControllerProvider.notifier);

    for (final entry in _selectedQuantities.entries) {
      await controller.addProduitLine(
        commandeId: widget.commandeId,
        produitId: entry.key,
        quantity: entry.value,
      );
      if (ref.read(commandeControllerProvider).hasError) break;
    }

    if (!mounted) return;
    final state = ref.read(commandeControllerProvider);
    if (!state.hasError) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final produits = ref.watch(produitsProvider).valueOrNull ?? [];
    final state = ref.watch(commandeControllerProvider);
    final categories = _categoriesFor(produits);
    final activeCategory = _activeCategory(categories);
    final filtered = _filteredProducts(produits, activeCategory);
    final selectedCount = _selectedQuantities.values.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    18 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7DAE5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _CircleActionButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.of(context).pop(),
                          iconSize: 30,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Ajouter un produit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF101529),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Sélectionnez un produit à ajouter',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF707792),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 58,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un produit...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF7B819B),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF707792),
                            size: 30,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6E8EF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: AppColors.violetPrincipal,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final selected = category == activeCategory;
                          return _CategoryFilterChip(
                            label: category,
                            selected: selected,
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionHeader(title: 'Tous les produits'),
                    const SizedBox(height: 12),
                    _AllProductsCard(
                      products: filtered,
                      selectedQuantities: _selectedQuantities,
                      disabled: state.isLoading,
                      onAdd: _incrementProduct,
                    ),
                  ],
                ),
              ),
              _AddProductFooter(
                selectedCount: selectedCount,
                isLoading: state.isLoading,
                onSubmit: selectedCount == 0 ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _incrementProduct(ProduitEntity produit) {
    setState(() {
      final current = _selectedQuantities[produit.id] ?? 0;
      if (produit.stockTrackingEnabled && current >= produit.stock) return;
      _selectedQuantities[produit.id] = current + 1;
    });
  }

  List<String> _categoriesFor(List<ProduitEntity> produits) {
    final values =
        produits
            .map((produit) => produit.categoryName?.trim())
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Tous', ...values];
  }

  String _activeCategory(List<String> categories) {
    final selected = _selectedCategory;
    if (selected != null && categories.contains(selected)) return selected;
    return categories.first;
  }

  List<ProduitEntity> _filteredProducts(
    List<ProduitEntity> produits,
    String activeCategory,
  ) {
    final query = _query.trim().toLowerCase();
    final filtered = produits.where((produit) {
      final matchesCategory =
          activeCategory == 'Tous' || produit.categoryName == activeCategory;
      final matchesQuery =
          query.isEmpty ||
          produit.name.toLowerCase().contains(query) ||
          (produit.categoryName?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesQuery;
    }).toList();
    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return filtered;
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.violetPrincipal : const Color(0xFFF4F5F9),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          children: [
            Icon(
              label == 'Tous'
                  ? Icons.grid_view_rounded
                  : Icons.category_outlined,
              size: 21,
              color: selected ? Colors.white : const Color(0xFF101529),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF101529),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF101529),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _AllProductsCard extends StatelessWidget {
  const _AllProductsCard({
    required this.products,
    required this.selectedQuantities,
    required this.disabled,
    required this.onAdd,
  });

  final List<ProduitEntity> products;
  final Map<String, int> selectedQuantities;
  final bool disabled;
  final ValueChanged<ProduitEntity> onAdd;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _NoProductsMessage(hasQuery: false);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EF)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var index = 0; index < products.length; index++) ...[
            _CatalogProductTile(
              product: products[index],
              quantity: selectedQuantities[products[index].id] ?? 0,
              disabled: disabled,
              onAdd: () => onAdd(products[index]),
            ),
            if (index < products.length - 1)
              const Divider(height: 1, color: Color(0xFFE6E8EF)),
          ],
        ],
      ),
    );
  }
}

class _CatalogProductTile extends StatelessWidget {
  const _CatalogProductTile({
    required this.product,
    required this.quantity,
    required this.disabled,
    required this.onAdd,
  });

  final ProduitEntity product;
  final int quantity;
  final bool disabled;
  final VoidCallback onAdd;

  static final _amountFormat = NumberFormat('#,##0', 'fr');

  @override
  Widget build(BuildContext context) {
    final canAdd =
        !disabled &&
        (!product.stockTrackingEnabled || quantity < product.stock);
    final stockLabel = product.stockTrackingEnabled
        ? 'Stock ${product.stock}'
        : 'Stock non suivi';

    return SizedBox(
      height: 92,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _ProductThumb(label: product.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF101529),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.categoryName ?? stockLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF707792),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${_amountFormat.format(product.price)} FC',
              style: TextStyle(
                color: !product.stockTrackingEnabled || product.stock > 0
                    ? AppColors.violetPrincipal
                    : const Color(0xFF9AA0B7),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            _RoundAddButton(enabled: canAdd, onTap: onAdd, quantity: quantity),
          ],
        ),
      ),
    );
  }
}

class _RoundAddButton extends StatelessWidget {
  const _RoundAddButton({
    required this.enabled,
    required this.onTap,
    required this.quantity,
  });

  final bool enabled;
  final VoidCallback onTap;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: IconButton(
        tooltip: 'Ajouter',
        onPressed: enabled ? onTap : null,
        style: IconButton.styleFrom(
          backgroundColor: quantity > 0
              ? AppColors.violetPrincipal
              : Colors.white,
          disabledBackgroundColor: const Color(0xFFF4F5F9),
          foregroundColor: quantity > 0
              ? Colors.white
              : AppColors.violetPrincipal,
          disabledForegroundColor: const Color(0xFFB8BECF),
          side: BorderSide(
            color: quantity > 0
                ? AppColors.violetPrincipal
                : const Color(0xFFDDE2EA),
          ),
          shape: const CircleBorder(),
        ),
        icon: quantity > 0
            ? Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              )
            : const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _NoProductsMessage extends StatelessWidget {
  const _NoProductsMessage({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          hasQuery
              ? 'Aucun produit ne correspond à cette recherche.'
              : 'Aucun produit disponible dans cette catégorie.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF707792),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AddProductFooter extends StatelessWidget {
  const _AddProductFooter({
    required this.selectedCount,
    required this.isLoading,
    required this.onSubmit,
  });

  final int selectedCount;
  final bool isLoading;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$selectedCount produit${selectedCount > 1 ? 's' : ''} sélectionné${selectedCount > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Color(0xFF101529),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violetPrincipal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.violetPrincipal.withValues(
                  alpha: 0.18,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Ajouter à la commande',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    required this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(icon, size: iconSize, color: const Color(0xFF101529)),
        ),
      ),
    );
  }
}
