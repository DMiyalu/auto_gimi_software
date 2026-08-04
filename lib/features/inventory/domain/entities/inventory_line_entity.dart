class InventoryLineEntity {
  const InventoryLineEntity({
    required this.id,
    required this.inventoryId,
    required this.productId,
    required this.label,
    required this.expectedStock,
    this.countedStock,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String inventoryId;
  final String productId;
  final String label;
  final int expectedStock;
  final int? countedStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get variance =>
      countedStock == null ? null : countedStock! - expectedStock;

  bool get isCounted => countedStock != null;
}
