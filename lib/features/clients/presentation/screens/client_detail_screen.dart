import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/business_category.dart';
import '../../../../core/domain/client_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../garage/domain/entities/prestation_summary.dart';
import '../../../garage/presentation/providers/prestation_providers.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../../domain/entities/client_entity.dart';
import '../providers/client_providers.dart';

/// Détail d'un client — commun à tous les métiers. L'onglet Historique tire
/// ses données du métier actif (prestations pour le garage aujourd'hui) ;
/// les autres métiers afficheront leur propre historique (commandes,
/// collectes...) au fur et à mesure de leur mise en place.
class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientByIdProvider(clientId));

    return clientAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      data: (client) {
        if (client == null) {
          return const Scaffold(
            body: Center(child: Text('Client introuvable.')),
          );
        }
        return _ClientDetailBody(client: client);
      },
    );
  }
}

class _ClientDetailBody extends ConsumerWidget {
  const _ClientDetailBody({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.clientDetailTitle),
          actions: [
            TextButton(
              onPressed: () => context.push(Routes.clientEditPath(client.id)),
              child: Text(l10n.modify),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabInformations),
              Tab(text: l10n.tabHistory),
              Tab(text: l10n.tabNotes),
            ],
          ),
        ),
        body: Column(
          children: [
            _ClientHeader(client: client),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _InformationsTab(client: client),
                  _HistoryTab(client: client),
                  _NotesTab(client: client),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            child: Text(
              client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ClientBadge(client: client),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        client.displayPhone,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientBadge extends StatelessWidget {
  const _ClientBadge({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBusiness = client.clientType == ClientType.business;
    final label = isBusiness
        ? l10n.clientTypeBusiness
        : l10n.clientTypeIndividual;
    final color = isBusiness
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InformationsTab extends ConsumerWidget {
  const _InformationsTab({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activity = _watchClientActivity(ref, client.id);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      children: [
        if (client.email != null)
          _InfoRow(label: l10n.clientEmail, value: client.email!),
        _InfoRow(label: l10n.clientAddress, value: client.address ?? '—'),
        _InfoRow(
          label: l10n.registeredOn,
          value: DateUtilsHelper.formatDate(
            client.createdAt,
            locale: l10n.localeName,
          ),
        ),
        _InfoRow(label: l10n.totalOrders, value: '${activity.length}'),
        _InfoRow(
          label: l10n.totalSpent,
          value: _formatAmount(
            activity.fold<double>(0, (sum, item) => sum + item.montantTotal),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (activity.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tabHistory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => DefaultTabController.of(context).animateTo(1),
                child: Text(l10n.seeAll),
              ),
            ],
          ),
          for (final item in activity.take(2))
            _ActivityTile(item: item, locale: l10n.localeName),
        ],
      ],
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activity = _watchClientActivity(ref, client.id);

    if (activity.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            l10n.noHistoryYet,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: activity.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _ActivityTile(item: activity[index], locale: l10n.localeName),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notes = client.notes;

    if (notes == null || notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            l10n.noNotesYet,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(notes, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.locale});

  final PrestationSummary item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.vehiculeDisplayName),
        subtitle: Text(
          DateUtilsHelper.formatDate(item.dateOuverture, locale: locale),
        ),
        trailing: Text(
          _formatAmount(item.montantTotal),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        onTap: () => context.push(Routes.prestationDetailPath(item.id)),
      ),
    );
  }
}

/// Historique/stats du client — branché sur les prestations réelles pour le
/// garage (seul métier avec une verticale transactionnelle en place) ; les
/// autres métiers retombent sur une liste vide en attendant leur propre
/// historique (commandes, collectes...).
List<PrestationSummary> _watchClientActivity(WidgetRef ref, String clientId) {
  final category = ref.watch(activeBusinessCategoryProvider);
  if (category != BusinessCategory.garageAuto) return const [];
  return ref.watch(prestationsForClientProvider(clientId)).valueOrNull ?? [];
}

String _formatAmount(double amount) {
  final formatted = NumberFormat.decimalPattern().format(amount.round());
  return '$formatted FC';
}
