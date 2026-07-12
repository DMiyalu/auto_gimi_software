/// Catégorie de services du catalogue (ex. Mécanique, Carrosserie).
class ServiceCategoryEntity {
  const ServiceCategoryEntity({
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
