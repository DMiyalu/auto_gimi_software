import '../entities/inventory_line_entity.dart';
import '../entities/inventory_session_entity.dart';

abstract class InventoryRepository {
  Stream<List<InventorySessionEntity>> watchInventories({
    required String establishmentId,
  });

  Stream<InventorySessionEntity?> watchInventory({
    required String establishmentId,
    required String id,
  });

  Stream<List<InventoryLineEntity>> watchLines({
    required String establishmentId,
    required String inventoryId,
  });

  Future<InventorySessionEntity> createInventory({
    required String establishmentId,
  });

  Future<void> setCountedStock({
    required String establishmentId,
    required String lineId,
    required int countedStock,
  });

  Future<void> closeInventory({
    required String establishmentId,
    required String inventoryId,
  });

  Future<void> cancelInventory({
    required String establishmentId,
    required String inventoryId,
  });
}
