import '../../../../core/domain/app_currency.dart';
import '../entities/product_category_entity.dart';
import '../entities/produit_entity.dart';

abstract class ProduitRepository {
  Stream<List<ProductCategoryEntity>> watchCategories();

  Stream<List<ProduitEntity>> watchProduits();

  Future<ProduitEntity?> getProduit(String id);

  Future<ProductCategoryEntity?> getCategory(String id);

  Future<ProductCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  });

  Future<ProductCategoryEntity> updateCategory({
    required String establishmentId,
    required String id,
    required String name,
  });

  Future<void> deleteCategory({
    required String establishmentId,
    required String id,
  });

  Future<ProduitEntity> createProduit({
    required String establishmentId,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    int stock = 0,
  });

  Future<ProduitEntity> updateProduit({
    required String establishmentId,
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    int stock = 0,
  });

  Future<void> deleteProduit({
    required String establishmentId,
    required String id,
  });
}
