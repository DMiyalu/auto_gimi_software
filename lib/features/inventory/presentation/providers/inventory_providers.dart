import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/inventory_line_entity.dart';
import '../../domain/entities/inventory_session_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(database: ref.watch(databaseProvider));
});

final inventoriesProvider = StreamProvider<List<InventorySessionEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref
      .watch(inventoryRepositoryProvider)
      .watchInventories(establishmentId: establishment.id);
});

final inventoryProvider =
    StreamProvider.family<InventorySessionEntity?, String>((ref, id) {
      final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
      if (establishment == null) return Stream.value(null);
      return ref
          .watch(inventoryRepositoryProvider)
          .watchInventory(establishmentId: establishment.id, id: id);
    });

final inventoryLinesProvider =
    StreamProvider.family<List<InventoryLineEntity>, String>((
      ref,
      inventoryId,
    ) {
      final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
      if (establishment == null) return Stream.value([]);
      return ref
          .watch(inventoryRepositoryProvider)
          .watchLines(
            establishmentId: establishment.id,
            inventoryId: inventoryId,
          );
    });

final inventoryControllerProvider =
    AsyncNotifierProvider<InventoryController, void>(InventoryController.new);

class InventoryController extends AsyncNotifier<void> {
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

  Future<InventorySessionEntity?> createInventory() async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    InventorySessionEntity? created;
    state = await AsyncValue.guard(() async {
      created = await ref
          .read(inventoryRepositoryProvider)
          .createInventory(establishmentId: establishmentId);
      _schedulePush();
    });
    return created;
  }

  Future<void> setCountedStock({
    required String lineId,
    required int countedStock,
  }) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .setCountedStock(
            establishmentId: establishmentId,
            lineId: lineId,
            countedStock: countedStock,
          );
      _schedulePush();
    });
  }

  Future<void> closeInventory({required String inventoryId}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .closeInventory(
            establishmentId: establishmentId,
            inventoryId: inventoryId,
          );
      _schedulePush();
    });
  }

  Future<void> cancelInventory({required String inventoryId}) async {
    final establishmentId = _establishmentId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .cancelInventory(
            establishmentId: establishmentId,
            inventoryId: inventoryId,
          );
      _schedulePush();
    });
  }
}
