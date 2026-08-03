import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/app_currency.dart';
import '../../domain/entities/facture_entity.dart';
import '../../domain/entities/paiement_entity.dart';
import '../../domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  final _uuid = const Uuid();

  @override
  Stream<List<FactureEntity>> watchFactures({required String establishmentId}) {
    final query = _database.select(_database.factures)
      ..where(
        (f) =>
            f.establishmentId.equals(establishmentId) &
            f.isDeleted.equals(false),
      )
      ..orderBy([(f) => OrderingTerm.desc(f.issuedAt)]);

    return query.watch().map((rows) => rows.map(_factureFromDrift).toList());
  }

  @override
  Stream<FactureEntity?> watchFactureForActivity({
    required String establishmentId,
    required BillingActivityType activityType,
    required String activityId,
  }) {
    final query = _database.select(_database.factures)
      ..where(
        (f) =>
            f.establishmentId.equals(establishmentId) &
            f.activityType.equals(activityType.value) &
            f.activityId.equals(activityId) &
            f.isDeleted.equals(false),
      );

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _factureFromDrift(row),
    );
  }

  @override
  Stream<List<PaiementEntity>> watchPaiements({
    required String establishmentId,
    required String factureId,
  }) {
    final query = _database.select(_database.paiements)
      ..where(
        (p) =>
            p.establishmentId.equals(establishmentId) &
            p.factureId.equals(factureId) &
            p.isDeleted.equals(false),
      )
      ..orderBy([(p) => OrderingTerm.desc(p.paidAt)]);

    return query.watch().map((rows) => rows.map(_paiementFromDrift).toList());
  }

  @override
  Future<FactureEntity> issueFactureForActivity({
    required String establishmentId,
    required BillingActivityType activityType,
    required String activityId,
    required double totalAmount,
    AppCurrency currency = AppCurrency.usd,
  }) async {
    if (totalAmount <= 0) {
      throw ArgumentError('Le montant de la facture doit être positif.');
    }

    final existing = await _findFactureForActivity(
      establishmentId: establishmentId,
      activityType: activityType,
      activityId: activityId,
    );
    if (existing != null) return _factureFromDrift(existing);

    final now = DateTime.now();
    final id = _uuid.v4();
    final reference =
        'FAC-${now.millisecondsSinceEpoch.toString().substring(6)}';

    await _database
        .into(_database.factures)
        .insert(
          FacturesCompanion.insert(
            id: id,
            establishmentId: Value(establishmentId),
            reference: reference,
            activityType: activityType.value,
            activityId: activityId,
            montantTotal: totalAmount,
            devise: Value(currency.code),
            issuedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return FactureEntity(
      id: id,
      reference: reference,
      activityType: activityType.value,
      activityId: activityId,
      status: FactureStatus.issued,
      totalAmount: totalAmount,
      paidAmount: 0,
      currency: currency,
      issuedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<PaiementEntity> recordPayment({
    required String establishmentId,
    required String factureId,
    required PaymentMethod method,
    required double amount,
    AppCurrency currency = AppCurrency.usd,
  }) async {
    if (amount <= 0) throw ArgumentError('Le paiement doit être positif.');

    final facture =
        await (_database.select(_database.factures)..where(
              (f) =>
                  f.establishmentId.equals(establishmentId) &
                  f.id.equals(factureId) &
                  f.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (facture == null) throw StateError('Facture introuvable.');
    if (facture.statut == FactureStatus.canceled.value) {
      throw StateError('Cette facture est annulée.');
    }
    if (facture.statut == FactureStatus.paid.value) {
      throw StateError('Cette facture est déjà payée.');
    }
    final balanceDue = facture.montantTotal - facture.montantPaye;
    if (amount > balanceDue) {
      throw ArgumentError('Le paiement dépasse le solde de la facture.');
    }

    final now = DateTime.now();
    final id = _uuid.v4();
    final newPaidAmount = facture.montantPaye + amount;
    final isPaid = newPaidAmount >= facture.montantTotal;

    await _database.transaction(() async {
      await _database
          .into(_database.paiements)
          .insert(
            PaiementsCompanion.insert(
              id: id,
              establishmentId: Value(establishmentId),
              factureId: factureId,
              methode: method.value,
              montant: amount,
              devise: Value(currency.code),
              paidAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (_database.update(_database.factures)..where(
            (f) =>
                f.establishmentId.equals(establishmentId) &
                f.id.equals(factureId),
          ))
          .write(
            FacturesCompanion(
              statut: Value(
                isPaid ? FactureStatus.paid.value : FactureStatus.issued.value,
              ),
              montantPaye: Value(newPaidAmount),
              paidAt: Value(isPaid ? now : null),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
    });

    return PaiementEntity(
      id: id,
      factureId: factureId,
      method: method,
      amount: amount,
      currency: currency,
      paidAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Facture?> _findFactureForActivity({
    required String establishmentId,
    required BillingActivityType activityType,
    required String activityId,
  }) {
    return (_database.select(_database.factures)..where(
          (f) =>
              f.establishmentId.equals(establishmentId) &
              f.activityType.equals(activityType.value) &
              f.activityId.equals(activityId) &
              f.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  FactureEntity _factureFromDrift(Facture row) {
    return FactureEntity(
      id: row.id,
      reference: row.reference,
      activityType: row.activityType,
      activityId: row.activityId,
      status: FactureStatus.fromValue(row.statut),
      totalAmount: row.montantTotal,
      paidAmount: row.montantPaye,
      currency: AppCurrency.fromCode(row.devise),
      issuedAt: row.issuedAt,
      paidAt: row.paidAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  PaiementEntity _paiementFromDrift(Paiement row) {
    return PaiementEntity(
      id: row.id,
      factureId: row.factureId,
      method: PaymentMethod.fromValue(row.methode),
      amount: row.montant,
      currency: AppCurrency.fromCode(row.devise),
      paidAt: row.paidAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
