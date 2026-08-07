/// Ligne de répartition des ventes par produit (catégorie filtrée).
class ProductSalesItem {
  const ProductSalesItem({
    required this.produitId,
    required this.label,
    required this.quantity,
    required this.amount,
    required this.percentage,
    required this.rank,
  });

  final String produitId;
  final String label;
  final int quantity;
  final double amount;

  /// Part du volume (quantité) dans la catégorie, 0–100.
  final double percentage;

  final int rank;
}
