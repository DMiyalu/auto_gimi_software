import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:auto_mobile_software/features/billing/domain/entities/facture_entity.dart';
import 'package:auto_mobile_software/features/billing/domain/entities/paiement_entity.dart';

void main() {
  late AppDatabase database;
  late BillingRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = BillingRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('emet une facture idempotente pour une activite', () async {
    final first = await repository.issueFactureForActivity(
      establishmentId: 'est-1',
      activityType: BillingActivityType.commande,
      activityId: 'cmd-1',
      totalAmount: 42,
      currency: AppCurrency.usd,
    );
    final second = await repository.issueFactureForActivity(
      establishmentId: 'est-1',
      activityType: BillingActivityType.commande,
      activityId: 'cmd-1',
      totalAmount: 42,
      currency: AppCurrency.usd,
    );

    expect(second.id, first.id);

    final factures = await repository
        .watchFactures(establishmentId: 'est-1')
        .first;
    expect(factures, hasLength(1));
    expect(factures.single.status, FactureStatus.issued);
    expect(factures.single.totalAmount, 42);
  });

  test('emet une facture pour une prestation garage', () async {
    final facture = await repository.issueFactureForActivity(
      establishmentId: 'garage-1',
      activityType: BillingActivityType.prestation,
      activityId: 'prest-1',
      totalAmount: 75,
      currency: AppCurrency.usd,
    );

    final updated = await repository
        .watchFactureForActivity(
          establishmentId: 'garage-1',
          activityType: BillingActivityType.prestation,
          activityId: 'prest-1',
        )
        .first;

    expect(updated!.id, facture.id);
    expect(updated.activityType, BillingActivityType.prestation.value);
    expect(updated.totalAmount, 75);
  });

  test('enregistre un paiement partiel puis solde la facture', () async {
    final facture = await repository.issueFactureForActivity(
      establishmentId: 'est-1',
      activityType: BillingActivityType.commande,
      activityId: 'cmd-1',
      totalAmount: 50,
    );

    await repository.recordPayment(
      establishmentId: 'est-1',
      factureId: facture.id,
      method: PaymentMethod.cash,
      amount: 20,
    );
    var updated = await repository
        .watchFactureForActivity(
          establishmentId: 'est-1',
          activityType: BillingActivityType.commande,
          activityId: 'cmd-1',
        )
        .first;
    expect(updated!.paidAmount, 20);
    expect(updated.status, FactureStatus.issued);

    await repository.recordPayment(
      establishmentId: 'est-1',
      factureId: facture.id,
      method: PaymentMethod.mobileMoney,
      amount: 30,
    );
    updated = await repository
        .watchFactureForActivity(
          establishmentId: 'est-1',
          activityType: BillingActivityType.commande,
          activityId: 'cmd-1',
        )
        .first;
    expect(updated!.paidAmount, 50);
    expect(updated.status, FactureStatus.paid);

    final payments = await repository
        .watchPaiements(establishmentId: 'est-1', factureId: facture.id)
        .first;
    expect(payments, hasLength(2));
  });

  test('refuse un paiement superieur au solde', () async {
    final facture = await repository.issueFactureForActivity(
      establishmentId: 'est-1',
      activityType: BillingActivityType.commande,
      activityId: 'cmd-1',
      totalAmount: 10,
    );

    await expectLater(
      repository.recordPayment(
        establishmentId: 'est-1',
        factureId: facture.id,
        method: PaymentMethod.cash,
        amount: 11,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
