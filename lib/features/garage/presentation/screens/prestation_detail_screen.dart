import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/app_currency.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../billing/domain/entities/facture_entity.dart';
import '../../../billing/presentation/providers/billing_providers.dart';
import '../../../billing/presentation/widgets/activity_billing_panel.dart';
import '../../../clients/presentation/providers/client_providers.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../printing/domain/entities/invoice_ticket_data.dart';
import '../../../printing/presentation/utils/invoice_print_flow.dart';
import '../../domain/entities/prestation_entity.dart';
import '../providers/prestation_providers.dart';
import '../widgets/prestation_client_tab.dart';
import '../widgets/prestation_works_tab.dart';

/// Détail d'une prestation : en-tête véhicule, onglets Travaux / Client.
class PrestationDetailScreen extends ConsumerWidget {
  const PrestationDetailScreen({super.key, required this.prestationId});

  final String prestationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestationAsync = ref.watch(prestationProvider(prestationId));

    return prestationAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      data: (prestation) {
        if (prestation == null) {
          return const Scaffold(
            body: Center(child: Text('Prestation introuvable.')),
          );
        }
        return _PrestationDetailBody(prestation: prestation);
      },
    );
  }
}

class _PrestationDetailBody extends ConsumerWidget {
  const _PrestationDetailBody({required this.prestation});

  final PrestationEntity prestation;

  Future<void> _printInvoice(BuildContext context, WidgetRef ref) async {
    final prestationId = prestation.id;
    final establishment = await ref.read(currentEstablishmentProvider.future);
    final vehicule = await ref.read(
      vehiculeProvider(prestation.vehiculeId).future,
    );
    final lines = await ref.read(prestationLinesProvider(prestationId).future);
    final client = prestation.clientId != null
        ? await ref.read(clientByIdProvider(prestation.clientId!).future)
        : null;
    final facture = await ref.read(
      factureForActivityProvider(
        BillingActivityRef(
          type: BillingActivityType.prestation,
          id: prestationId,
        ),
      ).future,
    );

    if (!context.mounted) return;

    final data = InvoiceTicketData(
      establishmentName: establishment?.name ?? 'Facture',
      establishmentPhone: establishment?.phone,
      reference: facture?.reference ?? prestationId,
      date: facture?.issuedAt ?? DateTime.now(),
      clientName: client?.name,
      clientPhone: client?.displayPhone,
      vehicleLabel: vehicule != null
          ? '${vehicule.displayName} (${vehicule.immatriculation})'
          : null,
      lines: [
        for (final line in lines)
          InvoiceTicketLine(
            label: line.libelle,
            quantity: line.quantite,
            unitPrice: line.prixUnitaire,
            lineAmount: line.montantLigne,
          ),
      ],
      totalAmount: facture?.totalAmount ?? prestation.montantTotal,
      paidAmount: facture?.paidAmount,
      balanceDue: facture?.balanceDue,
      currency: facture?.currency ?? AppCurrency.cdf,
      statusLabel: facture?.status.label,
    );

    await printInvoiceTicket(context, ref, data);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicule =
        ref.watch(vehiculeProvider(prestation.vehiculeId)).valueOrNull;
    final title = vehicule?.displayName ?? '…';
    final showSubtitle =
        vehicule != null && vehicule.marque != null && vehicule.modele != null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              if (showSubtitle)
                Text(
                  vehicule.immatriculation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Imprimer la facture',
              icon: const Icon(Icons.print_outlined),
              onPressed: () => _printInvoice(context, ref),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Travaux'),
              Tab(text: 'Client'),
              Tab(text: 'Facture'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PrestationWorksTab(prestationId: prestation.id),
            PrestationClientTab(prestationId: prestation.id),
            _PrestationBillingTab(
              prestationId: prestation.id,
              totalAmount: prestation.montantTotal,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrestationBillingTab extends StatelessWidget {
  const _PrestationBillingTab({
    required this.prestationId,
    required this.totalAmount,
  });

  final String prestationId;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      children: [
        ActivityBillingPanel(
          activity: BillingActivityRef(
            type: BillingActivityType.prestation,
            id: prestationId,
          ),
          totalAmount: totalAmount,
        ),
      ],
    );
  }
}
