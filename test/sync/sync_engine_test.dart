import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/sync/sync_engine.dart';

const _establishmentId = 'est-1';

void main() {
  late AppDatabase database;
  late FakeFirebaseFirestore firestore;
  late SyncEngine engine;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    engine = SyncEngine(database: database, firestore: firestore);
  });

  tearDown(() async {
    await database.close();
  });

  CollectionReference<Map<String, dynamic>> clientsCollection() => firestore
      .collection('establishments')
      .doc(_establishmentId)
      .collection('clients');

  test('runSync pousse les lignes locales isDirty vers Firestore', () async {
    await database.into(database.clients).insert(
          ClientsCompanion.insert(
            id: 'c1',
            phone: '221771234567',
            nom: 'Amadou Diallo',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

    await engine.runSync(establishmentId: _establishmentId);

    final doc = await clientsCollection().doc('c1').get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['name'], 'Amadou Diallo');

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('c1')))
        .getSingle();
    expect(row.isDirty, isFalse);
  });

  test(
      'runSync sur une base locale vide peuple tout depuis Firestore '
      '(reproduit le changement d\'appareil)', () async {
    await clientsCollection().doc('remote-1').set({
      'name': 'Client distant',
      'phone': '221770000000',
      'loyaltyPoints': 0,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'isDeleted': false,
    });

    await engine.runSync(establishmentId: _establishmentId);

    final rows = await database.select(database.clients).get();
    expect(rows, hasLength(1));
    expect(rows.single.nom, 'Client distant');
  });

  test('runSync est incrémental : un second appel sans changement ne casse rien',
      () async {
    await clientsCollection().doc('remote-1').set({
      'name': 'Client distant',
      'phone': '221770000000',
      'loyaltyPoints': 0,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'isDeleted': false,
    });

    await engine.runSync(establishmentId: _establishmentId);
    await engine.runSync(establishmentId: _establishmentId);

    final rows = await database.select(database.clients).get();
    expect(rows, hasLength(1));

    final syncState = await (database.select(database.syncState)
          ..where((t) => t.collection.equals('clients')))
        .getSingle();
    expect(syncState.lastSyncAt, DateTime(2026, 1, 1));
  });

  test('runSync propage une suppression distante lors d\'un cycle ultérieur',
      () async {
    await clientsCollection().doc('c1').set({
      'name': 'Client actif',
      'phone': '221770000000',
      'loyaltyPoints': 0,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'isDeleted': false,
    });
    await engine.runSync(establishmentId: _establishmentId);

    await clientsCollection().doc('c1').update({
      'isDeleted': true,
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
    });
    await engine.runSync(establishmentId: _establishmentId);

    final row = await (database.select(database.clients)
          ..where((t) => t.id.equals('c1')))
        .getSingle();
    expect(row.isDeleted, isTrue);
  });

  test('runSync ne lance pas deux cycles concurrents (single-flight)', () async {
    final first = engine.runSync(establishmentId: _establishmentId);
    final second = engine.runSync(establishmentId: _establishmentId);

    expect(identical(first, second), isTrue);
    await first;
  });

  test('runSync ne fait rien si Firebase n\'est pas configuré', () async {
    final offlineEngine = SyncEngine(database: database, firestore: null);

    await offlineEngine.runSync(establishmentId: _establishmentId);

    final rows = await database.select(database.clients).get();
    expect(rows, isEmpty);
  });
}
