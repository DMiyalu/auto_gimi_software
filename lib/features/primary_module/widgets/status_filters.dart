import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/business_category.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';

/// Liste horizontale scrollable de filtres rapides — les options viennent
/// entièrement de la configuration métier active.
class StatusFilters extends ConsumerWidget {
  const StatusFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(primaryModuleConfigProvider);
    final items = ref.watch(activityListProvider);
    final selected = ref.watch(moduleSelectedFilterProvider);
    final isRestaurant = config.category == BusinessCategory.restaurant;

    return SizedBox(
      height: isRestaurant ? 48 : 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isRestaurant ? 18 : 16),
        itemCount: config.statusFilters.length,
        separatorBuilder: (_, _) =>
            SizedBox(width: isRestaurant ? 8 : AppSpacing.xs),
        itemBuilder: (context, index) {
          final option = config.statusFilters[index];
          final isSelected = option.key == selected;
          final hasItems = option.key == 'all'
              ? items.isNotEmpty
              : items.any((item) => item.statusKey == option.key);

          final dotColor = switch (option.key) {
            'en_attente' => const Color(0xFFFF970F),
            'en_preparation' => const Color(0xFF1E88E5),
            'pretes' => const Color(0xFF40C979),
            _ => config.primaryColor,
          };

          if (isRestaurant) {
            return FilterChip(
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) =>
                  ref.read(moduleSelectedFilterProvider.notifier).state =
                      option.key,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              backgroundColor: const Color(0xFFF4F5F9),
              selectedColor: config.primaryColor,
              shape: const StadiumBorder(side: BorderSide.none),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF101529),
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  if (hasItems && option.key != 'all') ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

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
                      color: isSelected ? Colors.white : config.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(moduleSelectedFilterProvider.notifier).state =
                    option.key,
          );
        },
      ),
    );
  }
}
