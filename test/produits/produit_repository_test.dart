import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/produits/domain/entities/produit_entity.dart';

void main() {
  late AppDatabase database;
  late ProduitRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ProduitRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('updateStockTracking persiste la decision localement', () async {
    final produit = await repository.createProduit(
      establishmentId: 'est-1',
      name: 'Poulet braise',
      price: 8,
      currency: AppCurrency.usd,
      stock: 0,
      stockTrackingEnabled: true,
    );

    await repository.updateStockTracking(
      establishmentId: 'est-1',
      id: produit.id,
      enabled: false,
    );

    final updated = await repository.getProduit(
      establishmentId: 'est-1',
      id: produit.id,
    );

    expect(updated!.stockTrackingEnabled, isFalse);
  });

  test('createProduit persiste le seuil d alerte stock', () async {
    final produit = await repository.createProduit(
      establishmentId: 'est-1',
      name: 'Poulet braise',
      price: 8,
      currency: AppCurrency.usd,
      stock: 6,
      stockTrackingEnabled: true,
      stockAlertThreshold: 7,
    );

    final saved = await repository.getProduit(
      establishmentId: 'est-1',
      id: produit.id,
    );

    expect(saved!.stockAlertThreshold, 7);
    expect(saved.stockStatus, ProductStockStatus.low);
  });

  test('updateProduit met a jour le seuil d alerte stock', () async {
    final produit = await repository.createProduit(
      establishmentId: 'est-1',
      name: 'Poulet braise',
      price: 8,
      currency: AppCurrency.usd,
      stock: 10,
      stockTrackingEnabled: true,
      stockAlertThreshold: 3,
    );

    await repository.updateProduit(
      establishmentId: 'est-1',
      id: produit.id,
      name: 'Poulet braise',
      price: 8,
      currency: AppCurrency.usd,
      stock: 4,
      stockTrackingEnabled: true,
      stockAlertThreshold: 4,
    );

    final updated = await repository.getProduit(
      establishmentId: 'est-1',
      id: produit.id,
    );

    expect(updated!.stockAlertThreshold, 4);
    expect(updated.stockStatus, ProductStockStatus.low);
  });
}
