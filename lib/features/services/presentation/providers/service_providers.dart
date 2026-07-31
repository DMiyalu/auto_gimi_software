import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/app_currency.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/entities/catalog_service_entity.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/repositories/service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepositoryImpl(database: ref.watch(databaseProvider));
});

final serviceCategoriesProvider =
    StreamProvider<List<ServiceCategoryEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref.watch(serviceRepositoryProvider).watchCategories();
});

final catalogServicesProvider =
    StreamProvider<List<CatalogServiceEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref.watch(serviceRepositoryProvider).watchServices();
});

final serviceByIdProvider =
    FutureProvider.family<CatalogServiceEntity?, String>((ref, id) {
  return ref.watch(serviceRepositoryProvider).getService(id);
});

final serviceCategoryByIdProvider =
    FutureProvider.family<ServiceCategoryEntity?, String>((ref, id) {
  return ref.watch(serviceRepositoryProvider).getCategory(id);
});

final serviceControllerProvider =
    AsyncNotifierProvider<ServiceController, void>(ServiceController.new);

class ServiceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  String get _establishmentId {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }
    return establishment.id;
  }

  void _schedulePush() {
    ref.read(autoSyncCoordinatorProvider).schedulePush();
  }

  Future<void> createCategory({required String name}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).createCategory(
            establishmentId: establishmentId,
            name: name,
          );
      _schedulePush();
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).updateCategory(
            establishmentId: establishmentId,
            id: id,
            name: name,
          );
      _schedulePush();
    });
  }

  Future<void> deleteCategory({required String id}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).deleteCategory(
            establishmentId: establishmentId,
            id: id,
          );
      _schedulePush();
    });
  }

  Future<void> createService({
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    required int intervalDays,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).createService(
            establishmentId: establishmentId,
            categoryId: categoryId,
            name: name,
            price: price,
            currency: currency,
            intervalDays: intervalDays,
          );
      _schedulePush();
    });
  }

  Future<void> updateService({
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    required int intervalDays,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).updateService(
            establishmentId: establishmentId,
            id: id,
            categoryId: categoryId,
            name: name,
            price: price,
            currency: currency,
            intervalDays: intervalDays,
          );
      _schedulePush();
    });
  }

  Future<void> deleteService({required String id}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).deleteService(
            establishmentId: establishmentId,
            id: id,
          );
      _schedulePush();
    });
  }
}
