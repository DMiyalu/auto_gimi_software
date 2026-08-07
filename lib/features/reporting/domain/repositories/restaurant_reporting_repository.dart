import '../entities/product_sales_item.dart';
import '../entities/report_date_range.dart';

/// Accès aux agrégats reporting restaurant qui nécessitent des jointures
/// Drift (lignes × commandes × produits).
abstract class RestaurantReportingRepository {
  /// Ventes par produit pour les commandes clôturées de [range],
  /// optionnellement filtrées par [categoryId].
  ///
  /// Tri décroissant par quantité ; [limit] borne le top N (`null` = tous).
  Stream<List<ProductSalesItem>> watchProductSales({
    required String establishmentId,
    required ReportDateRange range,
    String? categoryId,
    int? limit,
  });
}
