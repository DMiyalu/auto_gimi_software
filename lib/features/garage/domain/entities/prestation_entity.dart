import '../../../../core/domain/enums.dart';

/// Prestation (ordre de travail) ouverte pour un véhicule — le client peut
/// être rattaché plus tard.
class PrestationEntity {
  const PrestationEntity({
    required this.id,
    required this.vehiculeId,
    this.clientId,
    required this.statut,
    required this.dateOuverture,
    this.dateCloture,
    required this.montantTotal,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String vehiculeId;
  final String? clientId;
  final PrestationStatut statut;
  final DateTime dateOuverture;
  final DateTime? dateCloture;
  final double montantTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
}
