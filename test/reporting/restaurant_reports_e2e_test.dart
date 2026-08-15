import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/reporting/presentation/screens/dashboard_screen.dart';
import 'package:auto_mobile_software/features/reporting/presentation/widgets/product_sales_breakdown_card.dart';
import 'package:auto_mobile_software/features/reporting/presentation/widgets/report_date_range_selector.dart';
import 'package:auto_mobile_software/features/reporting/presentation/widgets/restaurant_report_kpi_grid.dart';
import 'package:auto_mobile_software/features/reporting/presentation/widgets/revenue_evolution_chart.dart';
import 'package:auto_mobile_software/features/restaurant/data/repositories/commande_repository_impl.dart';

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
  final produits = ProduitRepositoryImpl(database: database);
  final commandes = CommandeRepositoryImpl(database: database);
  final clients = ClientRepositoryImpl(database: database);

  final client = await clients.createClient(
    establishmentId: 'etab-1',
    name: 'Amina Kabasele',
    whatsappPhone: '+243900111222',
  );

  final plats = await produits.createCategory(
    establishmentId: 'etab-1',
    name: 'Plats',
  );
  final poulet = await produits.createProduit(
    establishmentId: 'etab-1',
    categoryId: plats.id,
    name: 'Poulet braisé',
    price: 10000,
    currency: AppCurrency.cdf,
    stock: 50,
  );
  final riz = await produits.createProduit(
    establishmentId: 'etab-1',
    categoryId: plats.id,
    name: 'Riz gras',
    price: 5000,
    currency: AppCurrency.cdf,
    stock: 50,
  );

  final commandeA = await commandes.createCommande(
    establishmentId: 'etab-1',
    clientId: client.id,
    context: 'Table 1',
  );
  await commandes.addProduitLine(
    establishmentId: 'etab-1',
    commandeId: commandeA.id,
    produitId: poulet.id,
    quantity: 2,
  );
  await commandes.addProduitLine(
    establishmentId: 'etab-1',
    commandeId: commandeA.id,
    produitId: riz.id,
    quantity: 1,
  );
  await commandes.registerPayment(
    establishmentId: 'etab-1',
    commandeId: commandeA.id,
  );

  final commandeB = await commandes.createCommande(
    establishmentId: 'etab-1',
    clientId: client.id,
    context: 'Table 2',
  );
  await commandes.addProduitLine(
    establishmentId: 'etab-1',
    commandeId: commandeB.id,
    produitId: poulet.id,
    quantity: 1,
  );
  await commandes.registerPayment(
    establishmentId: 'etab-1',
    commandeId: commandeB.id,
  );

  // CA = 2*10000 + 5000 + 10000 = 35 000 CDF, 2 commandes, 1 client.
  final now = DateTime.now();
  for (final id in [commandeA.id, commandeB.id]) {
    await (database.update(
      database.commandes,
    )..where((c) => c.id.equals(id))).write(
      CommandesCompanion(createdAt: Value(now), updatedAt: Value(now)),
    );
  }

  return database;
}

Future<void> _pump(WidgetTester tester, AppDatabase database) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment),
        ),
        databaseProvider.overrideWithValue(database),
        canCreateActivitiesProvider.overrideWithValue(true),
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
          initialLocation: Routes.reports,
          routes: [
            GoRoute(
              path: Routes.reports,
              builder: (_, _) => const DashboardScreen(),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(const {});
    await initializeDateFormatting('fr');
  });

  testWidgets(
    'parcours Rapports restaurant : KPIs, graphique, catégorie, sheet et période',
    (tester) async {
      final database = await _seed();
      addTearDown(database.close);

      await _pump(tester, database);

      // 1. Écran restaurant (pas le stub garage) — titre header + Partager.
      expect(find.text('Rapports'), findsWidgets);
      expect(find.byKey(const Key('send_report_button')), findsNothing);
      expect(find.text('Envoyer'), findsNothing);
      expect(find.byKey(const Key('share_report_button')), findsOneWidget);
      expect(find.text('Partager'), findsOneWidget);
      expect(find.text('Aperçu de votre activité'), findsNothing);
      expect(find.byType(RestaurantReportKpiGrid), findsOneWidget);
      expect(find.byType(RevenueEvolutionChart), findsOneWidget);
      expect(find.byType(ProductSalesBreakdownCard), findsOneWidget);

      // 1b. Sheet de partage : 4 périodes.
      await tester.tap(find.byKey(const Key('share_report_button')));
      await tester.pumpAndSettle();
      expect(find.text('Rapport du jour'), findsOneWidget);
      expect(find.text('Rapport hebdo semaine en cours'), findsOneWidget);
      expect(
        find.text('Rapport hebdo de la semaine précédente'),
        findsOneWidget,
      );
      expect(find.text('Rapport mensuel du mois précédent'), findsOneWidget);
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      // 2. KPIs issus des commandes clôturées du jour.
      // NumberFormat fr utilise un espace insécable comme séparateur.
      final amountFormat = NumberFormat('#,##0', 'fr');
      expect(
        find.text('${amountFormat.format(35000)} CDF'),
        findsOneWidget,
      ); // CA
      expect(find.text('2'), findsWidgets); // commandes (+ éventuellement rank)
      expect(
        find.text('${amountFormat.format(17500)} CDF'),
        findsOneWidget,
      ); // panier moyen
      expect(find.text('1'), findsWidgets); // clients servis / ranks
      expect(find.text("Chiffre d'affaires"), findsOneWidget);
      expect(find.text('Commandes'), findsWidgets);
      expect(find.text('Panier moyen'), findsOneWidget);
      expect(find.text('Clients servis'), findsOneWidget);

      // 3. Graphique + répartition.
      expect(find.text("Évolution du chiffre d'affaires"), findsOneWidget);
      expect(find.text('CA (CDF)'), findsOneWidget);
      expect(find.text('Répartition des ventes par catégorie'), findsOneWidget);
      expect(find.text('Plats'), findsOneWidget);
      expect(find.text('Poulet braisé'), findsOneWidget);
      expect(find.text('Riz gras'), findsOneWidget);

      // 4. Bottom sheet élargi « voir tous ».
      await tester.ensureVisible(
        find.text('Voir tous les produits de la catégorie'),
      );
      await tester.tap(find.text('Voir tous les produits de la catégorie'));
      await tester.pumpAndSettle();

      expect(find.text('Produits — Plats'), findsOneWidget);
      expect(find.textContaining('2 produits'), findsOneWidget);
      expect(find.text('Poulet braisé'), findsWidgets);
      expect(find.text('Riz gras'), findsWidgets);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Produits — Plats'), findsNothing);

      // 5. Filtre de période.
      await tester.tap(find.byType(ReportDateRangeSelector));
      await tester.pumpAndSettle();
      expect(find.text('Période'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, '7 derniers jours'));
      await tester.pumpAndSettle();
      expect(find.text('7 derniers jours'), findsOneWidget);

      // Démonte proprement (timers Drift / charts).
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    },
  );
}
