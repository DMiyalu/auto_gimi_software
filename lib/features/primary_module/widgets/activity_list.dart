import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/business_category.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';
import '../models/activity_item.dart';
import 'activity_card.dart';
import 'activity_card_actions_sheet.dart';

/// Liste principale de l'activité métier — recherche + filtre déjà
/// appliqués en amont par [filteredActivityListProvider].
class ActivityList extends ConsumerWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredActivityListProvider);
    final config = ref.watch(primaryModuleConfigProvider);

    if (items.isEmpty) {
      return _EmptyState(icon: config.activityIcon);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final list = ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            96,
          ),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final item = items[index];
            return _AnimatedEntry(
              key: ValueKey(item.id),
              index: index,
              child: Slidable(
                startActionPane: _printActionPane(
                  context,
                  item,
                  config.primaryColor,
                ),
                endActionPane: _printActionPane(
                  context,
                  item,
                  config.primaryColor,
                ),
                child: ActivityCard(
                  item: item,
                  onTap: () {
                    if (config.category == BusinessCategory.garageAuto) {
                      context.push(Routes.prestationDetailPath(item.id));
                      return;
                    }
                    if (config.category == BusinessCategory.restaurant) {
                      context.push(Routes.commandeDetailPath(item.id));
                      return;
                    }
                    context.push(
                      Routes.activityDetailPath(item.id),
                      extra: item,
                    );
                  },
                  onLongPress: () =>
                      showActivityCardActions(context, ref, item),
                ),
              ),
            );
          },
        );

        if (!isWide) return list;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: list,
          ),
        );
      },
    );
  }

  /// Glisser à gauche ou à droite révèle la même action "Imprimer" des deux
  /// côtés — cohérent avec la demande d'un geste symétrique façon
  /// messagerie plutôt que deux actions différentes par sens.
  ActionPane _printActionPane(
    BuildContext context,
    ActivityItem item,
    Color color,
  ) {
    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.28,
      children: [
        SlidableAction(
          onPressed: (_) => printInvoiceFeedback(context, item),
          backgroundColor: color,
          foregroundColor: Colors.white,
          icon: Icons.print_outlined,
          label: 'Imprimer',
          borderRadius: AppRadius.cardRadius,
        ),
      ],
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  const _AnimatedEntry({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index * 40).clamp(0, 300);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Rien à afficher pour l’instant',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
