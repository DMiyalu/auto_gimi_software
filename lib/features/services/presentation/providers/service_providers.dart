import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/entities/catalog_service_entity.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/repositories/service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepositoryImpl(
    database: ref.watch(databaseProvider),
    firestore: isFirebaseConfigured ? FirebaseFirestore.instance : null,
  );
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

final serviceControllerProvider =
    AsyncNotifierProvider<ServiceController, void>(ServiceController.new);

class ServiceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCategory({required String name}) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).createCategory(
            establishmentId: establishment.id,
            name: name,
          );
    });
  }

  Future<void> createService({
    required String categoryId,
    required String name,
    required double price,
    required int intervalDays,
  }) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(serviceRepositoryProvider).createService(
            establishmentId: establishment.id,
            categoryId: categoryId,
            name: name,
            price: price,
            intervalDays: intervalDays,
          );
    });
  }
}
