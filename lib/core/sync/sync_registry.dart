import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'sync_adapter.dart';

/// Adaptateurs pour les collections déjà exposées par un repository.
/// Ajouter une future table (véhicules, prestations…) = ajouter une entrée
/// ici, sans toucher à `SyncEngine`.
final List<SyncAdapter> defaultSyncAdapters = [
  ClientSyncAdapter(),
  ProductCategorySyncAdapter(),
  ProduitSyncAdapter(),
  CategorySyncAdapter(),
  CatalogServiceSyncAdapter(),
];

class ClientSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'clients';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required int limit,
  }) async {
    final rows = await (db.select(db.clients)
          ..where((t) => t.isDirty.equals(true))
          ..limit(limit))
        .get();
    return {
      for (final row in rows)
        row.id: {
          'name': row.nom,
          'phone': row.phone,
          'loyaltyPoints': row.pointsFidelite,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.clients)..where((t) => t.id.isIn(ids.toList())))
        .write(const ClientsCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    DateTime? maxSeen;
    await db.transaction(() async {
      for (final doc in docs) {
        final data = doc.data();
        final remoteUpdatedAt = readFirestoreDate(data['updatedAt']);
        if (remoteUpdatedAt == null) continue;
        if (maxSeen == null || remoteUpdatedAt.isAfter(maxSeen!)) {
          maxSeen = remoteUpdatedAt;
        }

        final existing = await (db.select(db.clients)
              ..where((t) => t.id.equals(doc.id)))
            .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db.into(db.clients).insertOnConflictUpdate(
              ClientsCompanion(
                id: Value(doc.id),
                nom: Value(data['name'] as String? ?? ''),
                phone: Value(data['phone'] as String? ?? ''),
                pointsFidelite:
                    Value((data['loyaltyPoints'] as num?)?.toInt() ?? 0),
                createdAt: Value(
                  readFirestoreDate(data['createdAt']) ?? remoteUpdatedAt,
                ),
                updatedAt: Value(remoteUpdatedAt),
                isDeleted: Value(data['isDeleted'] as bool? ?? false),
                isDirty: const Value(false),
              ),
            );
      }
    });
    return maxSeen;
  }
}

class ProductCategorySyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'product_categories';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required int limit,
  }) async {
    final rows = await (db.select(db.productCategories)
          ..where((t) => t.isDirty.equals(true))
          ..limit(limit))
        .get();
    return {
      for (final row in rows)
        row.id: {
          'name': row.nom,
          'order': row.ordre,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.productCategories)
          ..where((t) => t.id.isIn(ids.toList())))
        .write(const ProductCategoriesCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    DateTime? maxSeen;
    await db.transaction(() async {
      for (final doc in docs) {
        final data = doc.data();
        final remoteUpdatedAt = readFirestoreDate(data['updatedAt']);
        if (remoteUpdatedAt == null) continue;
        if (maxSeen == null || remoteUpdatedAt.isAfter(maxSeen!)) {
          maxSeen = remoteUpdatedAt;
        }

        final existing = await (db.select(db.productCategories)
              ..where((t) => t.id.equals(doc.id)))
            .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db.into(db.productCategories).insertOnConflictUpdate(
              ProductCategoriesCompanion(
                id: Value(doc.id),
                nom: Value(data['name'] as String? ?? ''),
                ordre: Value((data['order'] as num?)?.toInt() ?? 0),
                createdAt: Value(
                  readFirestoreDate(data['createdAt']) ?? remoteUpdatedAt,
                ),
                updatedAt: Value(remoteUpdatedAt),
                isDeleted: Value(data['isDeleted'] as bool? ?? false),
                isDirty: const Value(false),
              ),
            );
      }
    });
    return maxSeen;
  }
}

class CategorySyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'categories';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required int limit,
  }) async {
    final rows = await (db.select(db.categories)
          ..where((t) => t.isDirty.equals(true))
          ..limit(limit))
        .get();
    return {
      for (final row in rows)
        row.id: {
          'name': row.nom,
          'order': row.ordre,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.categories)..where((t) => t.id.isIn(ids.toList())))
        .write(const CategoriesCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    DateTime? maxSeen;
    await db.transaction(() async {
      for (final doc in docs) {
        final data = doc.data();
        final remoteUpdatedAt = readFirestoreDate(data['updatedAt']);
        if (remoteUpdatedAt == null) continue;
        if (maxSeen == null || remoteUpdatedAt.isAfter(maxSeen!)) {
          maxSeen = remoteUpdatedAt;
        }

        final existing = await (db.select(db.categories)
              ..where((t) => t.id.equals(doc.id)))
            .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db.into(db.categories).insertOnConflictUpdate(
              CategoriesCompanion(
                id: Value(doc.id),
                nom: Value(data['name'] as String? ?? ''),
                ordre: Value((data['order'] as num?)?.toInt() ?? 0),
                createdAt: Value(
                  readFirestoreDate(data['createdAt']) ?? remoteUpdatedAt,
                ),
                updatedAt: Value(remoteUpdatedAt),
                isDeleted: Value(data['isDeleted'] as bool? ?? false),
                isDirty: const Value(false),
              ),
            );
      }
    });
    return maxSeen;
  }
}

class ProduitSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'produits';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required int limit,
  }) async {
    final rows = await (db.select(db.produits)
          ..where((t) => t.isDirty.equals(true))
          ..limit(limit))
        .get();
    return {
      for (final row in rows)
        row.id: {
          'categoryId': row.categorieId,
          'name': row.nom,
          'price': row.prix,
          'currency': row.devise,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.produits)..where((t) => t.id.isIn(ids.toList())))
        .write(const ProduitsCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    DateTime? maxSeen;
    await db.transaction(() async {
      for (final doc in docs) {
        final data = doc.data();
        final remoteUpdatedAt = readFirestoreDate(data['updatedAt']);
        if (remoteUpdatedAt == null) continue;
        if (maxSeen == null || remoteUpdatedAt.isAfter(maxSeen!)) {
          maxSeen = remoteUpdatedAt;
        }

        final existing = await (db.select(db.produits)
              ..where((t) => t.id.equals(doc.id)))
            .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db.into(db.produits).insertOnConflictUpdate(
              ProduitsCompanion(
                id: Value(doc.id),
                categorieId: Value(data['categoryId'] as String?),
                nom: Value(data['name'] as String? ?? ''),
                prix: Value((data['price'] as num?)?.toDouble() ?? 0),
                devise: Value(data['currency'] as String? ?? 'USD'),
                createdAt: Value(
                  readFirestoreDate(data['createdAt']) ?? remoteUpdatedAt,
                ),
                updatedAt: Value(remoteUpdatedAt),
                isDeleted: Value(data['isDeleted'] as bool? ?? false),
                isDirty: const Value(false),
              ),
            );
      }
    });
    return maxSeen;
  }
}

class CatalogServiceSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'services';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required int limit,
  }) async {
    final rows = await (db.select(db.catalogServices)
          ..where((t) => t.isDirty.equals(true))
          ..limit(limit))
        .get();
    return {
      for (final row in rows)
        row.id: {
          'categoryId': row.categorieId,
          'name': row.nom,
          'price': row.prix,
          'currency': row.devise,
          'intervalDays': row.intervalleJours,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.catalogServices)
          ..where((t) => t.id.isIn(ids.toList())))
        .write(const CatalogServicesCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    DateTime? maxSeen;
    await db.transaction(() async {
      for (final doc in docs) {
        final data = doc.data();
        final remoteUpdatedAt = readFirestoreDate(data['updatedAt']);
        if (remoteUpdatedAt == null) continue;
        if (maxSeen == null || remoteUpdatedAt.isAfter(maxSeen!)) {
          maxSeen = remoteUpdatedAt;
        }

        final existing = await (db.select(db.catalogServices)
              ..where((t) => t.id.equals(doc.id)))
            .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db.into(db.catalogServices).insertOnConflictUpdate(
              CatalogServicesCompanion(
                id: Value(doc.id),
                categorieId: Value(data['categoryId'] as String?),
                nom: Value(data['name'] as String? ?? ''),
                prix: Value((data['price'] as num?)?.toDouble() ?? 0),
                devise: Value(data['currency'] as String? ?? 'USD'),
                intervalleJours:
                    Value((data['intervalDays'] as num?)?.toInt() ?? 0),
                createdAt: Value(
                  readFirestoreDate(data['createdAt']) ?? remoteUpdatedAt,
                ),
                updatedAt: Value(remoteUpdatedAt),
                isDeleted: Value(data['isDeleted'] as bool? ?? false),
                isDirty: const Value(false),
              ),
            );
      }
    });
    return maxSeen;
  }
}
