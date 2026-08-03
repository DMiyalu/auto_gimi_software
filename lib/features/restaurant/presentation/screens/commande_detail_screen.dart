import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../billing/domain/entities/facture_entity.dart';
import '../../../billing/domain/entities/paiement_entity.dart';
import '../../../billing/presentation/providers/billing_providers.dart';
import '../../../produits/domain/entities/produit_entity.dart';
import '../../../produits/presentation/providers/produit_providers.dart';
import '../providers/commande_providers.dart';

class CommandeDetailScreen extends ConsumerWidget {
  const CommandeDetailScreen({super.key, required this.commandeId});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(commandeProvider(commandeId));
    final lines =
        ref.watch(commandeLinesProvider(commandeId)).valueOrNull ?? [];
    final state = ref.watch(commandeControllerProvider);
    final billingState = ref.watch(billingControllerProvider);
    final facture = ref
        .watch(
          factureForActivityProvider(
            BillingActivityRef(
              type: BillingActivityType.commande,
              id: commandeId,
            ),
          ),
        )
        .valueOrNull;

    ref.listen(commandeControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });
    ref.listen(billingControllerProvider, (_, next) {
      if (next.hasError) {
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

        return Scaffold(
          appBar: AppBar(title: Text(item.reference)),
          floatingActionButton: isCanceled
              ? null
              : FloatingActionButton.extended(
                  onPressed: state.isLoading
                      ? null
                      : () => _showAddProductSheet(context, ref),
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  label: const Text('Produit'),
                ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _CommandeHeader(
                reference: item.reference,
                contextLabel: item.context ?? 'Commande restaurant',
                statusLabel: item.statusLabel,
                totalAmount: item.totalAmount,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: item.statusKey,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(
                    value: 'en_preparation',
                    child: Text('En préparation'),
                  ),
                  DropdownMenuItem(value: 'pretes', child: Text('Prête')),
                  DropdownMenuItem(
                    value: 'livraison',
                    child: Text('Livraison'),
                  ),
                  DropdownMenuItem(value: 'annulees', child: Text('Annulée')),
                ],
                onChanged: state.isLoading || isCanceled
                    ? null
                    : (value) {
                        if (value == null) return;
                        ref
                            .read(commandeControllerProvider.notifier)
                            .setStatus(
                              commandeId: commandeId,
                              statusKey: value,
                            );
                      },
              ),
              if (!isCanceled) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => ref
                            .read(commandeControllerProvider.notifier)
                            .cancelCommande(commandeId: commandeId),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Annuler la commande'),
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  'Commande annulée : les produits ont été remis en stock.',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _FactureSection(
                facture: facture,
                totalAmount: item.totalAmount,
                isCanceled: isCanceled,
                isLoading: billingState.isLoading,
                onIssue: () => ref
                    .read(billingControllerProvider.notifier)
                    .issueFactureForActivity(
                      activityType: BillingActivityType.commande,
                      activityId: commandeId,
                      totalAmount: item.totalAmount,
                    ),
                onPay: facture == null
                    ? null
                    : () => _showPaymentSheet(context, facture),
              ),
              const SizedBox(height: 24),
              Text('Lignes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (lines.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('Aucun produit dans la commande')),
                )
              else
                for (final line in lines)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(line.label),
                    subtitle: Text(
                      '${line.quantity} x ${line.unitPrice.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(line.lineAmount.toStringAsFixed(2)),
                        if (!isCanceled)
                          IconButton(
                            tooltip: 'Retirer',
                            onPressed: state.isLoading
                                ? null
                                : () => ref
                                      .read(commandeControllerProvider.notifier)
                                      .removeLine(lineId: line.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                      ],
                    ),
                  ),
            ],
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

  void _showAddProductSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) {
        return _AddProductSheet(commandeId: commandeId);
      },
    );
  }

  void _showPaymentSheet(BuildContext context, FactureEntity facture) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) {
        return _PaymentSheet(facture: facture);
      },
    );
  }
}

class _FactureSection extends StatelessWidget {
  const _FactureSection({
    required this.facture,
    required this.totalAmount,
    required this.isCanceled,
    required this.isLoading,
    required this.onIssue,
    required this.onPay,
  });

  final FactureEntity? facture;
  final double totalAmount;
  final bool isCanceled;
  final bool isLoading;
  final Future<void> Function() onIssue;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final current = facture;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Facture', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (current == null) ...[
              Text('Montant à facturer : ${totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: isLoading || isCanceled || totalAmount <= 0
                    ? null
                    : onIssue,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Émettre la facture'),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(current.reference),
                subtitle: Text(current.status.label),
                trailing: Text(current.totalAmount.toStringAsFixed(2)),
              ),
              Text('Payé : ${current.paidAmount.toStringAsFixed(2)}'),
              Text('Solde : ${current.balanceDue.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: isLoading || current.status == FactureStatus.paid
                    ? null
                    : onPay,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Encaisser'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.facture});

  final FactureEntity facture;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  late final TextEditingController _amountController;
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.facture.balanceDue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null) return;

    await ref
        .read(billingControllerProvider.notifier)
        .recordPayment(
          factureId: widget.facture.id,
          method: _method,
          amount: amount,
          currency: widget.facture.currency,
        );

    if (!mounted) return;
    final state = ref.read(billingControllerProvider);
    if (!state.hasError) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billingControllerProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Encaisser', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Méthode'),
              items: [
                for (final method in PaymentMethod.values)
                  DropdownMenuItem(value: method, child: Text(method.label)),
              ],
              onChanged: state.isLoading
                  ? null
                  : (value) {
                      if (value != null) setState(() => _method = value);
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              enabled: !state.isLoading,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: state.isLoading ? null : _submit,
              icon: state.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.payments_outlined),
              label: const Text('Valider le paiement'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandeHeader extends StatelessWidget {
  const _CommandeHeader({
    required this.reference,
    required this.contextLabel,
    required this.statusLabel,
    required this.totalAmount,
  });

  final String reference;
  final String contextLabel;
  final String statusLabel;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reference, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(contextLabel),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(label: Text(statusLabel)),
                const Spacer(),
                Text(
                  totalAmount.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
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
  final _quantityController = TextEditingController(text: '1');
  String? _selectedProduitId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final produitId = _selectedProduitId;
    if (produitId == null) return;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

    await ref
        .read(commandeControllerProvider.notifier)
        .addProduitLine(
          commandeId: widget.commandeId,
          produitId: produitId,
          quantity: quantity,
        );

    if (!mounted) return;
    final state = ref.read(commandeControllerProvider);
    if (!state.hasError) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final produits = ref.watch(produitsProvider).valueOrNull ?? [];
    final state = ref.watch(commandeControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ajouter un produit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedProduitId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Produit'),
              items: [
                for (final produit in produits)
                  DropdownMenuItem(
                    value: produit.id,
                    child: Text(_productLabel(produit)),
                  ),
              ],
              onChanged: state.isLoading
                  ? null
                  : (value) => setState(() => _selectedProduitId = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              enabled: !state.isLoading,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: state.isLoading || produits.isEmpty ? null : _submit,
              icon: state.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  String _productLabel(ProduitEntity produit) {
    return '${produit.name} • ${produit.price.toStringAsFixed(2)} ${produit.currency.code} • Stock ${produit.stock}';
  }
}
