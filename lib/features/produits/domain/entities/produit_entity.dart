import '../../../../core/domain/app_currency.dart';

const defaultProductStockAlertThreshold = 5;

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
    required this.stockTrackingEnabled,
    this.stockAlertThreshold = defaultProductStockAlertThreshold,
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
  final bool stockTrackingEnabled;
  final int stockAlertThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductStockStatus get stockStatus => stockTrackingEnabled
      ? ProductStockStatus.of(stock, alertThreshold: stockAlertThreshold)
      : ProductStockStatus.notTracked;
}

/// Seuils d'affichage du badge de stock sur la carte produit et du filtre
/// "En rupture" — pas de configuration métier pour l'instant, un seuil fixe
/// suffit tant qu'aucun établissement ne demande de le personnaliser.
enum ProductStockStatus {
  notTracked,
  outOfStock,
  low,
  inStock;

  static ProductStockStatus of(
    int stock, {
    int alertThreshold = defaultProductStockAlertThreshold,
  }) {
    if (stock <= 0) return ProductStockStatus.outOfStock;
    if (stock <= alertThreshold) return ProductStockStatus.low;
    return ProductStockStatus.inStock;
  }
}
