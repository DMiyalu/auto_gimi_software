import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../domain/entities/catalog_service_entity.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({
    required AppDatabase database,
    FirebaseFirestore? firestore,
  })  : _database = database,
        _firestore = firestore;

  final AppDatabase _database;
  final FirebaseFirestore? _firestore;
  final _uuid = const Uuid();

  @override
  Stream<List<ServiceCategoryEntity>> watchCategories() {
    final query = _database.select(_database.categories)
      ..where((c) => c.isDeleted.equals(false))
      ..orderBy([
        (c) => OrderingTerm.asc(c.ordre),
        (c) => OrderingTerm.asc(c.nom),
      ]);

    return query.watch().map((rows) => rows.map(_categoryFromDrift).toList());
  }

  @override
  Stream<List<CatalogServiceEntity>> watchServices() {
    final query = _database.select(_database.catalogServices).join([
      innerJoin(
        _database.categories,
        _database.categories.id.equalsExp(
          _database.catalogServices.categorieId,
        ),
      ),
    ])
      ..where(_database.catalogServices.isDeleted.equals(false))
      ..where(_database.categories.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.asc(_database.categories.ordre),
        OrderingTerm.asc(_database.catalogServices.nom),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final service = row.readTable(_database.catalogServices);
        final category = row.readTable(_database.categories);
        return CatalogServiceEntity(
          id: service.id,
          categoryId: service.categorieId,
          categoryName: category.nom,
          name: service.nom,
          price: service.prix,
          intervalDays: service.intervalleJours,
          createdAt: service.createdAt,
          updatedAt: service.updatedAt,
        );
      }).toList();
    });
  }

  @override
  Future<ServiceCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom de la catégorie est requis.');
    }

    final maxRow = await (_database.selectOnly(_database.categories)
          ..addColumns([_database.categories.ordre.max()])
          ..where(_database.categories.isDeleted.equals(false)))
        .getSingleOrNull();
    final maxOrder =
        maxRow?.read(_database.categories.ordre.max()) ?? -1;

    final id = _uuid.v4();
    final now = DateTime.now();
    final order = maxOrder + 1;

    await _database.into(_database.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            nom: trimmedName,
            ordre: Value(order),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final firestore = _firestore;
    if (isFirebaseConfigured && firestore != null) {
      await firestore
          .collection('establishments')
          .doc(establishmentId)
          .collection('categories')
          .doc(id)
          .set({
        'name': trimmedName,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
    }

    return ServiceCategoryEntity(
      id: id,
      name: trimmedName,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<CatalogServiceEntity> createService({
    required String establishmentId,
    required String categoryId,
    required String name,
    required double price,
    required int intervalDays,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom du service est requis.');
    }
    if (price < 0) {
      throw ArgumentError('Le prix ne peut pas être négatif.');
    }
    if (intervalDays < 0) {
      throw ArgumentError("L'intervalle d'entretien ne peut pas être négatif.");
    }

    final categoryQuery = _database.select(_database.categories)
      ..where(
        (c) => c.id.equals(categoryId) & c.isDeleted.equals(false),
      );
    final category = await categoryQuery.getSingleOrNull();
    if (category == null) {
      throw StateError('Catégorie introuvable.');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    await _database.into(_database.catalogServices).insert(
          CatalogServicesCompanion.insert(
            id: id,
            categorieId: categoryId,
            nom: trimmedName,
            prix: price,
            intervalleJours: Value(intervalDays),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final firestore = _firestore;
    if (isFirebaseConfigured && firestore != null) {
      await firestore
          .collection('establishments')
          .doc(establishmentId)
          .collection('services')
          .doc(id)
          .set({
        'categoryId': categoryId,
        'name': trimmedName,
        'price': price,
        'intervalDays': intervalDays,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
    }

    return CatalogServiceEntity(
      id: id,
      categoryId: categoryId,
      categoryName: category.nom,
      name: trimmedName,
      price: price,
      intervalDays: intervalDays,
      createdAt: now,
      updatedAt: now,
    );
  }

  ServiceCategoryEntity _categoryFromDrift(Category row) {
    return ServiceCategoryEntity(
      id: row.id,
      name: row.nom,
      order: row.ordre,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
