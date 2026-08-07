import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/core/routing/routes.dart';
import 'package:auto_mobile_software/features/clients/data/repositories/client_repository_impl.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/primary_module/screens/primary_module_screen.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/presentation/screens/commande_detail_screen.dart';
import 'package:auto_mobile_software/features/restaurant/presentation/screens/new_commande_screen.dart';

final _establishment = Establishment(
  id: 'etab-1',
  name: 'Le Goût Parfait',
  category: BusinessCategory.restaurant,
  ownerId: 'owner-1',
  managerName: 'Jean Kalonji',
  phone: '+243900000000',
  phoneVerified: true,
  createdAt: DateTime(2026, 1, 1),
);

Future<AppDatabase> _seed() async {
  final database = AppDatabase(NativeDatabase.memory());

  await ClientRepositoryImpl(database: database).createClient(
    establishmentId: 'etab-1',
    name: 'Amina Kabasele',
    whatsappPhone: '+243900111222',
  );
  await ProduitRepositoryImpl(database: database).createProduit(
    establishmentId: 'etab-1',
    name: 'Poulet braisé',
    price: 10,
    currency: AppCurrency.usd,
    stock: 5,
  );

  return database;
}

Future<void> _pump(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment),
        ),
        databaseProvider.overrideWithValue(database),
        // Sans rôle actif, canCreateActivitiesProvider vaut false par
        // défaut et bloque silencieusement toute mutation passant par le
        // controller (createCommande, addProduitLine, registerPayment...).
        canCreateActivitiesProvider.overrideWithValue(true),
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
          initialLocation: Routes.dashboard,
          routes: [
            GoRoute(
              path: Routes.dashboard,
              builder: (_, _) => const PrimaryModuleScreen(),
            ),
            GoRoute(
              path: Routes.commandeNew,
              builder: (_, _) => const NewCommandeScreen(),
            ),
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
  // Le popup d'impression consulte l'imprimante sélectionnée via
  // SharedPreferences ; sans cette initialisation, l'appel bloque
  // indéfiniment faute de handler de plateforme en environnement de test.
  SharedPreferences.setMockInitialValues(const {});

  testWidgets(
    'parcours complet : liste -> nouvelle commande -> table -> produit -> '
    'client -> impression -> encaissement -> retour liste à jour',
    (tester) async {
      final database = await _seed();
      addTearDown(database.close);
      await _pump(tester, database);

      // 1. Depuis la liste (restaurant), ouvrir le FAB puis "Nouvelle commande".
      expect(find.text('Le Goût Parfait'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // L'état vide de la liste propose aussi un bouton "Nouvelle commande" :
      // on cible précisément le ListTile de la feuille d'actions du FAB.
      await tester.tap(find.widgetWithText(ListTile, 'Nouvelle commande'));
      await tester.pumpAndSettle();

      expect(find.text('Créer une commande'), findsOneWidget);

      // 2. Choisir une table.
      await tester.tap(find.text('Sans table'));
      await tester.pumpAndSettle();
      expect(find.text('Choisir une table'), findsOneWidget);
      await tester.tap(find.text('Table 2'));
      await tester.pumpAndSettle();

      // 3. Créer la commande -> navigation vers l'écran de détail réel.
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.text('Table 2'), findsWidgets);
      expect(
        find.text('Ajoutez des produits à la commande'),
        findsOneWidget,
      );

      // 4. Ajouter un produit via la vraie feuille de sélection.
      await tester.tap(find.text('Ajouter un produit'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ajouter'));
      await tester.pump();
      await tester.tap(find.byTooltip('Ajouter'));
      await tester.pump();
      expect(find.text('2 produits sélectionnés'), findsOneWidget);

      await tester.tap(find.text('Ajouter à la commande'));
      await tester.pumpAndSettle();

      expect(find.text('Poulet braisé'), findsOneWidget);
      expect(find.text('2 x 10 FC'), findsOneWidget);

      // 5. Attacher un client via la recherche inline (onglet Détails).
      await tester.tap(find.text('Détails'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '9001');
      await tester.pumpAndSettle();
      expect(find.text('Amina Kabasele'), findsOneWidget);

      await tester.ensureVisible(find.text('Amina Kabasele'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amina Kabasele'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Retirer le client'), findsOneWidget);

      // 6. Vérifier que le popup d'impression est bien atteignable depuis
      // une commande réellement créée et peuplée (aucune imprimante ici).
      await tester.tap(find.text('Imprimer facture'));
      await tester.pumpAndSettle();
      expect(find.text('Imprimer la facture'), findsOneWidget);
      expect(find.text('Aucune imprimante configurée.'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // 7. Encaisser sans avoir imprimé (cas d'usage explicitement demandé) :
      // en_cours -> clôturée directement.
      await tester.tap(find.text('Encaisser paiement'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('20 FC'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Argent encaissé'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Paiement encaissé — commande clôturée.'),
        findsOneWidget,
      );
      expect(find.text('Payée'), findsOneWidget);
      expect(find.text('Encaisser paiement'), findsNothing);

      // 8. Retour à la liste : la commande clôturée doit s'y refléter.
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Table 2'), findsWidgets);
      expect(find.text('Clôturée'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
