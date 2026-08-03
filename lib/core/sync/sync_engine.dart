import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firebase_bootstrap.dart';
import '../providers/database_provider.dart';
import 'sync_adapter.dart';
import 'sync_registry.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    database: ref.watch(databaseProvider),
    firestore: isFirebaseConfigured ? FirebaseFirestore.instance : null,
  );
});

/// Synchronise la base locale (Drift) et Firestore sous
/// `establishments/{id}/...`, dans les deux sens :
/// - push des lignes locales `isDirty` par lots (une seule écriture réseau
///   par lot au lieu d'une par ligne),
/// - pull incrémental (`updatedAt` > dernier curseur connu), paginé pour
///   rester léger sur un lien faible.
///
/// Ne fait rien si Firebase n'est pas configuré. Un seul cycle de
/// synchronisation s'exécute à la fois (les appels concurrents attendent
/// celui déjà en cours) : les déclencheurs (connectivité, minuterie, retour
/// au premier plan, écriture locale…) vivent dans `AutoSyncCoordinator`.
class SyncEngine {
  SyncEngine({
    required AppDatabase database,
    required FirebaseFirestore? firestore,
    List<SyncAdapter>? adapters,
  }) : _database = database,
       _firestore = firestore,
       _adapters = adapters ?? defaultSyncAdapters;

  static const int _pushPageSize = 200;
  static const int _pullPageSize = 100;
  static const int _adapterConcurrency = 2;

  final AppDatabase _database;
  final FirebaseFirestore? _firestore;
  final List<SyncAdapter> _adapters;

  Future<void>? _inFlight;

  /// Pousse puis tire les changements de chaque collection pour
  /// [establishmentId]. Sans effet si une synchro est déjà en cours (renvoie
  /// le même Future) ou si Firebase n'est pas configuré.
  Future<void> runSync({required String establishmentId}) {
    final firestore = _firestore;
    if (firestore == null) return Future.value();

    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    final future = _run(firestore, establishmentId).whenComplete(() {
      _inFlight = null;
    });
    _inFlight = future;
    return future;
  }

  Future<void> _run(FirebaseFirestore firestore, String establishmentId) async {
    final establishmentRef = firestore
        .collection('establishments')
        .doc(establishmentId);

    for (final group in _chunked(_adapters, _adapterConcurrency)) {
      await Future.wait(
        group.map(
          (adapter) => _syncAdapter(establishmentId, establishmentRef, adapter),
        ),
      );
    }
  }

  Future<void> _syncAdapter(
    String establishmentId,
    DocumentReference<Map<String, dynamic>> establishmentRef,
    SyncAdapter adapter,
  ) async {
    await _pushAdapter(establishmentId, establishmentRef, adapter);
    await _pullAdapter(establishmentId, establishmentRef, adapter);
  }

  Future<void> _pushAdapter(
    String establishmentId,
    DocumentReference<Map<String, dynamic>> establishmentRef,
    SyncAdapter adapter,
  ) async {
    final collection = establishmentRef.collection(adapter.firestoreCollection);

    while (true) {
      final docs = await adapter.loadDirtyDocs(
        _database,
        establishmentId: establishmentId,
        limit: _pushPageSize,
      );
      if (docs.isEmpty) return;

      final batch = _firestore!.batch();
      for (final entry in docs.entries) {
        batch.set(
          collection.doc(entry.key),
          entry.value,
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      await adapter.clearDirty(_database, docs.keys);

      if (docs.length < _pushPageSize) return;
    }
  }

  Future<void> _pullAdapter(
    String establishmentId,
    DocumentReference<Map<String, dynamic>> establishmentRef,
    SyncAdapter adapter,
  ) async {
    final since = await _readLastSync(
      establishmentId,
      adapter.firestoreCollection,
    );
    Query<Map<String, dynamic>> query = establishmentRef
        .collection(adapter.firestoreCollection)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('updatedAt')
        .limit(_pullPageSize);

    DateTime? maxSeen;
    while (true) {
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) break;

      final pageMax = await adapter.applyRemoteDocs(
        _database,
        establishmentId,
        snapshot.docs,
      );
      if (pageMax != null && (maxSeen == null || pageMax.isAfter(maxSeen))) {
        maxSeen = pageMax;
      }

      if (snapshot.docs.length < _pullPageSize) break;
      query = query.startAfterDocument(snapshot.docs.last);
    }

    if (maxSeen != null) {
      await _writeLastSync(
        establishmentId,
        adapter.firestoreCollection,
        maxSeen,
      );
    }
  }

  String _syncStateKey(String establishmentId, String collection) =>
      '$establishmentId/$collection';

  Future<DateTime> _readLastSync(
    String establishmentId,
    String collection,
  ) async {
    final row =
        await (_database.select(_database.syncState)..where(
              (t) => t.collection.equals(
                _syncStateKey(establishmentId, collection),
              ),
            ))
            .getSingleOrNull();
    return row?.lastSyncAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _writeLastSync(
    String establishmentId,
    String collection,
    DateTime value,
  ) async {
    await _database
        .into(_database.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            collection: _syncStateKey(establishmentId, collection),
            lastSyncAt: value,
          ),
        );
  }
}

Iterable<List<T>> _chunked<T>(List<T> items, int size) sync* {
  for (var i = 0; i < items.length; i += size) {
    final end = i + size > items.length ? items.length : i + size;
    yield items.sublist(i, end);
  }
}
