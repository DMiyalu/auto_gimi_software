import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../garage/domain/entities/client_order_stats.dart';
import '../../../garage/presentation/providers/prestation_providers.dart';
import '../../../primary_module/config/business_module_config.dart';
import '../../../primary_module/widgets/module_fab.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../../domain/entities/client_entity.dart';
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

    return PrimaryScaffold(
      floatingActionButton: ModuleFab(
        color: AppColors.zuriRed,
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

          return const Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: ClientSearchBar(),
              ),
              SizedBox(height: 12),
              ClientFilters(),
              SizedBox(height: 12),
              Expanded(child: _ClientListView()),
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
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.zuriPink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 38,
                color: AppColors.zuriRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noClients,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.zuriNavy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noClientsHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8A90A5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientListView extends ConsumerStatefulWidget {
  const _ClientListView();

  @override
  ConsumerState<_ClientListView> createState() => _ClientListViewState();
}

class _ClientListViewState extends ConsumerState<_ClientListView> {
  var _showAll = false;

  static const _recentLimit = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clients = ref.watch(filteredClientsProvider);
    final orderStats = ref.watch(clientOrderStatsProvider).valueOrNull ?? {};

    if (clients.isEmpty) {
      return Center(
        child: Text(
          l10n.noClientsMatchFilter,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A90A5),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final sorted = _sortedByRecency(clients, orderStats);
    final visible =
        _showAll || sorted.length <= _recentLimit
            ? sorted
            : sorted.take(_recentLimit).toList();
    final canExpand = sorted.length > _recentLimit;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
      itemCount: visible.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recentClientsTitle,
                    style: const TextStyle(
                      color: AppColors.zuriNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (canExpand)
                  TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.zuriRed,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _showAll ? l10n.clientsCount(sorted.length) : l10n.seeAll,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        final client = visible[index - 1];
        return ClientCard(client: client, stats: orderStats[client.id]);
      },
    );
  }

  List<ClientEntity> _sortedByRecency(
    List<ClientEntity> clients,
    Map<String, ClientOrderStats> orderStats,
  ) {
    final copy = [...clients];
    copy.sort((a, b) {
      final aDate = orderStats[a.id]?.lastOrderAt ?? a.updatedAt;
      final bDate = orderStats[b.id]?.lastOrderAt ?? b.updatedAt;
      return bDate.compareTo(aDate);
    });
    return copy;
  }
}
