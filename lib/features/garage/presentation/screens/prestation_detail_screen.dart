import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        );
      },
    );
  }
}

class _PrestationDetailBody extends ConsumerWidget {
  const _PrestationDetailBody({
    required this.prestationId,
    required this.vehiculeId,
  });

  final String prestationId;
  final String vehiculeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicule = ref.watch(vehiculeProvider(vehiculeId)).valueOrNull;
    final title = vehicule?.displayName ?? '…';
    final showSubtitle =
        vehicule != null && vehicule.marque != null && vehicule.modele != null;

    return DefaultTabController(
      length: 2,
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
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          bottom: const TabBar(
            tabs: [Tab(text: 'Travaux'), Tab(text: 'Client')],
          ),
        ),
        body: TabBarView(
          children: [
            PrestationWorksTab(prestationId: prestationId),
            PrestationClientTab(prestationId: prestationId),
          ],
        ),
      ),
    );
  }
}
