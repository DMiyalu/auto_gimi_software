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
import 'package:auto_mobile_software/features/garage/data/repositories/prestation_repository_impl.dart';
import 'package:auto_mobile_software/features/primary_module/screens/primary_module_screen.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/presentation/screens/commande_detail_screen.dart';
import 'package:auto_mobile_software/features/restaurant/data/repositories/commande_repository_impl.dart';

Establishment _establishment(BusinessCategory category) {
  return Establishment(
    id: 'etab-1',
    name: 'Garage Zuri',
    category: category,
    ownerId: 'owner-1',
    managerName: 'Jean Kalonji',
    phone: '+243900000000',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

Future<void> _pump(
  WidgetTester tester,
  BusinessCategory category, {
  AppDatabase? database,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment(category)),
        ),
        if (database != null) databaseProvider.overrideWithValue(database),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (_, __) => const PrimaryModuleScreen()),
            GoRoute(
              path: Routes.commandeDetail,
              builder: (context, state) =>
                  CommandeDetailScreen(commandeId: state.pathParameters['id']!),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche la config garage : établissement, filtres, activité', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await PrestationRepositoryImpl(
      database: database,
    ).createPrestationForImmatriculation(
      establishmentId: 'etab-1',
      immatriculation: 'CD 214 KM',
    );

    await _pump(tester, BusinessCategory.garageAuto, database: database);

    expect(find.text('Garage Zuri'), findsOneWidget);
    expect(
      find.text('Rechercher une prestation, un véhicule ou un client…'),
      findsOneWidget,
    );
    expect(find.text('À payer'), findsOneWidget);
    expect(find.text('CD 214 KM'), findsOneWidget);

    // Démonte l'arbre avant la fin du test : la fermeture des flux Drift
    // .watch() actifs programme un timer interne de nettoyage à durée
    // nulle, qu'il faut laisser s'exécuter pour éviter l'assertion
    // "Timer still pending" du framework de test (cf. auto_sync_e2e_test).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'affiche Hotel / Guest House avec mainActivity Séjours et Zuri UI',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await _pump(tester, BusinessCategory.hotelGuestHouse, database: database);

      expect(find.text('Séjours'), findsWidgets);
      expect(find.text('Rechercher un séjour ou un client…'), findsOneWidget);
      expect(find.text('À payer'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Nouveau séjour'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('affiche la config restaurant sans libellé garage codé en dur', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await _pump(tester, BusinessCategory.restaurant, database: database);

    expect(find.text('À payer'), findsOneWidget);
    expect(
      find.text('Votre salle est prête à accueillir sa première commande'),
      findsOneWidget,
    );
    expect(find.text('Table 12'), findsNothing);
    expect(find.text('Toyota Corolla — CD 214 KM'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'le bouton de l’état vide des commandes ouvre les options d’action',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await _pump(tester, BusinessCategory.restaurant, database: database);

      await tester.tap(find.text('Nouvelle commande'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ListTile, 'Nouvelle commande'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ListTile, 'Réservation'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'À emporter'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Livraison'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('affiche les vraies commandes pour un restaurant', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await CommandeRepositoryImpl(
      database: database,
    ).createCommande(establishmentId: 'etab-1', context: 'Table VIP');

    await _pump(tester, BusinessCategory.restaurant, database: database);

    expect(find.textContaining('CMD-'), findsOneWidget);
    expect(find.text('Table VIP'), findsOneWidget);
    expect(find.text('Table 12'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('ouvre le détail réel depuis une commande restaurant', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final commande = await CommandeRepositoryImpl(
      database: database,
    ).createCommande(establishmentId: 'etab-1', context: 'Table terrasse');

    await _pump(tester, BusinessCategory.restaurant, database: database);

    await tester.tap(find.text(commande.reference));
    await tester.pumpAndSettle();

    expect(find.text(commande.reference), findsWidgets);
    expect(find.text('Table terrasse'), findsOneWidget);
    expect(find.text('Lignes'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('le détail commande annulée bloque les actions opérationnelles', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final produit = await ProduitRepositoryImpl(database: database)
        .createProduit(
          establishmentId: 'etab-1',
          name: 'Burger',
          price: 8,
          currency: AppCurrency.usd,
          stock: 2,
        );
    final repository = CommandeRepositoryImpl(database: database);
    final commande = await repository.createCommande(
      establishmentId: 'etab-1',
      context: 'Table annulée',
    );
    await repository.addProduitLine(
      establishmentId: 'etab-1',
      commandeId: commande.id,
      produitId: produit.id,
    );
    await repository.cancelCommande(
      establishmentId: 'etab-1',
      commandeId: commande.id,
    );

    await _pump(tester, BusinessCategory.restaurant, database: database);

    await tester.tap(find.text(commande.reference));
    await tester.pumpAndSettle();

    expect(
      find.text('Commande annulée : les produits ont été remis en stock.'),
      findsOneWidget,
    );
    expect(find.text('Produit'), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('la recherche filtre instantanément la liste', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = CommandeRepositoryImpl(database: database);
    await repository.createCommande(
      establishmentId: 'etab-1',
      context: 'Table 5',
    );
    await repository.createCommande(
      establishmentId: 'etab-1',
      context: 'Table 12',
    );

    await _pump(tester, BusinessCategory.restaurant, database: database);

    expect(find.text('Table 5'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Table 12');
    await tester.pumpAndSettle();

    expect(find.text('Table 12'), findsWidgets);
    expect(find.text('Table 5'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('un filtre de statut restreint la liste', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = CommandeRepositoryImpl(database: database);
    final aPayer = await repository.createCommande(
      establishmentId: 'etab-1',
      context: 'Table à payer',
    );
    await repository.markAwaitingPayment(
      establishmentId: 'etab-1',
      commandeId: aPayer.id,
    );
    await repository.createCommande(
      establishmentId: 'etab-1',
      context: 'Table 12',
    );

    await _pump(tester, BusinessCategory.restaurant, database: database);

    // Le badge de statut de la carte affiche aussi "À payer" : on cible
    // précisément le chip de filtre pour éviter l'ambiguïté avec ce badge.
    await tester.tap(find.byKey(const Key('status_filter_a_payer')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Table à payer'), findsOneWidget);
    expect(find.text('Table 12'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
