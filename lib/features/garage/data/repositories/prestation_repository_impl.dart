import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/enums.dart';
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
  Stream<PrestationEntity?> watchPrestation(String id) {
    final query = _database.select(_database.prestations)
      ..where((p) => p.id.equals(id) & p.isDeleted.equals(false));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _prestationFromDrift(row));
  }

  @override
  Stream<VehiculeEntity?> watchVehicule(String id) {
    final query = _database.select(_database.vehicules)
      ..where((v) => v.id.equals(id) & v.isDeleted.equals(false));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _vehiculeFromDrift(row));
  }

  @override
  Stream<List<LignePrestationEntity>> watchLignes(String prestationId) {
    final query = _database.select(_database.lignePrestations)
      ..where(
        (l) =>
            l.prestationId.equals(prestationId) & l.isDeleted.equals(false),
      )
      ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]);
    return query.watch().map((rows) => rows.map(_ligneFromDrift).toList());
  }

  @override
  Stream<List<PrestationSummary>> watchPrestationsSummary() {
    final query = _database.select(_database.prestations).join([
      innerJoin(
        _database.vehicules,
        _database.vehicules.id.equalsExp(_database.prestations.vehiculeId),
      ),
      leftOuterJoin(
        _database.clients,
        _database.clients.id.equalsExp(_database.prestations.clientId) &
            _database.clients.isDeleted.equals(false),
      ),
    ])
      ..where(_database.prestations.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.prestations.dateOuverture)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final prestation = row.readTable(_database.prestations);
        final vehicule = row.readTable(_database.vehicules);
        final client = row.readTableOrNull(_database.clients);
        final hasFullName =
            vehicule.marque != null && vehicule.modele != null;

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
    final existingVehicule = await _findVehiculeByImmatriculation(normalized);

    final vehiculeId = existingVehicule?.id ?? _uuid.v4();
    final clientId = existingVehicule?.clientId;

    if (existingVehicule == null) {
      await _database.into(_database.vehicules).insert(
            VehiculesCompanion.insert(
              id: vehiculeId,
              immatriculation: normalized,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    final prestationId = _uuid.v4();
    await _database.into(_database.prestations).insert(
          PrestationsCompanion.insert(
            id: prestationId,
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
    final service = await (_database.select(_database.catalogServices)
          ..where((s) => s.id.equals(serviceId) & s.isDeleted.equals(false)))
        .getSingleOrNull();
    if (service == null) throw StateError('Service introuvable.');

    await _addOrIncrementLine(
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
    final produit = await (_database.select(_database.produits)
          ..where((p) => p.id.equals(produitId) & p.isDeleted.equals(false)))
        .getSingleOrNull();
    if (produit == null) throw StateError('Produit introuvable.');

    await _addOrIncrementLine(
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
      final ligne = await (_database.select(_database.lignePrestations)
            ..where((l) => l.id.equals(ligneId)))
          .getSingleOrNull();
      if (ligne == null) return;

      await (_database.update(_database.lignePrestations)
            ..where((l) => l.id.equals(ligneId)))
          .write(
        LignePrestationsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );

      await _recomputeTotal(ligne.prestationId, now);
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
      final prestation = await (_database.select(_database.prestations)
            ..where((p) => p.id.equals(prestationId)))
          .getSingleOrNull();
      if (prestation == null) throw StateError('Prestation introuvable.');

      await (_database.update(_database.prestations)
            ..where((p) => p.id.equals(prestationId)))
          .write(
        PrestationsCompanion(
          clientId: Value(clientId),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );

      await (_database.update(_database.vehicules)
            ..where((v) => v.id.equals(prestation.vehiculeId)))
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
    await (_database.update(_database.prestations)
          ..where((p) => p.id.equals(prestationId)))
        .write(
      PrestationsCompanion(
        clientId: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  Future<void> _addOrIncrementLine({
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
              l.isDeleted.equals(false) &
              (serviceId != null
                  ? l.serviceId.equals(serviceId)
                  : l.produitId.equals(produitId!)),
        );
      final existing = await existingQuery.getSingleOrNull();

      if (existing != null) {
        final newQuantite = existing.quantite + 1;
        await (_database.update(_database.lignePrestations)
              ..where((l) => l.id.equals(existing.id)))
            .write(
          LignePrestationsCompanion(
            quantite: Value(newQuantite),
            montantLigne: Value(newQuantite * existing.prixUnitaire),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      } else {
        await _database.into(_database.lignePrestations).insert(
              LignePrestationsCompanion.insert(
                id: _uuid.v4(),
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

      await _recomputeTotal(prestationId, now);
    });
  }

  Future<void> _recomputeTotal(String prestationId, DateTime now) async {
    final sumRow = await (_database.selectOnly(_database.lignePrestations)
          ..addColumns([_database.lignePrestations.montantLigne.sum()])
          ..where(
            _database.lignePrestations.prestationId.equals(prestationId) &
                _database.lignePrestations.isDeleted.equals(false),
          ))
        .getSingleOrNull();
    final total =
        sumRow?.read(_database.lignePrestations.montantLigne.sum()) ?? 0;

    await (_database.update(_database.prestations)
          ..where((p) => p.id.equals(prestationId)))
        .write(
      PrestationsCompanion(
        montantTotal: Value(total),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  Future<Vehicule?> _findVehiculeByImmatriculation(String normalized) {
    final query = _database.select(_database.vehicules)
      ..where(
        (v) =>
            v.immatriculation.equals(normalized) & v.isDeleted.equals(false),
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
