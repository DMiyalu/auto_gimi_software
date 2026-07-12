/// Catégorie de produits (ex. Huiles, Filtres).
class ProductCategoryEntity {
  const ProductCategoryEntity({
    required this.id,
    required this.name,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
}
