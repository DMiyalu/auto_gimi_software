import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<List<ClientEntity>> watchClients() {
    final query = _database.select(_database.clients)
      ..where((client) => client.isDeleted.equals(false))
      ..orderBy([(client) => OrderingTerm.asc(client.nom)]);

    return query.watch().map((rows) => rows.map(_fromDrift).toList());
  }

  @override
  Stream<ClientEntity?> watchClient(String id) {
    final query = _database.select(_database.clients)
      ..where((client) => client.id.equals(id) & client.isDeleted.equals(false));
    return query.watchSingleOrNull().map(
          (row) => row == null ? null : _fromDrift(row),
        );
  }

  @override
  Future<ClientEntity?> findByPhone(String phone) async {
    final normalized = PhoneAuthMapper.normalize(phone);
    final query = _database.select(_database.clients)
      ..where(
        (client) =>
            client.phone.equals(normalized) & client.isDeleted.equals(false),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _fromDrift(row);
  }

  @override
  Future<ClientEntity> createClient({
    required String establishmentId,
    required String name,
    required String whatsappPhone,
  }) async {
    final trimmedName = name.trim();
    final phone = PhoneAuthMapper.normalize(whatsappPhone);

    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom du client est requis.');
    }
    if (!PhoneAuthMapper.isValidFullNumber(phone)) {
      throw ArgumentError('Numéro WhatsApp invalide.');
    }

    final duplicateQuery = _database.select(_database.clients)
      ..where(
        (client) =>
            client.phone.equals(phone) & client.isDeleted.equals(false),
      );
    final duplicate = await duplicateQuery.getSingleOrNull();
    if (duplicate != null) {
      throw StateError('Un client avec ce numéro WhatsApp existe déjà.');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    await _database.into(_database.clients).insert(
          ClientsCompanion.insert(
            id: id,
            phone: phone,
            nom: trimmedName,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return ClientEntity(
      id: id,
      name: trimmedName,
      whatsappPhone: phone,
      loyaltyPoints: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  ClientEntity _fromDrift(Client row) {
    return ClientEntity(
      id: row.id,
      name: row.nom,
      whatsappPhone: row.phone,
      loyaltyPoints: row.pointsFidelite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
