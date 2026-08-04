import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/inventory_line_entity.dart';
import '../../domain/entities/inventory_session_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<List<InventorySessionEntity>> watchInventories({
    required String establishmentId,
  }) {
    final query = _database.select(_database.inventaires)
      ..where(
        (i) =>
            i.establishmentId.equals(establishmentId) &
            i.isDeleted.equals(false),
      )
      ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]);

    return query.watch().map((rows) => rows.map(_inventoryFromDrift).toList());
  }

  @override
  Stream<InventorySessionEntity?> watchInventory({
    required String establishmentId,
    required String id,
  }) {
    final query = _database.select(_database.inventaires)
      ..where(
        (i) =>
            i.establishmentId.equals(establishmentId) &
            i.id.equals(id) &
            i.isDeleted.equals(false),
      );

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _inventoryFromDrift(row),
    );
  }

  @override
  Stream<List<InventoryLineEntity>> watchLines({
    required String establishmentId,
    required String inventoryId,
  }) {
    final query = _database.select(_database.ligneInventaires)
      ..where(
        (l) =>
            l.establishmentId.equals(establishmentId) &
            l.inventaireId.equals(inventoryId) &
            l.isDeleted.equals(false),
      )
      ..orderBy([(l) => OrderingTerm.asc(l.libelle)]);

    return query.watch().map((rows) => rows.map(_lineFromDrift).toList());
  }

  @override
  Future<InventorySessionEntity> createInventory({
    required String establishmentId,
  }) async {
    final products =
        await (_database.select(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.isDeleted.equals(false) &
                  p.stockTrackingEnabled.equals(true),
            ))
            .get();
    if (products.isEmpty) {
      throw StateError('Aucun produit à inventorier.');
    }

    final now = DateTime.now();
    final inventoryId = _uuid.v4();
    final reference =
        'INV-${now.millisecondsSinceEpoch.toString().substring(6)}';

    await _database.transaction(() async {
      await _database
          .into(_database.inventaires)
          .insert(
            InventairesCompanion.insert(
              id: inventoryId,
              establishmentId: Value(establishmentId),
              reference: reference,
              startedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (final product in products) {
        await _database
            .into(_database.ligneInventaires)
            .insert(
              LigneInventairesCompanion.insert(
                id: _uuid.v4(),
                establishmentId: Value(establishmentId),
                inventaireId: inventoryId,
                produitId: product.id,
                libelle: product.nom,
                stockTheorique: product.stock,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });

    return InventorySessionEntity(
      id: inventoryId,
      reference: reference,
      status: InventoryStatus.draft,
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> setCountedStock({
    required String establishmentId,
    required String lineId,
    required int countedStock,
  }) async {
    if (countedStock < 0) {
      throw ArgumentError('Le stock compté ne peut pas être négatif.');
    }

    final line = await _requireLine(establishmentId, lineId);
    await _requireDraftInventory(establishmentId, line.inventaireId);

    final now = DateTime.now();
    await (_database.update(_database.ligneInventaires)..where(
          (l) =>
              l.establishmentId.equals(establishmentId) & l.id.equals(lineId),
        ))
        .write(
          LigneInventairesCompanion(
            stockCompte: Value(countedStock),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
  }

  @override
  Future<void> closeInventory({
    required String establishmentId,
    required String inventoryId,
  }) async {
    await _requireDraftInventory(establishmentId, inventoryId);

    final lines =
        await (_database.select(_database.ligneInventaires)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.inventaireId.equals(inventoryId) &
                  l.isDeleted.equals(false),
            ))
            .get();
    if (lines.isEmpty) throw StateError('Inventaire vide.');
    if (lines.any((line) => line.stockCompte == null)) {
      throw StateError('Toutes les lignes doivent être comptées.');
    }

    final now = DateTime.now();
    await _database.transaction(() async {
      for (final line in lines) {
        await (_database.update(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(line.produitId) &
                  p.isDeleted.equals(false),
            ))
            .write(
              ProduitsCompanion(
                stock: Value(line.stockCompte!),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      }

      await (_database.update(_database.inventaires)..where(
            (i) =>
                i.establishmentId.equals(establishmentId) &
                i.id.equals(inventoryId),
          ))
          .write(
            InventairesCompanion(
              statut: Value(InventoryStatus.closed.value),
              closedAt: Value(now),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
    });
  }

  @override
  Future<void> cancelInventory({
    required String establishmentId,
    required String inventoryId,
  }) async {
    await _requireDraftInventory(establishmentId, inventoryId);
    final now = DateTime.now();

    await (_database.update(_database.inventaires)..where(
          (i) =>
              i.establishmentId.equals(establishmentId) &
              i.id.equals(inventoryId),
        ))
        .write(
          InventairesCompanion(
            statut: Value(InventoryStatus.canceled.value),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
  }

  Future<Inventaire> _requireDraftInventory(
    String establishmentId,
    String inventoryId,
  ) async {
    final inventory =
        await (_database.select(_database.inventaires)..where(
              (i) =>
                  i.establishmentId.equals(establishmentId) &
                  i.id.equals(inventoryId) &
                  i.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (inventory == null) throw StateError('Inventaire introuvable.');
    if (inventory.statut != InventoryStatus.draft.value) {
      throw StateError("L'inventaire n'est plus modifiable.");
    }
    return inventory;
  }

  Future<LigneInventaire> _requireLine(
    String establishmentId,
    String lineId,
  ) async {
    final line =
        await (_database.select(_database.ligneInventaires)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.id.equals(lineId) &
                  l.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (line == null) throw StateError("Ligne d'inventaire introuvable.");
    return line;
  }

  InventorySessionEntity _inventoryFromDrift(Inventaire row) {
    return InventorySessionEntity(
      id: row.id,
      reference: row.reference,
      status: InventoryStatus.fromValue(row.statut),
      startedAt: row.startedAt,
      closedAt: row.closedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  InventoryLineEntity _lineFromDrift(LigneInventaire row) {
    return InventoryLineEntity(
      id: row.id,
      inventoryId: row.inventaireId,
      productId: row.produitId,
      label: row.libelle,
      expectedStock: row.stockTheorique,
      countedStock: row.stockCompte,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
