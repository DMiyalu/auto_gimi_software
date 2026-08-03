import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../domain/enums.dart';
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
  VehiculeSyncAdapter(),
  PrestationSyncAdapter(),
  LignePrestationSyncAdapter(),
];

class ClientSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'clients';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.clients)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
              ..limit(limit))
            .get();
    return {
      for (final row in rows)
        row.id: {
          'name': row.nom,
          'phone': row.phone,
          'email': row.email,
          'address': row.adresse,
          'clientType': row.typeClient,
          'notes': row.notes,
          'loyaltyPoints': row.pointsFidelite,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.clients)..where((t) => t.id.isIn(ids.toList()))).write(
      const ClientsCompanion(isDirty: Value(false)),
    );
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    String establishmentId,
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

        final existing =
            await (db.select(db.clients)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.clients)
            .insertOnConflictUpdate(
              ClientsCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
                nom: Value(data['name'] as String? ?? ''),
                phone: Value(data['phone'] as String? ?? ''),
                email: Value(data['email'] as String?),
                adresse: Value(data['address'] as String?),
                typeClient: Value(
                  data['clientType'] as String? ?? 'particulier',
                ),
                notes: Value(data['notes'] as String?),
                pointsFidelite: Value(
                  (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
                ),
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
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.productCategories)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
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
    String establishmentId,
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

        final existing =
            await (db.select(db.productCategories)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.productCategories)
            .insertOnConflictUpdate(
              ProductCategoriesCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
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
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.categories)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
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
    String establishmentId,
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

        final existing =
            await (db.select(db.categories)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.categories)
            .insertOnConflictUpdate(
              CategoriesCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
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
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.produits)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
              ..limit(limit))
            .get();
    return {
      for (final row in rows)
        row.id: {
          'categoryId': row.categorieId,
          'name': row.nom,
          'price': row.prix,
          'currency': row.devise,
          'stock': row.stock,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.produits)..where((t) => t.id.isIn(ids.toList()))).write(
      const ProduitsCompanion(isDirty: Value(false)),
    );
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    String establishmentId,
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

        final existing =
            await (db.select(db.produits)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.produits)
            .insertOnConflictUpdate(
              ProduitsCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
                categorieId: Value(data['categoryId'] as String?),
                nom: Value(data['name'] as String? ?? ''),
                prix: Value((data['price'] as num?)?.toDouble() ?? 0),
                devise: Value(data['currency'] as String? ?? 'USD'),
                stock: Value((data['stock'] as num?)?.toInt() ?? 0),
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
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.catalogServices)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
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
    await (db.update(db.catalogServices)..where((t) => t.id.isIn(ids.toList())))
        .write(const CatalogServicesCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    String establishmentId,
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

        final existing =
            await (db.select(db.catalogServices)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.catalogServices)
            .insertOnConflictUpdate(
              CatalogServicesCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
                categorieId: Value(data['categoryId'] as String?),
                nom: Value(data['name'] as String? ?? ''),
                prix: Value((data['price'] as num?)?.toDouble() ?? 0),
                devise: Value(data['currency'] as String? ?? 'USD'),
                intervalleJours: Value(
                  (data['intervalDays'] as num?)?.toInt() ?? 0,
                ),
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

class VehiculeSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'vehicules';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.vehicules)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
              ..limit(limit))
            .get();
    return {
      for (final row in rows)
        row.id: {
          'clientId': row.clientId,
          'immatriculation': row.immatriculation,
          'marque': row.marque,
          'modele': row.modele,
          'annee': row.annee,
          'kilometrage': row.kilometrage,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.vehicules)..where((t) => t.id.isIn(ids.toList())))
        .write(const VehiculesCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    String establishmentId,
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

        final existing =
            await (db.select(db.vehicules)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.vehicules)
            .insertOnConflictUpdate(
              VehiculesCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
                clientId: Value(data['clientId'] as String?),
                immatriculation: Value(
                  data['immatriculation'] as String? ?? '',
                ),
                marque: Value(data['marque'] as String?),
                modele: Value(data['modele'] as String?),
                annee: Value((data['annee'] as num?)?.toInt()),
                kilometrage: Value((data['kilometrage'] as num?)?.toInt()),
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

class PrestationSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'prestations';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.prestations)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
              ..limit(limit))
            .get();
    return {
      for (final row in rows)
        row.id: {
          'clientId': row.clientId,
          'vehiculeId': row.vehiculeId,
          'statut': row.statut.name,
          'dateOuverture': Timestamp.fromDate(row.dateOuverture),
          'dateCloture': row.dateCloture == null
              ? null
              : Timestamp.fromDate(row.dateCloture!),
          'montantTotal': row.montantTotal,
          'montantPointsDeduit': row.montantPointsDeduit,
          'pointsUtilises': row.pointsUtilises,
          'pointsGagnes': row.pointsGagnes,
          'kilometrage': row.kilometrage,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.prestations)..where((t) => t.id.isIn(ids.toList())))
        .write(const PrestationsCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    String establishmentId,
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

        final existing =
            await (db.select(db.prestations)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        final remoteDateOuverture = readFirestoreDate(data['dateOuverture']);

        await db
            .into(db.prestations)
            .insertOnConflictUpdate(
              PrestationsCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
                clientId: Value(data['clientId'] as String?),
                vehiculeId: Value(data['vehiculeId'] as String? ?? ''),
                statut: Value(
                  PrestationStatut.values.byName(
                    data['statut'] as String? ?? 'ouverte',
                  ),
                ),
                dateOuverture: Value(remoteDateOuverture ?? remoteUpdatedAt),
                dateCloture: Value(readFirestoreDate(data['dateCloture'])),
                montantTotal: Value(
                  (data['montantTotal'] as num?)?.toDouble() ?? 0,
                ),
                montantPointsDeduit: Value(
                  (data['montantPointsDeduit'] as num?)?.toDouble() ?? 0,
                ),
                pointsUtilises: Value(
                  (data['pointsUtilises'] as num?)?.toInt() ?? 0,
                ),
                pointsGagnes: Value(
                  (data['pointsGagnes'] as num?)?.toInt() ?? 0,
                ),
                kilometrage: Value((data['kilometrage'] as num?)?.toInt()),
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

class LignePrestationSyncAdapter implements SyncAdapter {
  @override
  String get firestoreCollection => 'ligne_prestations';

  @override
  Future<Map<String, Map<String, dynamic>>> loadDirtyDocs(
    AppDatabase db, {
    required String establishmentId,
    required int limit,
  }) async {
    final rows =
        await (db.select(db.lignePrestations)
              ..where(
                (t) =>
                    t.establishmentId.equals(establishmentId) &
                    t.isDirty.equals(true),
              )
              ..limit(limit))
            .get();
    return {
      for (final row in rows)
        row.id: {
          'prestationId': row.prestationId,
          'type': row.type.name,
          'serviceId': row.serviceId,
          'produitId': row.produitId,
          'libelle': row.libelle,
          'quantite': row.quantite,
          'prixUnitaire': row.prixUnitaire,
          'montantLigne': row.montantLigne,
          'createdAt': Timestamp.fromDate(row.createdAt),
          'updatedAt': Timestamp.fromDate(row.updatedAt),
          'isDeleted': row.isDeleted,
        },
    };
  }

  @override
  Future<void> clearDirty(AppDatabase db, Iterable<String> ids) async {
    await (db.update(db.lignePrestations)
          ..where((t) => t.id.isIn(ids.toList())))
        .write(const LignePrestationsCompanion(isDirty: Value(false)));
  }

  @override
  Future<DateTime?> applyRemoteDocs(
    AppDatabase db,
    String establishmentId,
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

        final existing =
            await (db.select(db.lignePrestations)..where(
                  (t) =>
                      t.establishmentId.equals(establishmentId) &
                      t.id.equals(doc.id),
                ))
                .getSingleOrNull();
        if (existing != null &&
            existing.isDirty &&
            !existing.updatedAt.isBefore(remoteUpdatedAt)) {
          continue;
        }

        await db
            .into(db.lignePrestations)
            .insertOnConflictUpdate(
              LignePrestationsCompanion(
                id: Value(doc.id),
                establishmentId: Value(establishmentId),
                prestationId: Value(data['prestationId'] as String? ?? ''),
                type: Value(
                  LigneType.values.byName(data['type'] as String? ?? 'service'),
                ),
                serviceId: Value(data['serviceId'] as String?),
                produitId: Value(data['produitId'] as String?),
                libelle: Value(data['libelle'] as String? ?? ''),
                quantite: Value((data['quantite'] as num?)?.toInt() ?? 1),
                prixUnitaire: Value(
                  (data['prixUnitaire'] as num?)?.toDouble() ?? 0,
                ),
                montantLigne: Value(
                  (data['montantLigne'] as num?)?.toDouble() ?? 0,
                ),
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
