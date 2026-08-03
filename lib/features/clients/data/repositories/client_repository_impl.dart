import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/domain/client_type.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<List<ClientEntity>> watchClients({required String establishmentId}) {
    final query = _database.select(_database.clients)
      ..where(
        (client) =>
            client.establishmentId.equals(establishmentId) &
            client.isDeleted.equals(false),
      )
      ..orderBy([(client) => OrderingTerm.asc(client.nom)]);

    return query.watch().map((rows) => rows.map(_fromDrift).toList());
  }

  @override
  Stream<ClientEntity?> watchClient({
    required String establishmentId,
    required String id,
  }) {
    final query = _database.select(_database.clients)
      ..where(
        (client) =>
            client.establishmentId.equals(establishmentId) &
            client.id.equals(id) &
            client.isDeleted.equals(false),
      );
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _fromDrift(row),
    );
  }

  @override
  Future<ClientEntity?> findByPhone({
    required String establishmentId,
    required String phone,
  }) async {
    final normalized = PhoneAuthMapper.normalize(phone);
    final query = _database.select(_database.clients)
      ..where(
        (client) =>
            client.establishmentId.equals(establishmentId) &
            client.phone.equals(normalized) &
            client.isDeleted.equals(false),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _fromDrift(row);
  }

  @override
  Future<ClientEntity> createClient({
    required String establishmentId,
    required String name,
    required String whatsappPhone,
    String? email,
    String? address,
    ClientType clientType = ClientType.individual,
    String? notes,
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
            client.establishmentId.equals(establishmentId) &
            client.phone.equals(phone) &
            client.isDeleted.equals(false),
      );
    final duplicate = await duplicateQuery.getSingleOrNull();
    if (duplicate != null) {
      throw StateError('Un client avec ce numéro WhatsApp existe déjà.');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    await _database
        .into(_database.clients)
        .insert(
          ClientsCompanion.insert(
            id: id,
            establishmentId: Value(establishmentId),
            phone: phone,
            nom: trimmedName,
            email: Value(_blankToNull(email)),
            adresse: Value(_blankToNull(address)),
            typeClient: Value(clientType.code),
            notes: Value(_blankToNull(notes)),
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
      email: _blankToNull(email),
      address: _blankToNull(address),
      clientType: clientType,
      notes: _blankToNull(notes),
    );
  }

  @override
  Future<ClientEntity> updateClient({
    required String id,
    required String name,
    required String whatsappPhone,
    String? email,
    String? address,
    ClientType clientType = ClientType.individual,
    String? notes,
  }) async {
    final existing = await (_database.select(
      _database.clients,
    )..where((client) => client.id.equals(id))).getSingleOrNull();
    if (existing == null) throw StateError('Client introuvable.');
    final establishmentId = existing.establishmentId;
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
            client.establishmentId.equals(establishmentId) &
            client.phone.equals(phone) &
            client.isDeleted.equals(false) &
            client.id.equals(id).not(),
      );
    final duplicate = await duplicateQuery.getSingleOrNull();
    if (duplicate != null) {
      throw StateError('Un client avec ce numéro WhatsApp existe déjà.');
    }

    final now = DateTime.now();

    await (_database.update(_database.clients)..where(
          (client) =>
              client.establishmentId.equals(establishmentId) &
              client.id.equals(id),
        ))
        .write(
          ClientsCompanion(
            phone: Value(phone),
            nom: Value(trimmedName),
            email: Value(_blankToNull(email)),
            adresse: Value(_blankToNull(address)),
            typeClient: Value(clientType.code),
            notes: Value(_blankToNull(notes)),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );

    final row =
        await (_database.select(_database.clients)..where(
              (client) =>
                  client.establishmentId.equals(establishmentId) &
                  client.id.equals(id),
            ))
            .getSingle();
    return _fromDrift(row);
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  ClientEntity _fromDrift(Client row) {
    return ClientEntity(
      id: row.id,
      name: row.nom,
      whatsappPhone: row.phone,
      loyaltyPoints: row.pointsFidelite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      email: row.email,
      address: row.adresse,
      clientType: ClientType.fromCode(row.typeClient),
      notes: row.notes,
    );
  }
}
