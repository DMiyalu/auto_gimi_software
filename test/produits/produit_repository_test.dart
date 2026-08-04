import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';

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
}
