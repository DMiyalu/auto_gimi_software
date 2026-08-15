import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
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
    final usesRestaurantWorkflow = config.category.usesRestaurantWorkflow;

    return SizedBox(
      height: usesRestaurantWorkflow ? 44 : 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: config.statusFilters.length,
        separatorBuilder: (_, _) =>
            SizedBox(width: usesRestaurantWorkflow ? 8 : 8),
        itemBuilder: (context, index) {
          final option = config.statusFilters[index];
          final isSelected = option.key == selected;
          final hasItems = option.key == 'all'
              ? items.isNotEmpty
              : items.any((item) => item.statusKey == option.key);

          final dotColor = switch (option.key) {
            'en_cours' || 'en_attente' => const Color(0xFFFF8A00),
            'a_payer' || 'en_preparation' => config.primaryColor,
            'cloturee' || 'pretes' || 'terminees' => const Color(0xFF16A34A),
            'annulees' => Colors.grey,
            'livraison' => AppColors.zuriMagenta,
            _ => config.primaryColor,
          };

          if (usesRestaurantWorkflow) {
            return Material(
              key: Key('status_filter_${option.key}'),
              color: isSelected ? config.primaryColor : AppColors.zuriWhite,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () =>
                    ref.read(moduleSelectedFilterProvider.notifier).state =
                        option.key,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? config.primaryColor
                          : const Color(0xFFE6E8EF),
                    ),
                    boxShadow: isSelected
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.zuriNavy.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.zuriWhite
                                : AppColors.zuriNavy,
                            fontSize: 14,
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
                              color: isSelected ? Colors.white : dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) =>
                ref.read(moduleSelectedFilterProvider.notifier).state =
                    option.key,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            backgroundColor: AppColors.chipBackground,
            selectedColor: config.primaryColor,
            shape: const StadiumBorder(side: BorderSide.none),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
        },
      ),
    );
  }
}
