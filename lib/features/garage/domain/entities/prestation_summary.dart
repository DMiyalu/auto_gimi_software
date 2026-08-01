import '../../../../core/domain/enums.dart';

/// Vue résumée d'une prestation pour l'affichage en liste (accueil) —
/// évite de multiplier les abonnements par prestation pour résoudre le
/// véhicule/client associés.
class PrestationSummary {
  const PrestationSummary({
    required this.id,
    required this.statut,
    required this.dateOuverture,
    required this.montantTotal,
    required this.vehiculeDisplayName,
    required this.immatriculation,
    this.clientName,
  });

  final String id;
  final PrestationStatut statut;
  final DateTime dateOuverture;
  final double montantTotal;
  final String vehiculeDisplayName;
  final String immatriculation;
  final String? clientName;
}
