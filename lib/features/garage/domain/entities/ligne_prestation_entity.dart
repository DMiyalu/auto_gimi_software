import '../../../../core/domain/enums.dart';

/// Une ligne de travaux — un service du catalogue ou un produit en
/// magasin. [libelle] et [prixUnitaire] sont capturés au moment de l'ajout
/// et ne changent pas si le catalogue est modifié ensuite.
class LignePrestationEntity {
  const LignePrestationEntity({
    required this.id,
    required this.prestationId,
    required this.type,
    required this.libelle,
    required this.quantite,
    required this.prixUnitaire,
    required this.montantLigne,
    required this.createdAt,
    required this.updatedAt,
    this.serviceId,
    this.produitId,
  });

  final String id;
  final String prestationId;
  final LigneType type;
  final String? serviceId;
  final String? produitId;
  final String libelle;
  final int quantite;
  final double prixUnitaire;
  final double montantLigne;
  final DateTime createdAt;
  final DateTime updatedAt;
}
