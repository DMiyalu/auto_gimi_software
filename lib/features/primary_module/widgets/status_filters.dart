import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/primary_module_providers.dart';

/// Liste horizontale scrollable de filtres rapides — les options viennent
/// entièrement de la configuration métier active. Même chip, mêmes couleurs
/// sur tous les écrans de l'app (Clients, Produits inclus).
class StatusFilters extends ConsumerWidget {
  const StatusFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(primaryModuleConfigProvider);
    final items = ref.watch(activityListProvider);
    final selected = ref.watch(moduleSelectedFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: config.statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = config.statusFilters[index];
          final isSelected = option.key == selected;
          final hasItems = option.key == 'all'
              ? items.isNotEmpty
              : items.any((item) => item.statusKey == option.key);

          final dotColor = switch (option.key) {
            'en_attente' => AppColors.violetClair,
            'en_preparation' => AppColors.violetPrincipal,
            'pretes' => AppColors.bleuRoyal,
            _ => config.primaryColor,
          };

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
