import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/business_category.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';
import '../models/activity_item.dart';
import 'activity_card.dart';
import 'activity_card_actions_sheet.dart';
import '../config/business_module_config.dart';

/// Liste principale de l'activité métier — recherche + filtre déjà
/// appliqués en amont par [filteredActivityListProvider].
class ActivityList extends ConsumerWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredActivityListProvider);
    final config = ref.watch(primaryModuleConfigProvider);
    final isRestaurant = config.category == BusinessCategory.restaurant;

    if (items.isEmpty) {
      return _EmptyState(config: config);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        Widget buildItem(int index) {
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
                  context.push(Routes.activityDetailPath(item.id), extra: item);
                },
                onLongPress: () => showActivityCardActions(context, ref, item),
              ),
            ),
          );
        }

        final list = isRestaurant
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                child: Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      buildItem(index),
                      if (index < items.length - 1)
                        const SizedBox(height: AppSpacing.xs),
                    ],
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  96,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) => buildItem(index),
              );

        final content = Column(
          children: [
            if (isRestaurant)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Aujourd'hui",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.zuriNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${items.length} commande${items.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.zuriRed,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: list),
          ],
        );

        if (!isWide) return content;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: content,
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
  const _EmptyState({required this.config});

  final BusinessModuleConfig config;

  @override
  Widget build(BuildContext context) {
    final copy = _copyFor(config.category);
    final primaryAction = config.fabActions
        .where((action) => action.route != null)
        .firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 120),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 140).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: config.primaryColor.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      config.activityIcon,
                      size: 38,
                      color: config.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    copy.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF101529),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    copy.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF707792),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (primaryAction != null) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.push(primaryAction.route!),
                      icon: Icon(primaryAction.icon),
                      label: Text(primaryAction.label),
                      style: FilledButton.styleFrom(
                        backgroundColor: config.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _EmptyCopy _copyFor(BusinessCategory category) {
    return switch (category) {
      BusinessCategory.restaurant => const _EmptyCopy(
        title: 'Votre salle est prête à accueillir sa première commande',
        subtitle:
            'Créez une commande en quelques secondes, puis ajoutez les produits au fil du service.',
      ),
      BusinessCategory.garageAuto => const _EmptyCopy(
        title: 'Votre atelier est prêt pour la première prestation',
        subtitle:
            'Ajoutez une prestation dès qu’un véhicule arrive et suivez chaque étape depuis ici.',
      ),
      BusinessCategory.sanitation => const _EmptyCopy(
        title: 'Votre tournée peut commencer ici',
        subtitle:
            'Planifiez une première collecte et gardez le suivi opérationnel au même endroit.',
      ),
      _ => const _EmptyCopy(
        title: 'Tout est prêt pour démarrer',
        subtitle:
            'Ajoutez une première activité pour commencer à suivre votre journée.',
      ),
    };
  }
}

class _EmptyCopy {
  const _EmptyCopy({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
