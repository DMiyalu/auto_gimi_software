import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/client_tier.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/domain_card.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../garage/domain/entities/client_order_stats.dart';
import '../../domain/entities/client_entity.dart';
import 'client_avatar.dart';

/// Carte client de la liste — même ossature que les cartes d'activité de
/// l'écran principal (liseré coloré, coins arrondis, ombre douce), avec un
/// contenu propre aux clients (palier de fidélité, stats de commandes).
class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client, required this.stats});

  final ClientEntity client;
  final ClientOrderStats? stats;

  static final _dateFormat = DateFormat('dd/MM');
  static final _amountFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final tier = ClientTier.forPoints(client.loyaltyPoints);

    return DomainCard(
      accentColor: _accentColor(tier),
      onTap: () => context.push(Routes.clientDetailPath(client.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClientAvatar(client: client),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        client.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tier != ClientTier.none) ...[
                      const SizedBox(width: 6),
                      _TierBadge(tier: tier),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  client.displayPhone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatLine(
                        label: l10n.totalOrderedAmount,
                        value:
                            '${_amountFormat.format(stats?.totalSpent ?? 0)} FC',
                      ),
                    ),
                    Expanded(
                      child: _StatLine(
                        label: l10n.lastOrderLabel,
                        value: stats == null
                            ? l10n.noOrdersYet
                            : '${_dateFormat.format(stats!.lastOrderAt)}, '
                                  '${stats!.lastOrderContext}',
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Color _accentColor(ClientTier tier) {
    if (tier == ClientTier.gold) return Colors.amber.shade700;
    final lastOrderAt = stats?.lastOrderAt;
    final now = DateTime.now();
    final activeThisMonth =
        lastOrderAt != null &&
        lastOrderAt.year == now.year &&
        lastOrderAt.month == now.month;
    return activeThisMonth ? Colors.green.shade600 : Colors.red.shade400;
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final ClientTier tier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = tier == ClientTier.gold
        ? l10n.clientTierGold
        : l10n.clientTierLoyal;
    final color = tier == ClientTier.gold
        ? Colors.amber.shade700
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
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

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final crossAxis = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
