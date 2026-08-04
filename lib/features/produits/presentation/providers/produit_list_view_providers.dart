import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/produit_entity.dart';
import 'produit_providers.dart';

/// Produits après recherche + filtre rapide (catégorie ou "En rupture").
final filteredProduitsProvider = Provider<List<ProduitEntity>>((ref) {
  final produits = ref.watch(produitsProvider).valueOrNull ?? [];
  final query = ref.watch(produitSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(produitFilterProvider);

  return produits.where((produit) {
    if (query.isNotEmpty && !produit.name.toLowerCase().contains(query)) {
      return false;
    }

    if (filter == null) return true;
    if (filter == produitOutOfStockFilterValue) {
      return produit.stockTrackingEnabled &&
          produit.stockStatus == ProductStockStatus.outOfStock;
    }
    return produit.categoryId == filter;
  }).toList();
});
