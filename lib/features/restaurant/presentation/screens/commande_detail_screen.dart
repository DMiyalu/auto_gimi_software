import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
  final _searchController = TextEditingController();
  String _query = '';
  int _tabIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
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

        final isCanceled = item.statusKey == 'annulees';
        final filteredLines = _filteredLines(lines);

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCanceled) _TotalBar(totalAmount: item.totalAmount),
              const PrimaryBottomNavigation(location: Routes.dashboard),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _DetailHeader(
                  commande: item,
                  onBack: () => context.pop(),
                  onMore: () => _showActionsSheet(context, item),
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
                        lines: filteredLines,
                        totalLineCount: lines.length,
                        searchController: _searchController,
                        query: _query,
                        isCanceled: isCanceled,
                        isLoading: state.isLoading,
                        onQueryChanged: (value) =>
                            setState(() => _query = value),
                        onAddProduct: isCanceled
                            ? null
                            : () => _showAddProductSheet(context),
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
                      _DetailsPlaceholder(
                        commande: item,
                        isCanceled: isCanceled,
                        isLoading: state.isLoading,
                        onStatusChanged: (statusKey) => ref
                            .read(commandeControllerProvider.notifier)
                            .setStatus(
                              commandeId: widget.commandeId,
                              statusKey: statusKey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  List<LigneCommandeEntity> _filteredLines(List<LigneCommandeEntity> lines) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return lines;
    return lines
        .where((line) => line.label.toLowerCase().contains(query))
        .toList();
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

  void _showActionsSheet(BuildContext context, CommandeEntity commande) {
    final isCanceled = commande.statusKey == 'annulees';
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
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                if (!isCanceled)
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
  });

  final CommandeEntity commande;
  final VoidCallback onBack;
  final VoidCallback onMore;

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
            onTap: () {},
            iconSize: 30,
          ),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 3,
              width: selected ? double.infinity : 0,
              color: AppColors.violetPrincipal,
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
    required this.searchController,
    required this.query,
    required this.isCanceled,
    required this.isLoading,
    required this.onQueryChanged,
    required this.onAddProduct,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final List<LigneCommandeEntity> lines;
  final int totalLineCount;
  final TextEditingController searchController;
  final String query;
  final bool isCanceled;
  final bool isLoading;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback? onAddProduct;
  final ValueChanged<LigneCommandeEntity> onIncrement;
  final ValueChanged<LigneCommandeEntity> onDecrement;
  final ValueChanged<LigneCommandeEntity> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 230),
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 58,
                child: TextField(
                  controller: searchController,
                  onChanged: onQueryChanged,
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.violetPrincipal,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              height: 58,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF101529),
                  side: const BorderSide(color: Color(0xFFE6E8EF)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.grid_view_rounded, size: 25),
                label: const Text('Catégories'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
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
        _EmptyProductsHint(
          title: lines.isEmpty && query.isNotEmpty
              ? 'Aucun produit trouvé'
              : 'Ajoutez des produits à la commande',
          subtitle: lines.isEmpty && query.isNotEmpty
              ? 'Essayez une autre recherche'
              : 'Les articles apparaîtront ici',
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

class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.totalAmount});

  final double totalAmount;

  static final _amountFormat = NumberFormat('#,##0', 'fr');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Container(
        height: 112,
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
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
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: Color(0xFF707792),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_amountFormat.format(totalAmount)} FC',
                  style: const TextStyle(
                    color: Color(0xFF101529),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 58,
              child: FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.violetPrincipal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 30),
                label: const Text('Enregistrer la commande'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsPlaceholder extends StatelessWidget {
  const _DetailsPlaceholder({
    required this.commande,
    required this.isCanceled,
    required this.isLoading,
    required this.onStatusChanged,
  });

  final CommandeEntity commande;
  final bool isCanceled;
  final bool isLoading;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 230),
      children: [
        DropdownButtonFormField<String>(
          initialValue: commande.statusKey,
          decoration: const InputDecoration(labelText: 'Statut'),
          items: const [
            DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
            DropdownMenuItem(
              value: 'en_preparation',
              child: Text('En préparation'),
            ),
            DropdownMenuItem(value: 'pretes', child: Text('Prête')),
            DropdownMenuItem(value: 'livraison', child: Text('Livraison')),
            DropdownMenuItem(value: 'annulees', child: Text('Annulée')),
          ],
          onChanged: isLoading || isCanceled
              ? null
              : (value) {
                  if (value != null) onStatusChanged(value);
                },
        ),
        if (isCanceled) ...[
          const SizedBox(height: 18),
          const Text(
            'Commande annulée : les produits ont été remis en stock.',
            textAlign: TextAlign.center,
          ),
        ],
      ],
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
    final popular = filtered.take(4).toList();
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
                    _SectionHeader(
                      title: 'Produits populaires',
                      trailing: filtered.length > popular.length
                          ? 'Voir tout'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    if (popular.isEmpty)
                      _NoProductsMessage(hasQuery: _query.trim().isNotEmpty)
                    else
                      _PopularProductsGrid(
                        products: popular,
                        selectedQuantities: _selectedQuantities,
                        disabled: state.isLoading,
                        onAdd: _incrementProduct,
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
    if (produit.stock <= 0) return;
    setState(() {
      final current = _selectedQuantities[produit.id] ?? 0;
      if (current < produit.stock) {
        _selectedQuantities[produit.id] = current + 1;
      }
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
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

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
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.violetPrincipal,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class _PopularProductsGrid extends StatelessWidget {
  const _PopularProductsGrid({
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
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 96,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _PopularProductCard(
          product: product,
          quantity: selectedQuantities[product.id] ?? 0,
          disabled: disabled,
          onAdd: () => onAdd(product),
        );
      },
    );
  }
}

class _PopularProductCard extends StatelessWidget {
  const _PopularProductCard({
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
    final canAdd = !disabled && product.stock > 0 && quantity < product.stock;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProductThumb(label: product.name),
          const SizedBox(width: 10),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_amountFormat.format(product.price)} FC',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: product.stock > 0
                        ? AppColors.violetPrincipal
                        : const Color(0xFF9AA0B7),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _RoundAddButton(enabled: canAdd, onTap: onAdd, quantity: quantity),
        ],
      ),
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
    final canAdd = !disabled && product.stock > 0 && quantity < product.stock;

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
                    product.categoryName ?? 'Stock ${product.stock}',
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
                color: product.stock > 0
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
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: quantity > 0
              ? AppColors.violetPrincipal
              : enabled
              ? Colors.white
              : const Color(0xFFF4F5F9),
          shape: BoxShape.circle,
          border: Border.all(
            color: quantity > 0
                ? AppColors.violetPrincipal
                : const Color(0xFFDDE2EA),
          ),
        ),
        child: quantity > 0
            ? Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              )
            : Icon(
                Icons.add_rounded,
                color: enabled
                    ? AppColors.violetPrincipal
                    : const Color(0xFFB8BECF),
                size: 28,
              ),
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
