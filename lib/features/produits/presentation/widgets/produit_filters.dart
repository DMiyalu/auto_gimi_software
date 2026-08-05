import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/produit_providers.dart';

/// Filtres rapides de l'écran Produits — même UI/UX que les filtres des
/// écrans Clients et Commandes (chips horizontaux défilants) : "Tous", les
/// catégories du catalogue, puis "En rupture".
class ProduitFilters extends ConsumerWidget {
  const ProduitFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(productCategoriesProvider).valueOrNull ?? [];
    final selected = ref.watch(produitFilterProvider);

    final options = <(String?, String)>[
      (null, 'Tous'),
      for (final category in categories) (category.id, category.name),
      (produitOutOfStockFilterValue, l10n.productFilterOutOfStock),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final (key, label) = options[index];
          return ChoiceChip(
            label: Text(label),
            selected: selected == key,
            onSelected: (_) =>
                ref.read(produitFilterProvider.notifier).state = key,
          );
        },
      ),
    );
  }
}
