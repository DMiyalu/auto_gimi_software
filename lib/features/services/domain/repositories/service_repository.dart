import '../../../../core/domain/app_currency.dart';
import '../entities/catalog_service_entity.dart';
import '../entities/service_category_entity.dart';

abstract class ServiceRepository {
  Stream<List<ServiceCategoryEntity>> watchCategories({
    required String establishmentId,
  });

  Stream<List<CatalogServiceEntity>> watchServices({
    required String establishmentId,
  });

  Future<CatalogServiceEntity?> getService({
    required String establishmentId,
    required String id,
  });

  Future<ServiceCategoryEntity?> getCategory({
    required String establishmentId,
    required String id,
  });

  Future<ServiceCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  });

  Future<ServiceCategoryEntity> updateCategory({
    required String establishmentId,
    required String id,
    required String name,
  });

  Future<void> deleteCategory({
    required String establishmentId,
    required String id,
  });

  Future<CatalogServiceEntity> createService({
    required String establishmentId,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    required int intervalDays,
  });

  Future<CatalogServiceEntity> updateService({
    required String establishmentId,
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    required int intervalDays,
  });

  Future<void> deleteService({
    required String establishmentId,
    required String id,
  });
}
