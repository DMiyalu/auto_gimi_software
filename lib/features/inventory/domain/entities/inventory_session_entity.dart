class InventorySessionEntity {
  const InventorySessionEntity({
    required this.id,
    required this.reference,
    required this.status,
    required this.startedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String reference;
  final InventoryStatus status;
  final DateTime startedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDraft => status == InventoryStatus.draft;
}

enum InventoryStatus {
  draft('brouillon', 'Brouillon'),
  closed('cloture', 'Clôturé'),
  canceled('annule', 'Annulé');

  const InventoryStatus(this.value, this.label);

  final String value;
  final String label;

  static InventoryStatus fromValue(String? value) {
    return InventoryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InventoryStatus.draft,
    );
  }
}
