import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/activity_item.dart';

/// Écran de détail générique, piloté par [item]. Sert de base commune en
/// attendant que chaque métier obtienne un écran dédié (ex.
/// `PrestationDetailScreen`) — il suffira alors de remplacer le builder de
/// route pour `Routes.activityDetail`, sans dupliquer cette coquille.
class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.item});

  final ActivityItem? item;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Activité introuvable')));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: item.statusColor.withValues(alpha: 0.12),
                child: Icon(
                  item.leadingIcon,
                  color: item.statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      DateFormat.yMMMd('fr').add_Hm().format(item.time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  item.statusLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: item.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          if (item.metaLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(item.metaLabel!),
              ],
            ),
          ],
          if (item.amount != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${NumberFormat('#,##0', 'fr').format(item.amount)} FC',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}
