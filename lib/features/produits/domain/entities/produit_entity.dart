import '../../../../core/domain/app_currency.dart';

/// Produit proposé par le garage, éventuellement rattaché à une catégorie.
class ProduitEntity {
  const ProduitEntity({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.price,
    required this.currency,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final double price;
  final AppCurrency currency;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductStockStatus get stockStatus => ProductStockStatus.of(stock);
}

/// Seuils d'affichage du badge de stock sur la carte produit et du filtre
/// "En rupture" — pas de configuration métier pour l'instant, un seuil fixe
/// suffit tant qu'aucun établissement ne demande de le personnaliser.
enum ProductStockStatus {
  outOfStock,
  low,
  inStock;

  static ProductStockStatus of(int stock) {
    if (stock <= 0) return ProductStockStatus.outOfStock;
    if (stock < 5) return ProductStockStatus.low;
    return ProductStockStatus.inStock;
  }
}
