/// Service proposé par le garage, rattaché à une catégorie.
class CatalogServiceEntity {
  const CatalogServiceEntity({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.intervalDays,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final double price;
  final int intervalDays;
  final DateTime createdAt;
  final DateTime updatedAt;
}
