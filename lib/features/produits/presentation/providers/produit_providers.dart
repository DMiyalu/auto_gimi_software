import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/app_currency.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/produit_repository_impl.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/produit_entity.dart';
import '../../domain/repositories/produit_repository.dart';

final produitRepositoryProvider = Provider<ProduitRepository>((ref) {
  return ProduitRepositoryImpl(database: ref.watch(databaseProvider));
});

final productCategoriesProvider = StreamProvider<List<ProductCategoryEntity>>((
  ref,
) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref
      .watch(produitRepositoryProvider)
      .watchCategories(establishmentId: establishment.id);
});

final produitsProvider = StreamProvider<List<ProduitEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref
      .watch(produitRepositoryProvider)
      .watchProduits(establishmentId: establishment.id);
});

final produitByIdProvider = FutureProvider.family<ProduitEntity?, String>((
  ref,
  id,
) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return null;
  return ref
      .watch(produitRepositoryProvider)
      .getProduit(establishmentId: establishment.id, id: id);
});

/// Valeur sentinelle de [produitFilterProvider] représentant le filtre
/// "En rupture" — les autres valeurs sont soit `null` ("Tous"), soit un id
/// de catégorie réel, un ensemble dynamique qu'un enum fixe ne peut pas
/// représenter (contrairement aux filtres de l'écran Clients).
const produitOutOfStockFilterValue = '__out_of_stock__';

final produitSearchQueryProvider = StateProvider<String>((ref) => '');

final produitFilterProvider = StateProvider<String?>((ref) => null);

final productCategoryByIdProvider =
    FutureProvider.family<ProductCategoryEntity?, String>((ref, id) {
      final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
      if (establishment == null) return null;
      return ref
          .watch(produitRepositoryProvider)
          .getCategory(establishmentId: establishment.id, id: id);
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

  void _schedulePush() {
    ref.read(autoSyncCoordinatorProvider).schedulePush();
  }

  void _ensureCanManageCatalog() {
    if (!ref.read(canManageCatalogProvider)) {
      throw StateError(
        'Seuls le propriétaire et les gérants peuvent modifier le catalogue.',
      );
    }
  }

  Future<void> createCategory({required String name}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanManageCatalog();
      await ref
          .read(produitRepositoryProvider)
          .createCategory(establishmentId: establishmentId, name: name);
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
      _ensureCanManageCatalog();
      await ref
          .read(produitRepositoryProvider)
          .updateCategory(establishmentId: establishmentId, id: id, name: name);
      _schedulePush();
    });
  }

  Future<void> deleteCategory({required String id}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanManageCatalog();
      await ref
          .read(produitRepositoryProvider)
          .deleteCategory(establishmentId: establishmentId, id: id);
      _schedulePush();
    });
  }

  Future<void> createProduit({
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    int stock = 0,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanManageCatalog();
      await ref
          .read(produitRepositoryProvider)
          .createProduit(
            establishmentId: establishmentId,
            categoryId: categoryId,
            name: name,
            price: price,
            currency: currency,
            stock: stock,
          );
      _schedulePush();
    });
  }

  Future<void> updateProduit({
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    int stock = 0,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanManageCatalog();
      await ref
          .read(produitRepositoryProvider)
          .updateProduit(
            establishmentId: establishmentId,
            id: id,
            categoryId: categoryId,
            name: name,
            price: price,
            currency: currency,
            stock: stock,
          );
      _schedulePush();
    });
  }

  Future<void> deleteProduit({required String id}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanManageCatalog();
      await ref
          .read(produitRepositoryProvider)
          .deleteProduit(establishmentId: establishmentId, id: id);
      _schedulePush();
    });
  }
}
