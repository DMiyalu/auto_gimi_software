import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/app_currency.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/produit_repository_impl.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/produit_entity.dart';
import '../../domain/repositories/produit_repository.dart';

final produitRepositoryProvider = Provider<ProduitRepository>((ref) {
  return ProduitRepositoryImpl(
    database: ref.watch(databaseProvider),
    firestore: isFirebaseConfigured ? FirebaseFirestore.instance : null,
  );
});

final productCategoriesProvider =
    StreamProvider<List<ProductCategoryEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref.watch(produitRepositoryProvider).watchCategories();
});

final produitsProvider = StreamProvider<List<ProduitEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref.watch(produitRepositoryProvider).watchProduits();
});

final produitByIdProvider =
    FutureProvider.family<ProduitEntity?, String>((ref, id) {
  return ref.watch(produitRepositoryProvider).getProduit(id);
});

final productCategoryByIdProvider =
    FutureProvider.family<ProductCategoryEntity?, String>((ref, id) {
  return ref.watch(produitRepositoryProvider).getCategory(id);
});

final produitControllerProvider =
    AsyncNotifierProvider<ProduitController, void>(ProduitController.new);

class ProduitController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  String get _establishmentId {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }
    return establishment.id;
  }

  Future<void> createCategory({required String name}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).createCategory(
            establishmentId: establishmentId,
            name: name,
          );
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).updateCategory(
            establishmentId: establishmentId,
            id: id,
            name: name,
          );
    });
  }

  Future<void> deleteCategory({required String id}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).deleteCategory(
            establishmentId: establishmentId,
            id: id,
          );
    });
  }

  Future<void> createProduit({
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).createProduit(
            establishmentId: establishmentId,
            categoryId: categoryId,
            name: name,
            price: price,
            currency: currency,
          );
    });
  }

  Future<void> updateProduit({
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).updateProduit(
            establishmentId: establishmentId,
            id: id,
            categoryId: categoryId,
            name: name,
            price: price,
            currency: currency,
          );
    });
  }

  Future<void> deleteProduit({required String id}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).deleteProduit(
            establishmentId: establishmentId,
            id: id,
          );
    });
  }
}
