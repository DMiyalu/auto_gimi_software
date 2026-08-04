import '../entities/commande_entity.dart';
import '../entities/ligne_commande_entity.dart';

abstract class CommandeRepository {
  Stream<List<CommandeEntity>> watchCommandes({
    required String establishmentId,
  });

  Stream<CommandeEntity?> watchCommande({
    required String establishmentId,
    required String id,
  });

  Stream<List<LigneCommandeEntity>> watchLignes({
    required String establishmentId,
    required String commandeId,
  });

  Future<CommandeEntity> createCommande({
    required String establishmentId,
    String? clientId,
    String? context,
  });

  Future<void> addProduitLine({
    required String establishmentId,
    required String commandeId,
    required String produitId,
    int quantity = 1,
  });

  Future<void> removeLine({
    required String establishmentId,
    required String lineId,
  });

  Future<void> decrementLine({
    required String establishmentId,
    required String lineId,
  });

  Future<void> cancelCommande({
    required String establishmentId,
    required String commandeId,
  });

  Future<void> setStatus({
    required String establishmentId,
    required String commandeId,
    required String statusKey,
  });
}
