import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';

/// Liste horizontale scrollable de filtres rapides — les options viennent
/// entièrement de la configuration métier active.
class StatusFilters extends ConsumerWidget {
  const StatusFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(primaryModuleConfigProvider);
    final items = ref.watch(mockActivityListProvider);
    final selected = ref.watch(moduleSelectedFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: config.statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final option = config.statusFilters[index];
          final isSelected = option.key == selected;
          final hasItems = option.key == 'all'
              ? items.isNotEmpty
              : items.any((item) => item.statusKey == option.key);

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.label),
                if (hasItems && option.key != 'all') ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : config.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            selected: isSelected,
            onSelected: (_) => ref
                .read(moduleSelectedFilterProvider.notifier)
                .state = option.key,
          );
        },
      ),
    );
  }
}
