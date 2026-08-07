import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../providers/produit_providers.dart';

/// Filtres rapides de l'écran Produits — même UI/UX que les filtres des
/// écrans Clients et Commandes (chips horizontaux défilants) : "Tous", les
/// catégories du catalogue, puis "En rupture".
class ProduitFilters extends ConsumerWidget {
  const ProduitFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = ref.watch(primaryModuleConfigProvider).primaryColor;
    final categories = ref.watch(productCategoriesProvider).valueOrNull ?? [];
    final selected = ref.watch(produitFilterProvider);

    final options = <(String?, String)>[
      (null, 'Tous'),
      for (final category in categories) (category.id, category.name),
      (produitOutOfStockFilterValue, l10n.productFilterOutOfStock),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = options[index];
          final isSelected = selected == key;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) =>
                ref.read(produitFilterProvider.notifier).state = key,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            backgroundColor: AppColors.chipBackground,
            selectedColor: primaryColor,
            shape: const StadiumBorder(side: BorderSide.none),
            label: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
