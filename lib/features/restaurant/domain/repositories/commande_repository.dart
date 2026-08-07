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

  /// Transition en_cours → à_payer, déclenchée par l'impression de la
  /// facture. Idempotent si déjà à_payer ; échoue si clôturée ou annulée.
  Future<void> markAwaitingPayment({
    required String establishmentId,
    required String commandeId,
  });

  /// Transition (en_cours ou à_payer) → clôturée, déclenchée par
  /// l'encaissement du paiement (avec ou sans facture imprimée au
  /// préalable). Idempotent si déjà clôturée ; échoue si annulée.
  Future<void> registerPayment({
    required String establishmentId,
    required String commandeId,
  });

  Future<void> attachClient({
    required String establishmentId,
    required String commandeId,
    required String clientId,
  });

  Future<void> detachClient({
    required String establishmentId,
    required String commandeId,
  });
}
