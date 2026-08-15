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
import 'package:auto_mobile_software/features/printing/presentation/providers/printer_providers.dart';
import 'package:auto_mobile_software/features/printing/presentation/screens/printer_settings_screen.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/data/repositories/commande_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/presentation/screens/commande_detail_screen.dart';

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

class _Fixture {
  _Fixture({required this.database, required this.commandeId});

  final AppDatabase database;
  final String commandeId;
}

Future<_Fixture> _seed() async {
  final database = AppDatabase(NativeDatabase.memory());

  await ClientRepositoryImpl(database: database).createClient(
    establishmentId: 'etab-1',
    name: 'Amina Kabasele',
    whatsappPhone: '+243900111222',
  );

  final produit = await ProduitRepositoryImpl(database: database).createProduit(
    establishmentId: 'etab-1',
    name: 'Poulet braisé',
    price: 10,
    currency: AppCurrency.usd,
    stock: 5,
  );

  final commandeRepository = CommandeRepositoryImpl(database: database);
  final commande = await commandeRepository.createCommande(
    establishmentId: 'etab-1',
    context: 'Table 7',
  );
  await commandeRepository.addProduitLine(
    establishmentId: 'etab-1',
    commandeId: commande.id,
    produitId: produit.id,
    quantity: 2,
  );

  return _Fixture(database: database, commandeId: commande.id);
}

Future<void> _pump(
  WidgetTester tester,
  _Fixture fixture, {
  PrinterConnectionStatus printerStatus = const PrinterConnectionStatus(
    selectedAddress: null,
    selectedName: null,
    connected: false,
  ),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment),
        ),
        databaseProvider.overrideWithValue(fixture.database),
        // Sans rôle actif, canCreateActivitiesProvider vaut false par
        // défaut et bloque silencieusement toute mutation passant par le
        // controller (attachClient, registerPayment...).
        canCreateActivitiesProvider.overrideWithValue(true),
        currentPrinterStatusProvider.overrideWith((ref) async => printerStatus),
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
          initialLocation: Routes.commandeDetailPath(fixture.commandeId),
          routes: [
            GoRoute(
              path: Routes.commandeDetail,
              builder: (context, state) =>
                  CommandeDetailScreen(commandeId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: Routes.printerSettings,
              builder: (context, state) => const PrinterSettingsScreen(),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  // Le popup d'impression consulte l'imprimante sélectionnée via
  // SharedPreferences ; sans cette initialisation, l'appel bloque
  // indéfiniment faute de handler de plateforme en environnement de test.
  SharedPreferences.setMockInitialValues(const {});

  const connectedPrinter = PrinterConnectionStatus(
    selectedAddress: '00:11:22:AA:BB:CC',
    selectedName: 'MP210',
    connected: true,
  );

  testWidgets(
    'les deux onglets exposent Imprimer facture et Encaisser paiement, sans le bouton Enregistrer',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await _pump(tester, fixture, printerStatus: connectedPrinter);

      expect(find.text('Enregistrer la commande'), findsNothing);
      expect(find.text('Imprimer facture'), findsOneWidget);
      expect(find.text('Encaisser paiement'), findsOneWidget);

      await tester.tap(find.text('Détails'));
      await tester.pumpAndSettle();

      expect(find.text('Imprimer facture'), findsOneWidget);
      expect(find.text('Encaisser paiement'), findsOneWidget);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'taper un numéro dans l\'onglet Détails affiche une suggestion cliquable et attache le client',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await _pump(tester, fixture);

      await tester.tap(find.text('Détails'));
      await tester.pumpAndSettle();

      expect(find.text('Amina Kabasele'), findsNothing);

      await tester.enterText(find.byType(TextField), '9001');
      await tester.pumpAndSettle();

      expect(find.text('Amina Kabasele'), findsOneWidget);
      expect(find.text('+243900111222'), findsOneWidget);

      await tester.ensureVisible(find.text('Amina Kabasele'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amina Kabasele'));
      await tester.pumpAndSettle();

      // Le champ est vidé et la liste de suggestions se referme ; seule la
      // carte du client attaché (avec son bouton "Retirer") reste visible —
      // preuve non ambiguë que l'attachement a bien eu lieu.
      expect(find.text('Amina Kabasele'), findsOneWidget);
      expect(find.byTooltip('Retirer le client'), findsOneWidget);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'Imprimer facture affiche un popup indiquant qu\'aucune imprimante n\'est connectée',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await _pump(tester, fixture, printerStatus: connectedPrinter);

      await tester.tap(find.text('Imprimer facture'));
      await tester.pumpAndSettle();

      expect(find.text('Imprimer la facture'), findsOneWidget);
      expect(find.text('Aucune imprimante configurée.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Imprimer'), findsNothing);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Imprimer la facture'), findsNothing);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'sans imprimante connectée, le bouton ouvre la configuration imprimante',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await _pump(tester, fixture);

      expect(find.text('Imprimer facture'), findsNothing);
      expect(find.text('Configurer une imprimante'), findsOneWidget);

      await tester.tap(find.text('Configurer une imprimante'));
      await tester.pumpAndSettle();

      expect(find.text('Configuration imprimante'), findsOneWidget);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'Encaisser paiement affiche le total, clôture la commande et déclenche la célébration',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await _pump(tester, fixture);

      await tester.tap(find.text('Encaisser paiement'));
      await tester.pumpAndSettle();

      expect(find.text('Encaisser le paiement'), findsOneWidget);
      expect(find.text('Le total à encaisser est :'), findsOneWidget);
      // "20 FC" apparaît aussi par coïncidence sur la ligne produit et la
      // barre d'actions (même montant) ; on cible le popup spécifiquement.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('20 FC'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Argent encaissé'));
      await tester.pumpAndSettle();
      expect(find.text('Mode de paiement'), findsWidgets);
      expect(find.text('Cash'), findsOneWidget);

      await tester.tap(find.text('Valider'));
      // Pompe quelques frames sans attendre la fin du SnackBar (durée par
      // défaut ~4s) : pumpAndSettle attendrait sa disparition automatique
      // et manquerait l'assertion sur son contenu.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Paiement encaissé — commande clôturée.'),
        findsOneWidget,
      );
      // Le badge/bouton se mettent à jour dès la clôture ; on évite
      // pumpAndSettle ici, car les confettis animent en continu pendant
      // toute leur durée (par design) et ne "se stabilisent" jamais au
      // sens strict attendu par pumpAndSettle.
      expect(find.text('Payée'), findsOneWidget);
      expect(find.text('Encaisser paiement'), findsNothing);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'une commande clôturée ne peut plus être annulée mais reste imprimable (menu)',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      final commandeRepository = CommandeRepositoryImpl(
        database: fixture.database,
      );
      await commandeRepository.registerPayment(
        establishmentId: 'etab-1',
        commandeId: fixture.commandeId,
      );

      await _pump(tester, fixture);

      expect(find.text('Encaisser paiement'), findsNothing);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Imprimer'), findsOneWidget);
      expect(find.text('Annuler la commande'), findsNothing);
      expect(find.text('Encaisser le paiement'), findsNothing);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'Ajouter un produit sur commande clôturée notifie sans ouvrir le sheet',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await CommandeRepositoryImpl(database: fixture.database).registerPayment(
        establishmentId: 'etab-1',
        commandeId: fixture.commandeId,
      );

      await _pump(tester, fixture);

      await tester.tap(find.text('Ajouter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Cette commande est déjà clôturée et payée.'),
        findsOneWidget,
      );
      expect(find.text('Sélectionnez un produit à ajouter'), findsNothing);

      await _disposeTree(tester);
    },
  );

  testWidgets(
    'Ajouter un produit sur commande annulée notifie sans ouvrir le sheet',
    (tester) async {
      final fixture = await _seed();
      addTearDown(fixture.database.close);
      await CommandeRepositoryImpl(database: fixture.database).cancelCommande(
        establishmentId: 'etab-1',
        commandeId: fixture.commandeId,
      );

      await _pump(tester, fixture);

      await tester.tap(find.text('Ajouter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cette commande est déjà annulée.'), findsOneWidget);
      expect(find.text('Sélectionnez un produit à ajouter'), findsNothing);

      await _disposeTree(tester);
    },
  );
}
