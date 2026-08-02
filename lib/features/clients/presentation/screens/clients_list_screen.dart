import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../primary_module/config/business_module_config.dart';
import '../../../primary_module/widgets/module_fab.dart';
import '../providers/client_providers.dart';
import '../widgets/client_avatar.dart';
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
              const ClientSearchBar(),
              const SizedBox(height: AppSpacing.sm),
              const ClientFilters(),
              const SizedBox(height: AppSpacing.xs),
              const Expanded(child: _ClientListView()),
            ],
          );
        },
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: clients.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final client = clients[index];
        return ListTile(
          onTap: () => context.push(Routes.clientDetailPath(client.id)),
          leading: ClientAvatar(client: client),
          title: Text(client.name),
          subtitle: Row(
            children: [
              Icon(
                Icons.chat_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(client.displayPhone),
            ],
          ),
          trailing: client.loyaltyPoints > 0
              ? Chip(
                  label: Text('${client.loyaltyPoints} pts'),
                  visualDensity: VisualDensity.compact,
                )
              : null,
        );
      },
    );
  }
}
