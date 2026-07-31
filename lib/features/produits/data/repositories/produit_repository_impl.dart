import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/app_currency.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/produit_entity.dart';
import '../../domain/repositories/produit_repository.dart';

class ProduitRepositoryImpl implements ProduitRepository {
  ProduitRepositoryImpl({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;
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
      leftOuterJoin(
        _database.productCategories,
        _database.productCategories.id.equalsExp(
              _database.produits.categorieId,
            ) &
            _database.productCategories.isDeleted.equals(false),
      ),
    ])
      ..where(_database.produits.isDeleted.equals(false))
      ..orderBy([OrderingTerm.asc(_database.produits.nom)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final produit = row.readTable(_database.produits);
        final category = row.readTableOrNull(_database.productCategories);
        return _produitFromDrift(produit, category?.nom);
      }).toList();
    });
  }

  @override
  Future<ProduitEntity?> getProduit(String id) async {
    final query = _database.select(_database.produits).join([
      leftOuterJoin(
        _database.productCategories,
        _database.productCategories.id.equalsExp(
              _database.produits.categorieId,
            ) &
            _database.productCategories.isDeleted.equals(false),
      ),
    ])
      ..where(
        _database.produits.id.equals(id) &
            _database.produits.isDeleted.equals(false),
      );

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final produit = row.readTable(_database.produits);
    final category = row.readTableOrNull(_database.productCategories);
    return _produitFromDrift(produit, category?.nom);
  }

  @override
  Future<ProductCategoryEntity?> getCategory(String id) async {
    final query = _database.select(_database.productCategories)
      ..where((c) => c.id.equals(id) & c.isDeleted.equals(false));
    final row = await query.getSingleOrNull();
    return row == null ? null : _categoryFromDrift(row);
  }

  @override
  Future<ProductCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  }) async {
    final trimmedName = _requireName(name, 'catégorie');
    final maxOrder = await _maxCategoryOrder();
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

    return ProductCategoryEntity(
      id: id,
      name: trimmedName,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<ProductCategoryEntity> updateCategory({
    required String establishmentId,
    required String id,
    required String name,
  }) async {
    final trimmedName = _requireName(name, 'catégorie');
    final existing = await getCategory(id);
    if (existing == null) throw StateError('Catégorie introuvable.');

    final now = DateTime.now();
    await (_database.update(_database.productCategories)
          ..where((c) => c.id.equals(id)))
        .write(
      ProductCategoriesCompanion(
        nom: Value(trimmedName),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );

    return ProductCategoryEntity(
      id: id,
      name: trimmedName,
      order: existing.order,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteCategory({
    required String establishmentId,
    required String id,
  }) async {
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(_database.produits)
            ..where((p) => p.categorieId.equals(id)))
          .write(
        ProduitsCompanion(
          categorieId: const Value(null),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );

      await (_database.update(_database.productCategories)
            ..where((c) => c.id.equals(id)))
          .write(
        ProductCategoriesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<ProduitEntity> createProduit({
    required String establishmentId,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
  }) async {
    final trimmedName = _requireName(name, 'produit');
    _requirePrice(price);
    final categoryName = await _resolveCategoryName(categoryId);

    final id = _uuid.v4();
    final now = DateTime.now();

    await _database.into(_database.produits).insert(
          ProduitsCompanion.insert(
            id: id,
            categorieId: Value(categoryId),
            nom: trimmedName,
            prix: price,
            devise: Value(currency.code),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return ProduitEntity(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      name: trimmedName,
      price: price,
      currency: currency,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<ProduitEntity> updateProduit({
    required String establishmentId,
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
  }) async {
    final trimmedName = _requireName(name, 'produit');
    _requirePrice(price);
    final existing = await getProduit(id);
    if (existing == null) throw StateError('Produit introuvable.');
    final categoryName = await _resolveCategoryName(categoryId);
    final now = DateTime.now();

    await (_database.update(_database.produits)..where((p) => p.id.equals(id)))
        .write(
      ProduitsCompanion(
        categorieId: Value(categoryId),
        nom: Value(trimmedName),
        prix: Value(price),
        devise: Value(currency.code),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );

    return ProduitEntity(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      name: trimmedName,
      price: price,
      currency: currency,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteProduit({
    required String establishmentId,
    required String id,
  }) async {
    final now = DateTime.now();
    await (_database.update(_database.produits)..where((p) => p.id.equals(id)))
        .write(
      ProduitsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  Future<int> _maxCategoryOrder() async {
    final maxRow = await (_database.selectOnly(_database.productCategories)
          ..addColumns([_database.productCategories.ordre.max()])
          ..where(_database.productCategories.isDeleted.equals(false)))
        .getSingleOrNull();
    return maxRow?.read(_database.productCategories.ordre.max()) ?? -1;
  }

  Future<String?> _resolveCategoryName(String? categoryId) async {
    if (categoryId == null) return null;
    final category = await getCategory(categoryId);
    if (category == null) throw StateError('Catégorie introuvable.');
    return category.name;
  }

  String _requireName(String name, String label) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Le nom du $label est requis.');
    }
    return trimmed;
  }

  void _requirePrice(double price) {
    if (price < 0) {
      throw ArgumentError('Le prix ne peut pas être négatif.');
    }
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

  ProduitEntity _produitFromDrift(Produit row, String? categoryName) {
    return ProduitEntity(
      id: row.id,
      categoryId: row.categorieId,
      categoryName: categoryName,
      name: row.nom,
      price: row.prix,
      currency: AppCurrency.fromCode(row.devise),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
