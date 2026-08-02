import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../garage/presentation/providers/prestation_providers.dart';
import '../../../primary_module/config/business_module_config.dart';
import '../../../primary_module/widgets/module_fab.dart';
import '../providers/client_list_view_providers.dart';
import '../providers/client_providers.dart';
import '../widgets/client_card.dart';
import '../widgets/client_filters.dart';
import '../widgets/client_search_bar.dart';

class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clients)),
      floatingActionButton: ModuleFab(
        actions: [
          FabActionConfig(
            label: l10n.addClient,
            icon: Icons.person_add_alt_outlined,
            route: Routes.clientNew,
          ),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (clients) {
          if (clients.isEmpty) {
            return _EmptyClients(l10n: l10n);
          }

          return Column(
            children: [
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: ClientSearchBar()),
                    const SizedBox(width: AppSpacing.xs),
                    const _FiltersButton(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const ClientFilters(),
              const SizedBox(height: AppSpacing.sm),
              const Expanded(child: _ClientListView()),
            ],
          );
        },
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
      },
      icon: const Icon(Icons.tune, size: 18),
      label: Text(l10n.filters),
    );
  }
}

class _EmptyClients extends StatelessWidget {
  const _EmptyClients({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noClients,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noClientsHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientListView extends ConsumerWidget {
  const _ClientListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clients = ref.watch(filteredClientsProvider);
    final orderStats = ref.watch(clientOrderStatsProvider).valueOrNull ?? {};

    if (clients.isEmpty) {
      return Center(
        child: Text(
          l10n.noClientsMatchFilter,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      itemCount: clients.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.clientsListTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.clientsCount(clients.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final client = clients[index - 1];
        return ClientCard(client: client, stats: orderStats[client.id]);
      },
    );
  }
}
