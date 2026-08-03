import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/app_currency.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/facture_entity.dart';
import '../../domain/entities/paiement_entity.dart';
import '../providers/billing_providers.dart';

class ActivityBillingPanel extends ConsumerWidget {
  const ActivityBillingPanel({
    super.key,
    required this.activity,
    required this.totalAmount,
    this.currency = AppCurrency.usd,
    this.disabled = false,
  });

  final BillingActivityRef activity;
  final double totalAmount;
  final AppCurrency currency;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facture = ref.watch(factureForActivityProvider(activity)).valueOrNull;
    final state = ref.watch(billingControllerProvider);

    ref.listen(billingControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    final current = facture;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Facture', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            if (current == null) ...[
              Text('Montant à facturer : ${totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: AppSpacing.xs),
              FilledButton.icon(
                onPressed: state.isLoading || disabled || totalAmount <= 0
                    ? null
                    : () => ref
                          .read(billingControllerProvider.notifier)
                          .issueFactureForActivity(
                            activityType: activity.type,
                            activityId: activity.id,
                            totalAmount: totalAmount,
                            currency: currency,
                          ),
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
              const SizedBox(height: AppSpacing.xs),
              FilledButton.icon(
                onPressed:
                    state.isLoading || current.status == FactureStatus.paid
                    ? null
                    : () => _showPaymentSheet(context, current),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Encaisser'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, FactureEntity facture) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) => _PaymentSheet(facture: facture),
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
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Encaisser', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              enabled: !state.isLoading,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant'),
            ),
            const SizedBox(height: AppSpacing.md),
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
