import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:auto_mobile_software/features/inventory/domain/entities/inventory_session_entity.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';

void main() {
  late AppDatabase database;
  late InventoryRepositoryImpl repository;
  late ProduitRepositoryImpl produitRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = InventoryRepositoryImpl(database: database);
    produitRepository = ProduitRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createInventory capture les produits et leurs stocks courants',
    () async {
      final farine = await produitRepository.createProduit(
        establishmentId: 'resto-1',
        name: 'Farine',
        price: 5,
        currency: AppCurrency.usd,
        stock: 12,
      );
      await produitRepository.createProduit(
        establishmentId: 'resto-1',
        name: 'Tomate',
        price: 2,
        currency: AppCurrency.usd,
        stock: 8,
      );

      final inventory = await repository.createInventory(
        establishmentId: 'resto-1',
      );

      expect(inventory.status, InventoryStatus.draft);

      final lines = await repository
          .watchLines(establishmentId: 'resto-1', inventoryId: inventory.id)
          .first;
      expect(lines, hasLength(2));
      expect(
        lines.firstWhere((line) => line.productId == farine.id).label,
        'Farine',
      );
      expect(
        lines.firstWhere((line) => line.productId == farine.id).expectedStock,
        12,
      );
      expect(lines.every((line) => line.countedStock == null), isTrue);
    },
  );

  test(
    'closeInventory ajuste le stock produit avec les quantites comptees',
    () async {
      final produit = await produitRepository.createProduit(
        establishmentId: 'resto-1',
        name: 'Riz',
        price: 4,
        currency: AppCurrency.usd,
        stock: 10,
      );
      final inventory = await repository.createInventory(
        establishmentId: 'resto-1',
      );
      final line =
          (await repository
                  .watchLines(
                    establishmentId: 'resto-1',
                    inventoryId: inventory.id,
                  )
                  .first)
              .single;

      await repository.setCountedStock(
        establishmentId: 'resto-1',
        lineId: line.id,
        countedStock: 7,
      );
      await repository.closeInventory(
        establishmentId: 'resto-1',
        inventoryId: inventory.id,
      );

      final updatedProduct = await produitRepository.getProduit(
        establishmentId: 'resto-1',
        id: produit.id,
      );
      final updatedInventory = await repository
          .watchInventory(establishmentId: 'resto-1', id: inventory.id)
          .first;
      final updatedLine =
          (await repository
                  .watchLines(
                    establishmentId: 'resto-1',
                    inventoryId: inventory.id,
                  )
                  .first)
              .single;

      expect(updatedProduct!.stock, 7);
      expect(updatedInventory!.status, InventoryStatus.closed);
      expect(updatedInventory.closedAt, isNotNull);
      expect(updatedLine.variance, -3);
    },
  );

  test(
    "closeInventory refuse un inventaire avec des lignes non comptees",
    () async {
      await produitRepository.createProduit(
        establishmentId: 'resto-1',
        name: 'Sucre',
        price: 3,
        currency: AppCurrency.usd,
        stock: 6,
      );
      final inventory = await repository.createInventory(
        establishmentId: 'resto-1',
      );

      await expectLater(
        repository.closeInventory(
          establishmentId: 'resto-1',
          inventoryId: inventory.id,
        ),
        throwsA(isA<StateError>()),
      );
    },
  );
}
