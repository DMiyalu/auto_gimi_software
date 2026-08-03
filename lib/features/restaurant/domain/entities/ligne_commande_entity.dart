class LigneCommandeEntity {
  const LigneCommandeEntity({
    required this.id,
    required this.commandeId,
    required this.produitId,
    required this.label,
    required this.quantity,
    required this.unitPrice,
    required this.lineAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String commandeId;
  final String produitId;
  final String label;
  final int quantity;
  final double unitPrice;
  final double lineAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
}
