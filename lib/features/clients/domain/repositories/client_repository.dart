import '../../../../core/domain/client_type.dart';
import '../entities/client_entity.dart';

abstract class ClientRepository {
  Stream<List<ClientEntity>> watchClients({required String establishmentId});

  Stream<ClientEntity?> watchClient({
    required String establishmentId,
    required String id,
  });

  /// Recherche un client par numéro de téléphone (normalisé comme
  /// [createClient]) — `null` si aucun client actif ne correspond.
  Future<ClientEntity?> findByPhone({
    required String establishmentId,
    required String phone,
  });

  Future<ClientEntity> createClient({
    required String establishmentId,
    required String name,
    required String whatsappPhone,
    String? email,
    String? address,
    ClientType clientType,
    String? notes,
  });

  Future<ClientEntity> updateClient({
    required String id,
    required String name,
    required String whatsappPhone,
    String? email,
    String? address,
    ClientType clientType,
    String? notes,
  });
}
