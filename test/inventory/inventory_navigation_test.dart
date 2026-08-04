import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/core/routing/routes.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/inventory/presentation/screens/inventories_screen.dart';
import 'package:auto_mobile_software/features/inventory/presentation/screens/inventory_detail_screen.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/shell/presentation/widgets/more_menu_content.dart';

void main() {
  testWidgets('Plus donne accès aux inventaires restaurant', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await ProduitRepositoryImpl(database: database).createProduit(
      establishmentId: 'resto-1',
      name: 'Farine',
      price: 5,
      currency: AppCurrency.usd,
      stock: 12,
    );

    final establishment = Establishment(
      id: 'resto-1',
      name: 'Zolana Restaurant',
      category: BusinessCategory.restaurant,
      ownerId: 'owner-1',
      managerName: 'Jean Kalonji',
      phone: '+243900000000',
      phoneVerified: true,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentEstablishmentProvider.overrideWith(
            (ref) => Stream.value(establishment),
          ),
          pendingInvitationsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(
          locale: const Locale('fr'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: Routes.more,
            routes: [
              GoRoute(
                path: Routes.more,
                builder: (context, state) =>
                    const Scaffold(body: MoreMenuContent()),
              ),
              GoRoute(
                path: Routes.inventories,
                builder: (context, state) => const InventoriesScreen(),
              ),
              GoRoute(
                path: Routes.inventoryDetail,
                builder: (_, state) => InventoryDetailScreen(
                  inventoryId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventaires'), findsOneWidget);

    await tester.tap(find.text('Inventaires'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun inventaire'), findsOneWidget);

    await tester.tap(find.text('Nouvel inventaire'));
    await tester.pumpAndSettle();

    expect(find.text('Farine'), findsOneWidget);
    expect(find.text('Théorique : 12'), findsOneWidget);
    expect(find.text('Clôturer l’inventaire'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
