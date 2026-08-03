import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/enums.dart';
import '../../domain/entities/client_order_stats.dart';
import '../../domain/entities/ligne_prestation_entity.dart';
import '../../domain/entities/prestation_entity.dart';
import '../../domain/entities/prestation_summary.dart';
import '../../domain/entities/vehicule_entity.dart';
import '../../domain/repositories/prestation_repository.dart';

class PrestationRepositoryImpl implements PrestationRepository {
  PrestationRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<PrestationEntity?> watchPrestation({
    required String establishmentId,
    required String id,
  }) {
    final query = _database.select(_database.prestations)
      ..where(
        (p) =>
            p.establishmentId.equals(establishmentId) &
            p.id.equals(id) &
            p.isDeleted.equals(false),
      );
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _prestationFromDrift(row),
    );
  }

  @override
  Stream<VehiculeEntity?> watchVehicule({
    required String establishmentId,
    required String id,
  }) {
    final query = _database.select(_database.vehicules)
      ..where(
        (v) =>
            v.establishmentId.equals(establishmentId) &
            v.id.equals(id) &
            v.isDeleted.equals(false),
      );
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _vehiculeFromDrift(row),
    );
  }

  @override
  Stream<List<LignePrestationEntity>> watchLignes({
    required String establishmentId,
    required String prestationId,
  }) {
    final query = _database.select(_database.lignePrestations)
      ..where(
        (l) =>
            l.establishmentId.equals(establishmentId) &
            l.prestationId.equals(prestationId) &
            l.isDeleted.equals(false),
      )
      ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]);
    return query.watch().map((rows) => rows.map(_ligneFromDrift).toList());
  }

  @override
  Stream<List<PrestationSummary>> watchPrestationsSummary({
    required String establishmentId,
  }) {
    return _watchPrestationSummaries(establishmentId: establishmentId);
  }

  @override
  Stream<List<PrestationSummary>> watchPrestationsForClient({
    required String establishmentId,
    required String clientId,
  }) {
    return _watchPrestationSummaries(
      establishmentId: establishmentId,
      extraWhere: _database.prestations.clientId.equals(clientId),
    );
  }

  @override
  Stream<Map<String, ClientOrderStats>> watchClientOrderStats({
    required String establishmentId,
  }) {
    final query =
        _database.select(_database.prestations).join([
            innerJoin(
              _database.vehicules,
              _database.vehicules.id.equalsExp(
                _database.prestations.vehiculeId,
              ),
            ),
          ])
          ..where(
            _database.prestations.establishmentId.equals(establishmentId) &
                _database.prestations.isDeleted.equals(false) &
                _database.prestations.clientId.isNotNull(),
          )
          ..orderBy([OrderingTerm.desc(_database.prestations.dateOuverture)]);

    return query.watch().map((rows) {
      final totals = <String, double>{};
      final latest = <String, ClientOrderStats>{};

      for (final row in rows) {
        final prestation = row.readTable(_database.prestations);
        final vehicule = row.readTable(_database.vehicules);
        final clientId = prestation.clientId;
        if (clientId == null) continue;

        totals[clientId] = (totals[clientId] ?? 0) + prestation.montantTotal;
        // Les lignes sont triées de la plus récente à la plus ancienne : la
        // première rencontrée par client est donc sa dernière commande.
        latest.putIfAbsent(
          clientId,
          () => ClientOrderStats(
            totalSpent: 0,
            lastOrderAt: prestation.dateOuverture,
            lastOrderContext: vehicule.immatriculation,
          ),
        );
      }

      return {
        for (final entry in latest.entries)
          entry.key: ClientOrderStats(
            totalSpent: totals[entry.key]!,
            lastOrderAt: entry.value.lastOrderAt,
            lastOrderContext: entry.value.lastOrderContext,
          ),
      };
    });
  }

  Stream<List<PrestationSummary>> _watchPrestationSummaries({
    required String establishmentId,
    Expression<bool>? extraWhere,
  }) {
    final query =
        _database.select(_database.prestations).join([
            innerJoin(
              _database.vehicules,
              _database.vehicules.id.equalsExp(
                    _database.prestations.vehiculeId,
                  ) &
                  _database.vehicules.establishmentId.equals(establishmentId),
            ),
            leftOuterJoin(
              _database.clients,
              _database.clients.id.equalsExp(_database.prestations.clientId) &
                  _database.clients.establishmentId.equals(establishmentId) &
                  _database.clients.isDeleted.equals(false),
            ),
          ])
          ..where(
            _database.prestations.establishmentId.equals(establishmentId) &
                _database.prestations.isDeleted.equals(false) &
                (extraWhere ?? const Constant(true)),
          )
          ..orderBy([OrderingTerm.desc(_database.prestations.dateOuverture)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final prestation = row.readTable(_database.prestations);
        final vehicule = row.readTable(_database.vehicules);
        final client = row.readTableOrNull(_database.clients);
        final hasFullName = vehicule.marque != null && vehicule.modele != null;

        return PrestationSummary(
          id: prestation.id,
          statut: prestation.statut,
          dateOuverture: prestation.dateOuverture,
          montantTotal: prestation.montantTotal,
          vehiculeDisplayName: hasFullName
              ? '${vehicule.marque} ${vehicule.modele}'
              : vehicule.immatriculation,
          immatriculation: vehicule.immatriculation,
          clientName: client?.nom,
        );
      }).toList();
    });
  }

  @override
  Future<PrestationEntity> createPrestationForImmatriculation({
    required String establishmentId,
    required String immatriculation,
  }) async {
    final normalized = immatriculation.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw ArgumentError("Le numéro d'immatriculation est requis.");
    }

    final now = DateTime.now();
    final existingVehicule = await _findVehiculeByImmatriculation(
      establishmentId,
      normalized,
    );

    final vehiculeId = existingVehicule?.id ?? _uuid.v4();
    final clientId = existingVehicule?.clientId;

    if (existingVehicule == null) {
      await _database
          .into(_database.vehicules)
          .insert(
            VehiculesCompanion.insert(
              id: vehiculeId,
              establishmentId: Value(establishmentId),
              immatriculation: normalized,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    final prestationId = _uuid.v4();
    await _database
        .into(_database.prestations)
        .insert(
          PrestationsCompanion.insert(
            id: prestationId,
            establishmentId: Value(establishmentId),
            vehiculeId: vehiculeId,
            clientId: Value(clientId),
            statut: PrestationStatut.ouverte,
            dateOuverture: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return PrestationEntity(
      id: prestationId,
      vehiculeId: vehiculeId,
      clientId: clientId,
      statut: PrestationStatut.ouverte,
      dateOuverture: now,
      montantTotal: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> addServiceLine({
    required String establishmentId,
    required String prestationId,
    required String serviceId,
  }) async {
    final service =
        await (_database.select(_database.catalogServices)..where(
              (s) =>
                  s.establishmentId.equals(establishmentId) &
                  s.id.equals(serviceId) &
                  s.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (service == null) throw StateError('Service introuvable.');

    await _addOrIncrementLine(
      establishmentId: establishmentId,
      prestationId: prestationId,
      type: LigneType.service,
      serviceId: serviceId,
      produitId: null,
      libelle: service.nom,
      prixUnitaire: service.prix,
    );
  }

  @override
  Future<void> addProduitLine({
    required String establishmentId,
    required String prestationId,
    required String produitId,
  }) async {
    final produit =
        await (_database.select(_database.produits)..where(
              (p) =>
                  p.establishmentId.equals(establishmentId) &
                  p.id.equals(produitId) &
                  p.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (produit == null) throw StateError('Produit introuvable.');

    await _addOrIncrementLine(
      establishmentId: establishmentId,
      prestationId: prestationId,
      type: LigneType.produit,
      serviceId: null,
      produitId: produitId,
      libelle: produit.nom,
      prixUnitaire: produit.prix,
    );
  }

  @override
  Future<void> removeLine({
    required String establishmentId,
    required String ligneId,
  }) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      final ligne =
          await (_database.select(_database.lignePrestations)..where(
                (l) =>
                    l.establishmentId.equals(establishmentId) &
                    l.id.equals(ligneId),
              ))
              .getSingleOrNull();
      if (ligne == null) return;

      await (_database.update(_database.lignePrestations)..where(
            (l) =>
                l.establishmentId.equals(establishmentId) &
                l.id.equals(ligneId),
          ))
          .write(
            LignePrestationsCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );

      await _recomputeTotal(establishmentId, ligne.prestationId, now);
    });
  }

  @override
  Future<void> attachClient({
    required String establishmentId,
    required String prestationId,
    required String clientId,
  }) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      final prestation =
          await (_database.select(_database.prestations)..where(
                (p) =>
                    p.establishmentId.equals(establishmentId) &
                    p.id.equals(prestationId),
              ))
              .getSingleOrNull();
      if (prestation == null) throw StateError('Prestation introuvable.');

      await (_database.update(_database.prestations)..where(
            (p) =>
                p.establishmentId.equals(establishmentId) &
                p.id.equals(prestationId),
          ))
          .write(
            PrestationsCompanion(
              clientId: Value(clientId),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );

      await (_database.update(_database.vehicules)..where(
            (v) =>
                v.establishmentId.equals(establishmentId) &
                v.id.equals(prestation.vehiculeId),
          ))
          .write(
            VehiculesCompanion(
              clientId: Value(clientId),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
    });
  }

  @override
  Future<void> detachClient({
    required String establishmentId,
    required String prestationId,
  }) async {
    final now = DateTime.now();
    await (_database.update(_database.prestations)..where(
          (p) =>
              p.establishmentId.equals(establishmentId) &
              p.id.equals(prestationId),
        ))
        .write(
          PrestationsCompanion(
            clientId: const Value(null),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
  }

  Future<void> _addOrIncrementLine({
    required String establishmentId,
    required String prestationId,
    required LigneType type,
    required String? serviceId,
    required String? produitId,
    required String libelle,
    required double prixUnitaire,
  }) async {
    final now = DateTime.now();

    await _database.transaction(() async {
      final existingQuery = _database.select(_database.lignePrestations)
        ..where(
          (l) =>
              l.prestationId.equals(prestationId) &
              l.establishmentId.equals(establishmentId) &
              l.isDeleted.equals(false) &
              (serviceId != null
                  ? l.serviceId.equals(serviceId)
                  : l.produitId.equals(produitId!)),
        );
      final existing = await existingQuery.getSingleOrNull();

      if (existing != null) {
        final newQuantite = existing.quantite + 1;
        await (_database.update(_database.lignePrestations)..where(
              (l) =>
                  l.establishmentId.equals(establishmentId) &
                  l.id.equals(existing.id),
            ))
            .write(
              LignePrestationsCompanion(
                quantite: Value(newQuantite),
                montantLigne: Value(newQuantite * existing.prixUnitaire),
                updatedAt: Value(now),
                isDirty: const Value(true),
              ),
            );
      } else {
        await _database
            .into(_database.lignePrestations)
            .insert(
              LignePrestationsCompanion.insert(
                id: _uuid.v4(),
                establishmentId: Value(establishmentId),
                prestationId: prestationId,
                type: type,
                serviceId: Value(serviceId),
                produitId: Value(produitId),
                libelle: libelle,
                prixUnitaire: prixUnitaire,
                montantLigne: prixUnitaire,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      await _recomputeTotal(establishmentId, prestationId, now);
    });
  }

  Future<void> _recomputeTotal(
    String establishmentId,
    String prestationId,
    DateTime now,
  ) async {
    final sumRow =
        await (_database.selectOnly(_database.lignePrestations)
              ..addColumns([_database.lignePrestations.montantLigne.sum()])
              ..where(
                _database.lignePrestations.prestationId.equals(prestationId) &
                    _database.lignePrestations.establishmentId.equals(
                      establishmentId,
                    ) &
                    _database.lignePrestations.isDeleted.equals(false),
              ))
            .getSingleOrNull();
    final total =
        sumRow?.read(_database.lignePrestations.montantLigne.sum()) ?? 0;

    await (_database.update(_database.prestations)..where(
          (p) =>
              p.establishmentId.equals(establishmentId) &
              p.id.equals(prestationId),
        ))
        .write(
          PrestationsCompanion(
            montantTotal: Value(total),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
  }

  Future<Vehicule?> _findVehiculeByImmatriculation(
    String establishmentId,
    String normalized,
  ) {
    final query = _database.select(_database.vehicules)
      ..where(
        (v) =>
            v.establishmentId.equals(establishmentId) &
            v.immatriculation.equals(normalized) &
            v.isDeleted.equals(false),
      );
    return query.getSingleOrNull();
  }

  PrestationEntity _prestationFromDrift(Prestation row) {
    return PrestationEntity(
      id: row.id,
      vehiculeId: row.vehiculeId,
      clientId: row.clientId,
      statut: row.statut,
      dateOuverture: row.dateOuverture,
      dateCloture: row.dateCloture,
      montantTotal: row.montantTotal,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  VehiculeEntity _vehiculeFromDrift(Vehicule row) {
    return VehiculeEntity(
      id: row.id,
      clientId: row.clientId,
      immatriculation: row.immatriculation,
      marque: row.marque,
      modele: row.modele,
      annee: row.annee,
      kilometrage: row.kilometrage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  LignePrestationEntity _ligneFromDrift(LignePrestation row) {
    return LignePrestationEntity(
      id: row.id,
      prestationId: row.prestationId,
      type: row.type,
      serviceId: row.serviceId,
      produitId: row.produitId,
      libelle: row.libelle,
      quantite: row.quantite,
      prixUnitaire: row.prixUnitaire,
      montantLigne: row.montantLigne,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
