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
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
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
}
