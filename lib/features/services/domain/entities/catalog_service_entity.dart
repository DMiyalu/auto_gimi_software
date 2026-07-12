import '../../../../core/domain/app_currency.dart';

/// Service proposé par le garage, éventuellement rattaché à une catégorie.
class CatalogServiceEntity {
  const CatalogServiceEntity({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.price,
    required this.currency,
    required this.intervalDays,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final double price;
  final AppCurrency currency;
  final int intervalDays;
  final DateTime createdAt;
  final DateTime updatedAt;
}
