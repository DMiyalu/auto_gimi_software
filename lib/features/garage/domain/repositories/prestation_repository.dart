import '../entities/ligne_prestation_entity.dart';
import '../entities/prestation_entity.dart';
import '../entities/prestation_summary.dart';
import '../entities/vehicule_entity.dart';

abstract class PrestationRepository {
  Stream<PrestationEntity?> watchPrestation(String id);
  Stream<VehiculeEntity?> watchVehicule(String id);
  Stream<List<LignePrestationEntity>> watchLignes(String prestationId);

  /// Prestations non supprimées, véhicule/client déjà résolus, triées de
  /// la plus récente à la plus ancienne — alimente la liste d'accueil.
  Stream<List<PrestationSummary>> watchPrestationsSummary();

  /// Point d'entrée unique de création : cherche un véhicule existant par
  /// immatriculation (et réutilise son client s'il en a un), sinon crée un
  /// véhicule minimal (immatriculation seule). Crée ensuite une nouvelle
  /// prestation ouverte pour ce véhicule.
  Future<PrestationEntity> createPrestationForImmatriculation({
    required String establishmentId,
    required String immatriculation,
  });

  Future<void> addServiceLine({
    required String establishmentId,
    required String prestationId,
    required String serviceId,
  });

  Future<void> addProduitLine({
    required String establishmentId,
    required String prestationId,
    required String produitId,
  });

  Future<void> removeLine({
    required String establishmentId,
    required String ligneId,
  });

  /// Rattache un client à la prestation — met aussi à jour le véhicule pour
  /// que les prochaines prestations le retrouvent automatiquement.
  Future<void> attachClient({
    required String establishmentId,
    required String prestationId,
    required String clientId,
  });

  /// Détache le client de cette prestation uniquement (le véhicule garde
  /// son dernier client connu) — permet de corriger un rattachement erroné
  /// sans perdre l'historique du véhicule.
  Future<void> detachClient({
    required String establishmentId,
    required String prestationId,
  });
}
