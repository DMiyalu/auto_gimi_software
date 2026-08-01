import '../entities/client_entity.dart';

abstract class ClientRepository {
  Stream<List<ClientEntity>> watchClients();

  Stream<ClientEntity?> watchClient(String id);

  /// Recherche un client par numéro de téléphone (normalisé comme
  /// [createClient]) — `null` si aucun client actif ne correspond.
  Future<ClientEntity?> findByPhone(String phone);

  Future<ClientEntity> createClient({
    required String establishmentId,
    required String name,
    required String whatsappPhone,
  });
}
