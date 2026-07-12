import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final produitControllerProvider =
    AsyncNotifierProvider<ProduitController, void>(ProduitController.new);

class ProduitController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCategory({required String name}) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).createCategory(
            establishmentId: establishment.id,
            name: name,
          );
    });
  }

  Future<void> createProduit({
    required String categoryId,
    required String name,
    required double price,
  }) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(produitRepositoryProvider).createProduit(
            establishmentId: establishment.id,
            categoryId: categoryId,
            name: name,
            price: price,
          );
    });
  }
}
