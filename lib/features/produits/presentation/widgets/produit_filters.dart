import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_category_entity.dart';
import '../providers/produit_providers.dart';

/// Catégories Produits — tuiles horizontales style maquette Zuri.
class ProduitFilters extends ConsumerWidget {
  const ProduitFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(productCategoriesProvider).valueOrNull ?? [];
    final selected = ref.watch(produitFilterProvider);

    final options = <_CategoryOption>[
      _CategoryOption(
        key: null,
        label: l10n.productFilterAll,
        icon: Icons.grid_view_rounded,
      ),
      for (final category in categories)
        _CategoryOption(
          key: category.id,
          label: category.name,
          icon: _iconForCategory(category.name),
        ),
      _CategoryOption(
        key: produitOutOfStockFilterValue,
        label: l10n.productFilterOutOfStock,
        icon: Icons.warning_amber_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.productCategories,
                  style: const TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showAllCategories(
                  context,
                  ref,
                  l10n: l10n,
                  categories: categories,
                  selected: selected,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.zuriRed,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.seeAll,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selected == option.key;
              return _CategoryTile(
                key: Key('product_filter_${option.key ?? 'all'}'),
                label: option.label,
                icon: option.icon,
                selected: isSelected,
                onTap: () =>
                    ref.read(produitFilterProvider.notifier).state = option.key,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAllCategories(
    BuildContext context,
    WidgetRef ref, {
    required AppLocalizations l10n,
    required List<ProductCategoryEntity> categories,
    required String? selected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D8E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.productCategories,
                  style: const TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    Icons.grid_view_rounded,
                    color: selected == null
                        ? AppColors.zuriRed
                        : AppColors.zuriNavy,
                  ),
                  title: Text(l10n.productFilterAll),
                  trailing: selected == null
                      ? const Icon(Icons.check, color: AppColors.zuriRed)
                      : null,
                  onTap: () {
                    ref.read(produitFilterProvider.notifier).state = null;
                    Navigator.of(sheetContext).pop();
                  },
                ),
                for (final category in categories)
                  ListTile(
                    leading: Icon(
                      _iconForCategory(category.name),
                      color: selected == category.id
                          ? AppColors.zuriRed
                          : AppColors.zuriNavy,
                    ),
                    title: Text(category.name),
                    trailing: selected == category.id
                        ? const Icon(Icons.check, color: AppColors.zuriRed)
                        : null,
                    onTap: () {
                      ref.read(produitFilterProvider.notifier).state =
                          category.id;
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ListTile(
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: selected == produitOutOfStockFilterValue
                        ? AppColors.zuriRed
                        : AppColors.zuriNavy,
                  ),
                  title: Text(l10n.productFilterOutOfStock),
                  trailing: selected == produitOutOfStockFilterValue
                      ? const Icon(Icons.check, color: AppColors.zuriRed)
                      : null,
                  onTap: () {
                    ref.read(produitFilterProvider.notifier).state =
                        produitOutOfStockFilterValue;
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.add_rounded,
                    color: AppColors.zuriRed,
                  ),
                  title: Text(l10n.addProductCategory),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(Routes.productCategoryNew);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryOption {
  const _CategoryOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String? key;
  final String label;
  final IconData icon;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.zuriPink.withValues(alpha: 0.12)
          : AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.zuriPink.withValues(alpha: 0.35)
                  : const Color(0xFFE6E8EF),
            ),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: AppColors.zuriNavy.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? AppColors.zuriRed : const Color(0xFF8A90A5),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppColors.zuriRed : AppColors.zuriNavy,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForCategory(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('boisson')) return Icons.local_cafe_outlined;
  if (lower.contains('dessert')) return Icons.cake_outlined;
  if (lower.contains('plat')) return Icons.ramen_dining_outlined;
  if (lower.contains('accompagn')) return Icons.fastfood_outlined;
  if (lower.contains('ingr')) return Icons.kitchen_outlined;
  return Icons.category_outlined;
}
