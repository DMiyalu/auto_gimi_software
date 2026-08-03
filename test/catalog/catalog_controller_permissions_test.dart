import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/produits/presentation/providers/produit_providers.dart';
import 'package:auto_mobile_software/features/services/presentation/providers/service_providers.dart';

void main() {
  final establishment = Establishment(
    id: 'est-1',
    name: 'Garage Zolana',
    category: BusinessCategory.garageAuto,
    ownerId: 'owner-1',
    managerName: 'Amina Kabasele',
    phone: '+243900000000',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  ProviderContainer testContainer(AppDatabase database) {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(establishment),
        ),
        canManageCatalogProvider.overrideWithValue(false),
      ],
    );
  }

  test('un agent ne peut pas creer un produit via le controleur', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = testContainer(database);
    addTearDown(container.dispose);

    await container.read(currentEstablishmentProvider.future);

    await container
        .read(produitControllerProvider.notifier)
        .createProduit(
          name: 'Huile moteur',
          price: 25,
          currency: AppCurrency.usd,
          stock: 4,
        );

    expect(container.read(produitControllerProvider).hasError, isTrue);
    expect(await container.read(produitsProvider.future), isEmpty);
  });

  test('un agent ne peut pas creer un service via le controleur', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = testContainer(database);
    addTearDown(container.dispose);

    await container.read(currentEstablishmentProvider.future);

    await container
        .read(serviceControllerProvider.notifier)
        .createService(
          name: 'Diagnostic',
          price: 15,
          currency: AppCurrency.usd,
          intervalDays: 0,
        );

    expect(container.read(serviceControllerProvider).hasError, isTrue);
    expect(await container.read(catalogServicesProvider.future), isEmpty);
  });
}
