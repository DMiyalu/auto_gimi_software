import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/produit_entity.dart';
import '../../domain/repositories/produit_repository.dart';

class ProduitRepositoryImpl implements ProduitRepository {
  ProduitRepositoryImpl({
    required AppDatabase database,
    FirebaseFirestore? firestore,
  })  : _database = database,
        _firestore = firestore;

  final AppDatabase _database;
  final FirebaseFirestore? _firestore;
  final _uuid = const Uuid();

  @override
  Stream<List<ProductCategoryEntity>> watchCategories() {
    final query = _database.select(_database.productCategories)
      ..where((c) => c.isDeleted.equals(false))
      ..orderBy([
        (c) => OrderingTerm.asc(c.ordre),
        (c) => OrderingTerm.asc(c.nom),
      ]);

    return query.watch().map((rows) => rows.map(_categoryFromDrift).toList());
  }

  @override
  Stream<List<ProduitEntity>> watchProduits() {
    final query = _database.select(_database.produits).join([
      innerJoin(
        _database.productCategories,
        _database.productCategories.id.equalsExp(
          _database.produits.categorieId,
        ),
      ),
    ])
      ..where(_database.produits.isDeleted.equals(false))
      ..where(_database.productCategories.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.asc(_database.productCategories.ordre),
        OrderingTerm.asc(_database.produits.nom),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final produit = row.readTable(_database.produits);
        final category = row.readTable(_database.productCategories);
        return ProduitEntity(
          id: produit.id,
          categoryId: produit.categorieId,
          categoryName: category.nom,
          name: produit.nom,
          price: produit.prix,
          createdAt: produit.createdAt,
          updatedAt: produit.updatedAt,
        );
      }).toList();
    });
  }

  @override
  Future<ProductCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom de la catégorie est requis.');
    }

    final maxRow = await (_database.selectOnly(_database.productCategories)
          ..addColumns([_database.productCategories.ordre.max()])
          ..where(_database.productCategories.isDeleted.equals(false)))
        .getSingleOrNull();
    final maxOrder =
        maxRow?.read(_database.productCategories.ordre.max()) ?? -1;

    final id = _uuid.v4();
    final now = DateTime.now();
    final order = maxOrder + 1;

    await _database.into(_database.productCategories).insert(
          ProductCategoriesCompanion.insert(
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
          .collection('product_categories')
          .doc(id)
          .set({
        'name': trimmedName,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
    }

    return ProductCategoryEntity(
      id: id,
      name: trimmedName,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<ProduitEntity> createProduit({
    required String establishmentId,
    required String categoryId,
    required String name,
    required double price,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom du produit est requis.');
    }
    if (price < 0) {
      throw ArgumentError('Le prix ne peut pas être négatif.');
    }

    final categoryQuery = _database.select(_database.productCategories)
      ..where(
        (c) => c.id.equals(categoryId) & c.isDeleted.equals(false),
      );
    final category = await categoryQuery.getSingleOrNull();
    if (category == null) {
      throw StateError('Catégorie introuvable.');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    await _database.into(_database.produits).insert(
          ProduitsCompanion.insert(
            id: id,
            categorieId: categoryId,
            nom: trimmedName,
            prix: price,
            createdAt: now,
            updatedAt: now,
          ),
        );

    final firestore = _firestore;
    if (isFirebaseConfigured && firestore != null) {
      await firestore
          .collection('establishments')
          .doc(establishmentId)
          .collection('produits')
          .doc(id)
          .set({
        'categoryId': categoryId,
        'name': trimmedName,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
    }

    return ProduitEntity(
      id: id,
      categoryId: categoryId,
      categoryName: category.nom,
      name: trimmedName,
      price: price,
      createdAt: now,
      updatedAt: now,
    );
  }

  ProductCategoryEntity _categoryFromDrift(ProductCategory row) {
    return ProductCategoryEntity(
      id: row.id,
      name: row.nom,
      order: row.ordre,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
