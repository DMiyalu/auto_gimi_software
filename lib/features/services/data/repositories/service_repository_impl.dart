import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/app_currency.dart';
import '../../domain/entities/catalog_service_entity.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<List<ServiceCategoryEntity>> watchCategories({
    required String establishmentId,
  }) {
    final query = _database.select(_database.categories)
      ..where(
        (c) =>
            c.establishmentId.equals(establishmentId) &
            c.isDeleted.equals(false),
      )
      ..orderBy([
        (c) => OrderingTerm.asc(c.ordre),
        (c) => OrderingTerm.asc(c.nom),
      ]);

    return query.watch().map((rows) => rows.map(_categoryFromDrift).toList());
  }

  @override
  Stream<List<CatalogServiceEntity>> watchServices({
    required String establishmentId,
  }) {
    final query =
        _database.select(_database.catalogServices).join([
            leftOuterJoin(
              _database.categories,
              _database.categories.id.equalsExp(
                    _database.catalogServices.categorieId,
                  ) &
                  _database.categories.establishmentId.equals(establishmentId) &
                  _database.categories.isDeleted.equals(false),
            ),
          ])
          ..where(
            _database.catalogServices.establishmentId.equals(establishmentId) &
                _database.catalogServices.isDeleted.equals(false),
          )
          ..orderBy([OrderingTerm.asc(_database.catalogServices.nom)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final service = row.readTable(_database.catalogServices);
        final category = row.readTableOrNull(_database.categories);
        return _serviceFromDrift(service, category?.nom);
      }).toList();
    });
  }

  @override
  Future<CatalogServiceEntity?> getService({
    required String establishmentId,
    required String id,
  }) async {
    final query =
        _database.select(_database.catalogServices).join([
          leftOuterJoin(
            _database.categories,
            _database.categories.id.equalsExp(
                  _database.catalogServices.categorieId,
                ) &
                _database.categories.establishmentId.equals(establishmentId) &
                _database.categories.isDeleted.equals(false),
          ),
        ])..where(
          _database.catalogServices.establishmentId.equals(establishmentId) &
              _database.catalogServices.id.equals(id) &
              _database.catalogServices.isDeleted.equals(false),
        );

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final service = row.readTable(_database.catalogServices);
    final category = row.readTableOrNull(_database.categories);
    return _serviceFromDrift(service, category?.nom);
  }

  @override
  Future<ServiceCategoryEntity?> getCategory({
    required String establishmentId,
    required String id,
  }) async {
    final query = _database.select(_database.categories)
      ..where(
        (c) =>
            c.establishmentId.equals(establishmentId) &
            c.id.equals(id) &
            c.isDeleted.equals(false),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _categoryFromDrift(row);
  }

  @override
  Future<ServiceCategoryEntity> createCategory({
    required String establishmentId,
    required String name,
  }) async {
    final trimmedName = _requireName(name, 'catégorie');
    final maxOrder = await _maxCategoryOrder(establishmentId);
    final id = _uuid.v4();
    final now = DateTime.now();
    final order = maxOrder + 1;

    await _database
        .into(_database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            establishmentId: Value(establishmentId),
            nom: trimmedName,
            ordre: Value(order),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return ServiceCategoryEntity(
      id: id,
      name: trimmedName,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<ServiceCategoryEntity> updateCategory({
    required String establishmentId,
    required String id,
    required String name,
  }) async {
    final trimmedName = _requireName(name, 'catégorie');
    final existing = await getCategory(
      establishmentId: establishmentId,
      id: id,
    );
    if (existing == null) throw StateError('Catégorie introuvable.');

    final now = DateTime.now();
    await (_database.update(_database.categories)..where(
          (c) => c.establishmentId.equals(establishmentId) & c.id.equals(id),
        ))
        .write(
          CategoriesCompanion(
            nom: Value(trimmedName),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );

    return ServiceCategoryEntity(
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
      await (_database.update(_database.catalogServices)..where(
            (s) =>
                s.establishmentId.equals(establishmentId) &
                s.categorieId.equals(id),
          ))
          .write(
            CatalogServicesCompanion(
              categorieId: const Value(null),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );

      await (_database.update(_database.categories)..where(
            (c) => c.establishmentId.equals(establishmentId) & c.id.equals(id),
          ))
          .write(
            CategoriesCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
    });
  }

  @override
  Future<CatalogServiceEntity> createService({
    required String establishmentId,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    required int intervalDays,
  }) async {
    final trimmedName = _requireName(name, 'service');
    _requirePrice(price);
    _requireInterval(intervalDays);
    final categoryName = await _resolveCategoryName(
      establishmentId,
      categoryId,
    );

    final id = _uuid.v4();
    final now = DateTime.now();

    await _database
        .into(_database.catalogServices)
        .insert(
          CatalogServicesCompanion.insert(
            id: id,
            establishmentId: Value(establishmentId),
            categorieId: Value(categoryId),
            nom: trimmedName,
            prix: price,
            devise: Value(currency.code),
            intervalleJours: Value(intervalDays),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return CatalogServiceEntity(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      name: trimmedName,
      price: price,
      currency: currency,
      intervalDays: intervalDays,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<CatalogServiceEntity> updateService({
    required String establishmentId,
    required String id,
    String? categoryId,
    required String name,
    required double price,
    required AppCurrency currency,
    required int intervalDays,
  }) async {
    final trimmedName = _requireName(name, 'service');
    _requirePrice(price);
    _requireInterval(intervalDays);
    final existing = await getService(establishmentId: establishmentId, id: id);
    if (existing == null) throw StateError('Service introuvable.');
    final categoryName = await _resolveCategoryName(
      establishmentId,
      categoryId,
    );
    final now = DateTime.now();

    await (_database.update(_database.catalogServices)..where(
          (s) => s.establishmentId.equals(establishmentId) & s.id.equals(id),
        ))
        .write(
          CatalogServicesCompanion(
            categorieId: Value(categoryId),
            nom: Value(trimmedName),
            prix: Value(price),
            devise: Value(currency.code),
            intervalleJours: Value(intervalDays),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );

    return CatalogServiceEntity(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      name: trimmedName,
      price: price,
      currency: currency,
      intervalDays: intervalDays,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteService({
    required String establishmentId,
    required String id,
  }) async {
    final now = DateTime.now();
    await (_database.update(_database.catalogServices)..where(
          (s) => s.establishmentId.equals(establishmentId) & s.id.equals(id),
        ))
        .write(
          CatalogServicesCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
  }

  Future<int> _maxCategoryOrder(String establishmentId) async {
    final maxRow =
        await (_database.selectOnly(_database.categories)
              ..addColumns([_database.categories.ordre.max()])
              ..where(
                _database.categories.establishmentId.equals(establishmentId) &
                    _database.categories.isDeleted.equals(false),
              ))
            .getSingleOrNull();
    return maxRow?.read(_database.categories.ordre.max()) ?? -1;
  }

  Future<String?> _resolveCategoryName(
    String establishmentId,
    String? categoryId,
  ) async {
    if (categoryId == null) return null;
    final category = await getCategory(
      establishmentId: establishmentId,
      id: categoryId,
    );
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

  void _requireInterval(int intervalDays) {
    if (intervalDays < 0) {
      throw ArgumentError("L'intervalle d'entretien ne peut pas être négatif.");
    }
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

  CatalogServiceEntity _serviceFromDrift(
    CatalogService row,
    String? categoryName,
  ) {
    return CatalogServiceEntity(
      id: row.id,
      categoryId: row.categorieId,
      categoryName: categoryName,
      name: row.nom,
      price: row.prix,
      currency: AppCurrency.fromCode(row.devise),
      intervalDays: row.intervalleJours,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
