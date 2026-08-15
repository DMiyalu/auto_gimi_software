import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/presentation/widgets/domain_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';
import '../models/activity_item.dart';

/// Carte générique représentant une ligne d'activité (commande, prestation,
/// collecte...). Entièrement pilotée par [item] — ne connaît jamais le
/// métier actif.
class ActivityCard extends ConsumerWidget {
  const ActivityCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  final ActivityItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static final _amountFormat = NumberFormat('#,##0', 'fr');
  static final _timeFormat = DateFormat.Hm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = ref.watch(primaryModuleConfigProvider);

    if (config.category.usesRestaurantWorkflow) {
      return _RestaurantActivityCard(
        item: item,
        onTap: onTap,
        onLongPress: onLongPress,
      );
    }

    return DomainCard(
      accentColor: item.statusColor,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: item.statusColor.withValues(alpha: 0.12),
                child: Icon(item.leadingIcon, color: item.statusColor),
              ),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${item.badgeCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.pinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _timeFormat.format(item.time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (item.metaLabel != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.metaLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.amount != null)
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                          children: [
                            TextSpan(text: _amountFormat.format(item.amount)),
                            TextSpan(
                              text: ' FC',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),
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
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: item.statusColor,
                              fontWeight: FontWeight.w600,
                            ),
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

class _RestaurantActivityCard extends StatelessWidget {
  const _RestaurantActivityCard({
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  final ActivityItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static final _amountFormat = NumberFormat('#,##0', 'fr');
  static final _timeFormat = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    final accent = item.accentColor ?? item.statusColor;
    final statusFill = item.statusColor.withValues(alpha: 0.12);
    final metaIsPlace = item.leadingIcon == Icons.delivery_dining_outlined;

    return Material(
      color: AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            color: AppColors.zuriWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.zuriNavy.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: accent, width: 4)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Icon(item.leadingIcon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.zuriNavy,
                                  fontSize: 16,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (item.pinned) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.push_pin,
                            size: 14,
                            color: Color(0xFF8A90A5),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8A90A5),
                        fontSize: 13.5,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.metaLabel != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            metaIsPlace
                                ? Icons.location_on_outlined
                                : Icons.person_outline,
                            size: 15,
                            color: const Color(0xFF8A90A5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.metaLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF8A90A5),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeFormat.format(item.time),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A90A5),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_amountFormat.format(item.amount ?? 0)} FC',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.zuriNavy,
                              fontSize: 16,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      if (item.badgeCount != null && item.badgeCount! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.zuriRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${item.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: item.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
