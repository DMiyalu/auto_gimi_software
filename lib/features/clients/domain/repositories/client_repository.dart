import '../entities/client_entity.dart';

abstract class ClientRepository {
  Stream<List<ClientEntity>> watchClients();

  Future<ClientEntity> createClient({
    required String establishmentId,
    required String name,
    required String whatsappPhone,
  });
}
