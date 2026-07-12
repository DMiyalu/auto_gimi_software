import '../entities/catalog_service_entity.dart';
import '../entities/service_category_entity.dart';

abstract class ServiceRepository {
  Stream<List<ServiceCategoryEntity>> watchCategories();

  Stream<List<CatalogServiceEntity>> watchServices();

  Future<ServiceCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  });

  Future<CatalogServiceEntity> createService({
    required String establishmentId,
    required String categoryId,
    required String name,
    required double price,
    required int intervalDays,
  });
}
