import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/commande_entity.dart';
import '../../domain/entities/ligne_commande_entity.dart';
import '../../domain/repositories/commande_repository.dart';

class CommandeRepositoryImpl implements CommandeRepository {
  CommandeRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<List<CommandeEntity>> watchCommandes({
    required String establishmentId,
  }) {
    final query = _database.select(_database.commandes)
      ..where(
        (c) =>
            c.establishmentId.equals(establishmentId) &
            c.isDeleted.equals(false),
      )
      ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]);

    return query.watch().map((rows) => rows.map(_commandeFromDrift).toList());
  }

  @override
  Stream<CommandeEntity?> watchCommande({
    required String establishmentId,
    required String id,
  }) {
    final query = _database.select(_database.commandes)
      ..where(
        (c) =>
            c.establishmentId.equals(establishmentId) &
            c.id.equals(id) &
            c.isDeleted.equals(false),
      );

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _commandeFromDrift(row),
    );
  }

  @override
  Stream<List<LigneCommandeEntity>> watchLignes({
    required String establishmentId,
    required String commandeId,
  }) {
    final query = _database.select(_database.ligneCommandes)
      ..where(
        (l) =>
            l.establishmentId.equals(establishmentId) &
            l.commandeId.equals(commandeId) &
            l.isDeleted.equals(false),
      )
      ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]);

    return query.watch().map((rows) => rows.map(_ligneFromDrift).toList());
  }

  @override
  Future<CommandeEntity> createCommande({
    required String establishmentId,
    String? clientId,
    String? context,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final reference =
        'CMD-${now.millisecondsSinceEpoch.toString().substring(6)}';

    await _database
        .into(_database.commandes)
        .insert(
          CommandesCompanion.insert(
            id: id,
            establishmentId: Value(establishmentId),
            clientId: Value(clientId),
            reference: reference,
            contexte: Value(_blankToNull(context)),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return CommandeEntity(
      id: id,
      clientId: clientId,
      reference: reference,
      statusKey: 'en_attente',
      statusLabel: commandeStatusLabel('en_attente'),
      context: _blankToNull(context),
      totalAmount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> addProduitLine({
    required String establishmentId,
    required String commandeId,
    required String produitId,
    int quantity = 1,
  }) async {
    if (quantity <= 0) throw ArgumentError('La quantité doit être positive.');
    await _requireMutableCommande(establishmentId, commandeId);

    final produit =
        await (_database.select(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(produitId) &
                  p.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (produit == null) throw StateError('Produit introuvable.');
    if (produit.stockTrackingEnabled && produit.stock < quantity) {
      throw StateError('Stock insuffisant.');
    }

    final now = DateTime.now();
    final lineAmount = produit.prix * quantity;

    await _database.transaction(() async {
      final existingLine =
          await (_database.select(_database.ligneCommandes)..where(
                (l) =>
                    l.establishmentId.equals(establishmentId) &
                    l.commandeId.equals(commandeId) &
                    l.produitId.equals(produitId) &
                    l.isDeleted.equals(false),
              ))
              .getSingleOrNull();

      if (existingLine == null) {
        await _database
            .into(_database.ligneCommandes)
            .insert(
              LigneCommandesCompanion.insert(
                id: _uuid.v4(),
                establishmentId: Value(establishmentId),
                commandeId: commandeId,
                produitId: produitId,
                libelle: produit.nom,
                quantite: Value(quantity),
                prixUnitaire: produit.prix,
                montantLigne: lineAmount,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        final newQuantity = existingLine.quantite + quantity;
        await (_database.update(_database.ligneCommandes)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.id.equals(existingLine.id),
            ))
            .write(
              LigneCommandesCompanion(
                quantite: Value(newQuantity),
                prixUnitaire: Value(produit.prix),
                montantLigne: Value(produit.prix * newQuantity),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      }

      if (produit.stockTrackingEnabled) {
        await (_database.update(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(produitId),
            ))
            .write(
              ProduitsCompanion(
                stock: Value(produit.stock - quantity),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      }

      await _recalculateTotal(establishmentId, commandeId, now);
    });
  }

  @override
  Future<void> removeLine({
    required String establishmentId,
    required String lineId,
  }) async {
    final line =
        await (_database.select(_database.ligneCommandes)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.id.equals(lineId) &
                  l.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (line == null) throw StateError('Ligne de commande introuvable.');
    await _requireMutableCommande(establishmentId, line.commandeId);

    final produit =
        await (_database.select(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(line.produitId) &
                  p.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (produit == null) throw StateError('Produit introuvable.');

    final now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(_database.ligneCommandes)..where(
            (l) =>
                l.establishmentId.equals(establishmentId) & l.id.equals(lineId),
          ))
          .write(
            LigneCommandesCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );

      if (produit.stockTrackingEnabled) {
        await (_database.update(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(line.produitId),
            ))
            .write(
              ProduitsCompanion(
                stock: Value(produit.stock + line.quantite),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      }

      await _recalculateTotal(establishmentId, line.commandeId, now);
    });
  }

  @override
  Future<void> decrementLine({
    required String establishmentId,
    required String lineId,
  }) async {
    final line =
        await (_database.select(_database.ligneCommandes)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.id.equals(lineId) &
                  l.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (line == null) throw StateError('Ligne de commande introuvable.');
    if (line.quantite <= 1) {
      await removeLine(establishmentId: establishmentId, lineId: lineId);
      return;
    }
    await _requireMutableCommande(establishmentId, line.commandeId);

    final produit =
        await (_database.select(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(line.produitId) &
                  p.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (produit == null) throw StateError('Produit introuvable.');

    final now = DateTime.now();
    final newQuantity = line.quantite - 1;
    await _database.transaction(() async {
      await (_database.update(_database.ligneCommandes)..where(
            (l) =>
                l.establishmentId.equals(establishmentId) & l.id.equals(lineId),
          ))
          .write(
            LigneCommandesCompanion(
              quantite: Value(newQuantity),
              montantLigne: Value(line.prixUnitaire * newQuantity),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );

      if (produit.stockTrackingEnabled) {
        await (_database.update(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(line.produitId),
            ))
            .write(
              ProduitsCompanion(
                stock: Value(produit.stock + 1),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      }

      await _recalculateTotal(establishmentId, line.commandeId, now);
    });
  }

  @override
  Future<void> cancelCommande({
    required String establishmentId,
    required String commandeId,
  }) async {
    await _requireMutableCommande(establishmentId, commandeId);
    final now = DateTime.now();

    await _database.transaction(() async {
      final lines =
          await (_database.select(_database.ligneCommandes)..where(
                (l) =>
                    l.establishmentId.equals(establishmentId) &
                    l.commandeId.equals(commandeId) &
                    l.isDeleted.equals(false),
              ))
              .get();

      for (final line in lines) {
        final produit =
            await (_database.select(_database.produits)..where(
                  (p) =>
                      p.establishmentId.equals(establishmentId) &
                      p.id.equals(line.produitId) &
                      p.isDeleted.equals(false),
                ))
                .getSingleOrNull();

        if (produit != null && produit.stockTrackingEnabled) {
          await (_database.update(_database.produits)..where(
                (p) =>
                    p.establishmentId.equals(establishmentId) &
                    p.id.equals(line.produitId),
              ))
              .write(
                ProduitsCompanion(
                  stock: Value(produit.stock + line.quantite),
                  updatedAt: Value(now),
                  isDirty: const Value(true),
                ),
              );
        }

        await (_database.update(_database.ligneCommandes)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.id.equals(line.id),
            ))
            .write(
              LigneCommandesCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      }

      await (_database.update(_database.commandes)..where(
            (c) =>
                c.establishmentId.equals(establishmentId) &
                c.id.equals(commandeId),
          ))
          .write(
            CommandesCompanion(
              statut: const Value('annulees'),
              montantTotal: const Value(0),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
    });
  }

  @override
  Future<void> setStatus({
    required String establishmentId,
    required String commandeId,
    required String statusKey,
  }) async {
    if (statusKey == 'annulees') {
      await cancelCommande(
        establishmentId: establishmentId,
        commandeId: commandeId,
      );
      return;
    }
    await _requireMutableCommande(establishmentId, commandeId);
    final now = DateTime.now();
    await (_database.update(_database.commandes)..where(
          (c) =>
              c.establishmentId.equals(establishmentId) &
              c.id.equals(commandeId),
        ))
        .write(
          CommandesCompanion(
            statut: Value(statusKey),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
  }

  Future<Commande> _requireMutableCommande(
    String establishmentId,
    String commandeId,
  ) async {
    final commande =
        await (_database.select(_database.commandes)..where(
              (c) =>
                  c.establishmentId.equals(establishmentId) &
                  c.id.equals(commandeId) &
                  c.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (commande == null) throw StateError('Commande introuvable.');
    if (commande.statut == 'annulees') {
      throw StateError('Cette commande est annulée.');
    }
    return commande;
  }

  Future<void> _recalculateTotal(
    String establishmentId,
    String commandeId,
    DateTime updatedAt,
  ) async {
    final totalExpression = _database.ligneCommandes.montantLigne.sum();
    final totalRow =
        await (_database.selectOnly(_database.ligneCommandes)
              ..addColumns([totalExpression])
              ..where(
                _database.ligneCommandes.establishmentId.equals(
                      establishmentId,
                    ) &
                    _database.ligneCommandes.commandeId.equals(commandeId) &
                    _database.ligneCommandes.isDeleted.equals(false),
              ))
            .getSingleOrNull();
    final total = totalRow?.read(totalExpression) ?? 0;

    await (_database.update(_database.commandes)..where(
          (c) =>
              c.establishmentId.equals(establishmentId) &
              c.id.equals(commandeId),
        ))
        .write(
          CommandesCompanion(
            montantTotal: Value(total),
            updatedAt: Value(updatedAt),
            isDirty: const Value(true),
          ),
        );
  }

  CommandeEntity _commandeFromDrift(Commande row) {
    return CommandeEntity(
      id: row.id,
      clientId: row.clientId,
      reference: row.reference,
      statusKey: row.statut,
      statusLabel: commandeStatusLabel(row.statut),
      context: row.contexte,
      totalAmount: row.montantTotal,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  LigneCommandeEntity _ligneFromDrift(LigneCommande row) {
    return LigneCommandeEntity(
      id: row.id,
      commandeId: row.commandeId,
      produitId: row.produitId,
      label: row.libelle,
      quantity: row.quantite,
      unitPrice: row.prixUnitaire,
      lineAmount: row.montantLigne,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
