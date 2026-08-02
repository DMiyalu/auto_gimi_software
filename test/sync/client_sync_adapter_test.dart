import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/sync/sync_registry.dart';

const _establishmentId = 'est-1';

void main() {
  late AppDatabase database;
  late FakeFirebaseFirestore firestore;
  late ClientSyncAdapter adapter;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    adapter = ClientSyncAdapter();
  });

  tearDown(() async {
    await database.close();
  });

  CollectionReference<Map<String, dynamic>> clientsCollection() => firestore
      .collection('establishments')
      .doc(_establishmentId)
      .collection('clients');

  test('loadDirtyDocs ne retourne que les lignes isDirty, avec le bon mapping de champs', () async {
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Amadou Diallo',
            pointsFidelite: const Value(3),
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 2),
          ),
        );
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c2',
            phone: '221779999999',
            nom: 'Déjà synchronisé',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isDirty: const Value(false),
          ),
        );

    final docs = await adapter.loadDirtyDocs(database, limit: 10);

    expect(docs.keys, ['c1']);
    expect(docs['c1'], {
      'name': 'Amadou Diallo',
      'phone': '221771234567',
      'email': null,
      'address': null,
      'clientType': 'particulier',
      'notes': null,
      'loyaltyPoints': 3,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'isDeleted': false,
    });
  });

  test('loadDirtyDocs inclut le profil étendu (email, adresse, type, notes)',
      () async {
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Amadou Diallo',
            email: const Value('amadou@example.com'),
            adresse: const Value('12 rue de la Paix, Dakar'),
            typeClient: const Value('entreprise'),
            notes: const Value('Client fidèle, préfère le paiement mobile.'),
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 2),
          ),
        );

    final docs = await adapter.loadDirtyDocs(database, limit: 10);

    expect(docs['c1']?['email'], 'amadou@example.com');
    expect(docs['c1']?['address'], '12 rue de la Paix, Dakar');
    expect(docs['c1']?['clientType'], 'entreprise');
    expect(
      docs['c1']?['notes'],
      'Client fidèle, préfère le paiement mobile.',
    );
  });

  test('applyRemoteDocs restaure le profil étendu depuis Firestore', () async {
    await clientsCollection().doc('remote-1').set({
      'name': 'Client distant',
      'phone': '221770000000',
      'email': 'distant@example.com',
      'address': 'Avenue de la Paix, Gombe',
      'clientType': 'entreprise',
      'notes': 'Facture mensuelle.',
      'loyaltyPoints': 5,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'isDeleted': false,
    });
    final snapshot = await clientsCollection().get();

    await adapter.applyRemoteDocs(database, snapshot.docs);

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('remote-1')))
        .getSingle();
    expect(row.email, 'distant@example.com');
    expect(row.adresse, 'Avenue de la Paix, Gombe');
    expect(row.typeClient, 'entreprise');
    expect(row.notes, 'Facture mensuelle.');
  });

  test('clearDirty marque les lignes comme synchronisées', () async {
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Amadou Diallo',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

    await adapter.clearDirty(database, ['c1']);

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('c1')))
        .getSingle();
    expect(row.isDirty, isFalse);
  });

  test('applyRemoteDocs peuple une ligne absente en local (nouvel appareil)', () async {
    await clientsCollection().doc('remote-1').set({
      'name': 'Client distant',
      'phone': '221770000000',
      'loyaltyPoints': 5,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'isDeleted': false,
    });
    final snapshot = await clientsCollection().get();

    final maxSeen = await adapter.applyRemoteDocs(database, snapshot.docs);

    expect(maxSeen, DateTime(2026, 1, 2));
    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('remote-1')))
        .getSingle();
    expect(row.nom, 'Client distant');
    expect(row.pointsFidelite, 5);
    expect(row.isDirty, isFalse);
  });

  test(
      'applyRemoteDocs conserve une ligne locale isDirty dont updatedAt >= au distant',
      () async {
    final now = DateTime(2026, 1, 5);
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Version locale en attente',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await clientsCollection().doc('c1').set({
      'name': 'Version distante concurrente',
      'phone': '221779999999',
      'loyaltyPoints': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'isDeleted': false,
    });
    final snapshot = await clientsCollection().get();

    await adapter.applyRemoteDocs(database, snapshot.docs);

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('c1')))
        .getSingle();
    expect(row.nom, 'Version locale en attente');
    expect(row.isDirty, isTrue);
  });

  test('applyRemoteDocs écrase une ligne locale dont le distant est plus récent',
      () async {
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Version locale obsolète',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isDirty: const Value(false),
          ),
        );

    await clientsCollection().doc('c1').set({
      'name': 'Version distante plus récente',
      'phone': '221779999999',
      'loyaltyPoints': 2,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 5)),
      'isDeleted': false,
    });
    final snapshot = await clientsCollection().get();

    await adapter.applyRemoteDocs(database, snapshot.docs);

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('c1')))
        .getSingle();
    expect(row.nom, 'Version distante plus récente');
    expect(row.pointsFidelite, 2);
  });

  test('applyRemoteDocs propage une suppression distante (soft delete)', () async {
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Client actif',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isDirty: const Value(false),
          ),
        );

    await clientsCollection().doc('c1').set({
      'name': 'Client actif',
      'phone': '221771234567',
      'loyaltyPoints': 0,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 3)),
      'isDeleted': true,
    });
    final snapshot = await clientsCollection().get();

    await adapter.applyRemoteDocs(database, snapshot.docs);

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('c1')))
        .getSingle();
    expect(row.isDeleted, isTrue);
  });
}
