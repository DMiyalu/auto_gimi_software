import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../billing/domain/entities/facture_entity.dart';
import '../../../billing/presentation/providers/billing_providers.dart';
import '../../../billing/presentation/widgets/activity_billing_panel.dart';
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
        return _PrestationDetailBody(
          prestationId: prestationId,
          vehiculeId: prestation.vehiculeId,
          totalAmount: prestation.montantTotal,
        );
      },
    );
  }
}

class _PrestationDetailBody extends ConsumerWidget {
  const _PrestationDetailBody({
    required this.prestationId,
    required this.vehiculeId,
    required this.totalAmount,
  });

  final String prestationId;
  final String vehiculeId;
  final double totalAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicule = ref.watch(vehiculeProvider(vehiculeId)).valueOrNull;
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
            PrestationWorksTab(prestationId: prestationId),
            PrestationClientTab(prestationId: prestationId),
            _PrestationBillingTab(
              prestationId: prestationId,
              totalAmount: totalAmount,
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
