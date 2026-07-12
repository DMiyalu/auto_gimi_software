import '../entities/product_category_entity.dart';
import '../entities/produit_entity.dart';

abstract class ProduitRepository {
  Stream<List<ProductCategoryEntity>> watchCategories();

  Stream<List<ProduitEntity>> watchProduits();

  Future<ProductCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  });

  Future<ProduitEntity> createProduit({
    required String establishmentId,
    required String categoryId,
    required String name,
    required double price,
  });
}
