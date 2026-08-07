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
  late CommandeSyncAdapter adapter;
  late LigneCommandeSyncAdapter ligneAdapter;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    adapter = CommandeSyncAdapter();
    ligneAdapter = LigneCommandeSyncAdapter();
  });

  tearDown(() async {
    await database.close();
  });

  CollectionReference<Map<String, dynamic>> commandesCollection() => firestore
      .collection('establishments')
      .doc(_establishmentId)
      .collection('commandes');

  CollectionReference<Map<String, dynamic>> ligneCommandesCollection() =>
      firestore
          .collection('establishments')
          .doc(_establishmentId)
          .collection('ligne_commandes');

  test(
    'loadDirtyDocs ne retourne que les commandes isDirty, avec le bon mapping',
    () async {
      await database
          .into(database.commandes)
          .insert(
            CommandesCompanion.insert(
              id: 'cmd1',
              establishmentId: const Value(_establishmentId),
              reference: 'CMD-1',
              statut: const Value('a_payer'),
              contexte: const Value('Table 4'),
              montantTotal: const Value(42.5),
              createdAt: DateTime(2026, 1, 1),
              updatedAt: DateTime(2026, 1, 2),
            ),
          );
      await database
          .into(database.commandes)
          .insert(
            CommandesCompanion.insert(
              id: 'cmd2',
              establishmentId: const Value(_establishmentId),
              reference: 'CMD-2',
              createdAt: DateTime(2026, 1, 1),
              updatedAt: DateTime(2026, 1, 1),
              isDirty: const Value(false),
            ),
          );

      final docs = await adapter.loadDirtyDocs(
        database,
        establishmentId: _establishmentId,
        limit: 10,
      );

      expect(docs.keys, ['cmd1']);
      expect(docs['cmd1'], {
        'clientId': null,
        'reference': 'CMD-1',
        'statut': 'a_payer',
        'context': 'Table 4',
        'montantTotal': 42.5,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
        'isDeleted': false,
      });
    },
  );

  test(
    'un changement de statut (registerPayment) remet la commande isDirty '
    'pour re-synchronisation',
    () async {
      final now = DateTime(2026, 1, 1);
      await database
          .into(database.commandes)
          .insert(
            CommandesCompanion.insert(
              id: 'cmd1',
              establishmentId: const Value(_establishmentId),
              reference: 'CMD-1',
              statut: const Value('en_cours'),
              createdAt: now,
              updatedAt: now,
              isDirty: const Value(false),
            ),
          );

      await (database.update(database.commandes)
            ..where((t) => t.id.equals('cmd1')))
          .write(
        CommandesCompanion(
          statut: const Value('cloturee'),
          updatedAt: Value(DateTime(2026, 1, 3)),
          isDirty: const Value(true),
        ),
      );

      final docs = await adapter.loadDirtyDocs(
        database,
        establishmentId: _establishmentId,
        limit: 10,
      );

      expect(docs.keys, ['cmd1']);
      expect(docs['cmd1']?['statut'], 'cloturee');
    },
  );

  test('clearDirty marque les commandes comme synchronisées', () async {
    await database
        .into(database.commandes)
        .insert(
          CommandesCompanion.insert(
            id: 'cmd1',
            establishmentId: const Value(_establishmentId),
            reference: 'CMD-1',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

    await adapter.clearDirty(database, ['cmd1']);

    final row = await (database.select(
      database.commandes,
    )..where((t) => t.id.equals('cmd1'))).getSingle();
    expect(row.isDirty, isFalse);
  });

  test(
    'applyRemoteDocs peuple une commande absente en local (nouvel appareil)',
    () async {
      await commandesCollection().doc('remote-1').set({
        'clientId': null,
        'reference': 'CMD-9',
        'statut': 'a_payer',
        'context': 'Table 2',
        'montantTotal': 15.0,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
        'isDeleted': false,
      });
      final snapshot = await commandesCollection().get();

      final maxSeen = await adapter.applyRemoteDocs(
        database,
        _establishmentId,
        snapshot.docs,
      );

      expect(maxSeen, DateTime(2026, 1, 2));
      final row = await (database.select(
        database.commandes,
      )..where((t) => t.id.equals('remote-1'))).getSingle();
      expect(row.reference, 'CMD-9');
      expect(row.statut, 'a_payer');
      expect(row.montantTotal, 15.0);
      expect(row.isDirty, isFalse);
    },
  );

  test(
    'applyRemoteDocs conserve une commande locale isDirty plus récente '
    '(conflit résolu en faveur du plus récent updatedAt)',
    () async {
      final now = DateTime(2026, 1, 5);
      await database
          .into(database.commandes)
          .insert(
            CommandesCompanion.insert(
              id: 'cmd1',
              establishmentId: const Value(_establishmentId),
              reference: 'CMD-1',
              statut: const Value('cloturee'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await commandesCollection().doc('cmd1').set({
        'reference': 'CMD-1',
        'statut': 'en_cours',
        'montantTotal': 0.0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'isDeleted': false,
      });
      final snapshot = await commandesCollection().get();

      await adapter.applyRemoteDocs(database, _establishmentId, snapshot.docs);

      final row = await (database.select(
        database.commandes,
      )..where((t) => t.id.equals('cmd1'))).getSingle();
      expect(row.statut, 'cloturee');
      expect(row.isDirty, isTrue);
    },
  );

  test('LigneCommandeSyncAdapter : mapping et cycle complet', () async {
    await database
        .into(database.commandes)
        .insert(
          CommandesCompanion.insert(
            id: 'cmd1',
            establishmentId: const Value(_establishmentId),
            reference: 'CMD-1',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );
    await database
        .into(database.produits)
        .insert(
          ProduitsCompanion.insert(
            id: 'prod1',
            establishmentId: const Value(_establishmentId),
            nom: 'Poulet braisé',
            prix: 10,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );
    await database
        .into(database.ligneCommandes)
        .insert(
          LigneCommandesCompanion.insert(
            id: 'ligne1',
            establishmentId: const Value(_establishmentId),
            commandeId: 'cmd1',
            produitId: 'prod1',
            libelle: 'Poulet braisé',
            quantite: const Value(2),
            prixUnitaire: 10,
            montantLigne: 20,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 2),
          ),
        );

    final docs = await ligneAdapter.loadDirtyDocs(
      database,
      establishmentId: _establishmentId,
      limit: 10,
    );
    expect(docs['ligne1'], {
      'commandeId': 'cmd1',
      'produitId': 'prod1',
      'libelle': 'Poulet braisé',
      'quantite': 2,
      'prixUnitaire': 10.0,
      'montantLigne': 20.0,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'isDeleted': false,
    });

    await ligneAdapter.clearDirty(database, ['ligne1']);
    final synced = await (database.select(
      database.ligneCommandes,
    )..where((t) => t.id.equals('ligne1'))).getSingle();
    expect(synced.isDirty, isFalse);

    await ligneCommandesCollection().doc('remote-ligne').set({
      'commandeId': 'cmd1',
      'produitId': 'prod1',
      'libelle': 'Jus de gingembre',
      'quantite': 1,
      'prixUnitaire': 4.0,
      'montantLigne': 4.0,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 3)),
      'isDeleted': false,
    });
    final remoteSnapshot = await ligneCommandesCollection().get();
    await ligneAdapter.applyRemoteDocs(
      database,
      _establishmentId,
      remoteSnapshot.docs,
    );

    final remoteRow = await (database.select(
      database.ligneCommandes,
    )..where((t) => t.id.equals('remote-ligne'))).getSingle();
    expect(remoteRow.libelle, 'Jus de gingembre');
    expect(remoteRow.montantLigne, 4.0);
  });
}
