import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/app_database.dart';

/// Contrat par table pour [SyncEngine] : traduit entre les lignes Drift
/// locales et les documents Firestore `establishments/{id}/{firestoreCollection}`.
/// L'orchestration (pagination, lots, retries) reste générique dans
/// `SyncEngine` ; seule la traduction typée des données vit ici.
abstract class SyncAdapter {
  /// Nom de la sous-collection sous `establishments/{id}/...`.
  String get firestoreCollection;

  /// Jusqu'à [limit] lignes locales marquées `isDirty`, sous forme
  /// `{ id du document Firestore -> données à écrire }`.
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required int limit,
  });

  /// Marque les lignes comme synchronisées après un push réussi.
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids);

  /// Applique des documents distants en local. Ne doit jamais écraser une
  /// ligne locale `isDirty` dont `updatedAt` est postérieur ou égal à celui
  /// du document distant (elle sera repoussée au prochain push).
  ///
  /// Retourne le plus grand `updatedAt` vu parmi [docs] (appliqué ou non),
  /// utilisé par `SyncEngine` pour avancer le curseur `sync_state` — ou
  /// `null` si aucun document n'avait de `updatedAt` exploitable.
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  );
}

/// Convertit un champ Firestore `updatedAt`/`createdAt` (Timestamp) en
/// [DateTime]. Retourne `null` si absent ou d'un type inattendu.
DateTime? readFirestoreDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
