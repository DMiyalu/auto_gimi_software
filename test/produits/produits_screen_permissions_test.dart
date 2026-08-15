import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/core/routing/routes.dart';
import 'package:auto_mobile_software/core/sync/auto_sync_coordinator.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/produits/presentation/screens/produit_form_screen.dart';
import 'package:auto_mobile_software/features/produits/presentation/screens/produits_screen.dart';

void main() {
  testWidgets('un agent consulte les produits sans bouton de création', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentEstablishmentProvider.overrideWith(
            (ref) => Stream.value(
              Establishment(
                id: 'etab-1',
                name: 'Restaurant Zolana',
                category: BusinessCategory.restaurant,
                ownerId: 'owner-1',
                managerName: 'Amina Kabasele',
                phone: '+243900000000',
                phoneVerified: true,
                createdAt: DateTime(2026, 1, 1),
              ),
            ),
          ),
          canManageCatalogProvider.overrideWithValue(false),
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
            initialLocation: '/produits',
            routes: [
              GoRoute(
                path: '/produits',
                builder: (context, state) => const ProduitsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Produits'), findsWidgets);
    expect(find.text('Aucun produit'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'ajouter un produit affiche et persiste le seuil quand le stock est suivi',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            currentEstablishmentProvider.overrideWith(
              (ref) => Stream.value(
                Establishment(
                  id: 'etab-1',
                  name: 'Restaurant Zolana',
                  category: BusinessCategory.restaurant,
                  ownerId: 'owner-1',
                  managerName: 'Amina Kabasele',
                  phone: '+243900000000',
                  phoneVerified: true,
                  createdAt: DateTime(2026, 1, 1),
                ),
              ),
            ),
            canManageCatalogProvider.overrideWithValue(true),
            autoSyncCoordinatorProvider.overrideWith(
              (ref) => _NoopAutoSyncCoordinator(),
            ),
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
              initialLocation: Routes.produits,
              routes: [
                GoRoute(
                  path: Routes.produits,
                  builder: (context, state) => const ProduitsScreen(),
                ),
                GoRoute(
                  path: Routes.produitNew,
                  builder: (context, state) => const ProduitFormScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Ajouter un produit'));
      await tester.pumpAndSettle();

      expect(find.text("Seuil d'alerte stock"), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom du produit'),
        'Riz',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Prix'), '5');
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Quantité en stock'), findsOneWidget);
      expect(find.text("Seuil d'alerte stock"), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantité en stock'),
        '8',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, "Seuil d'alerte stock"),
        '3',
      );
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      final produits = await database.select(database.produits).get();

      expect(produits.single.nom, 'Riz');
      expect(produits.single.stockTrackingEnabled, isTrue);
      expect(produits.single.stock, 8);
      expect(produits.single.stockAlertThreshold, 3);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}

class _NoopAutoSyncCoordinator implements AutoSyncCoordinator {
  @override
  void dispose() {}

  @override
  void schedulePush() {}
}
