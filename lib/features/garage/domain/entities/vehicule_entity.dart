/// Véhicule d'un client — peut exister sans client rattaché (créé avec la
/// seule immatriculation lors de l'ouverture d'une prestation).
class VehiculeEntity {
  const VehiculeEntity({
    required this.id,
    required this.immatriculation,
    this.clientId,
    this.marque,
    this.modele,
    this.annee,
    this.kilometrage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? clientId;
  final String immatriculation;
  final String? marque;
  final String? modele;
  final int? annee;
  final int? kilometrage;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Marque + modèle si connus, sinon l'immatriculation.
  String get displayName {
    if (marque != null && modele != null) return '$marque $modele';
    return immatriculation;
  }
}
