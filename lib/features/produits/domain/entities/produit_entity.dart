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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final double price;
  final AppCurrency currency;
  final DateTime createdAt;
  final DateTime updatedAt;
}
