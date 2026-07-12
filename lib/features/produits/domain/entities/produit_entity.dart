/// Produit proposé par le garage, rattaché à une catégorie.
class ProduitEntity {
  const ProduitEntity({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
}
