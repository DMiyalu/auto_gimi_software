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
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_member.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/establishment/presentation/screens/establishment_form_screen.dart';
import 'package:auto_mobile_software/features/primary_module/screens/primary_module_screen.dart';
import 'package:auto_mobile_software/features/primary_module/widgets/activity_card.dart';
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

Future<void> _pump(
  WidgetTester tester, {
  AppDatabase? database,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment),
        ),
        if (database != null) databaseProvider.overrideWithValue(database),
        ...extraOverrides,
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
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (_, __) => const PrimaryModuleScreen()),
            GoRoute(
              path: Routes.establishmentNew,
              builder: (_, __) => const EstablishmentFormScreen(),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<AppDatabase> _databaseWithCommande() async {
  final database = AppDatabase(NativeDatabase.memory());
  await CommandeRepositoryImpl(
    database: database,
  ).createCommande(establishmentId: 'etab-1', context: 'Table 12');
  return database;
}

Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets(
    "l'appui long ouvre un menu avec épingler / statut / imprimer / annuler",
    (tester) async {
      final database = await _databaseWithCommande();
      addTearDown(database.close);
      await _pump(tester, database: database);

      await tester.longPress(find.byType(ActivityCard).first);
      await tester.pumpAndSettle();

      expect(find.text('Épingler en haut'), findsOneWidget);
      expect(find.text('Changer le statut'), findsOneWidget);
      expect(find.text('Imprimer la facture'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);

      await _disposeTree(tester);
    },
  );

  testWidgets('épingler une carte affiche l\'indicateur épinglé', (
    tester,
  ) async {
    final database = await _databaseWithCommande();
    addTearDown(database.close);
    await _pump(tester, database: database);

    expect(find.byIcon(Icons.push_pin), findsNothing);

    await tester.longPress(find.byType(ActivityCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Épingler en haut'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.push_pin), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('changer le statut met à jour le badge de la carte', (
    tester,
  ) async {
    final database = await _databaseWithCommande();
    addTearDown(database.close);
    await _pump(tester, database: database);

    await tester.longPress(find.byType(ActivityCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Changer le statut'));
    await tester.pumpAndSettle();

    // "À payer" apparaît déjà comme chip de filtre sous la feuille ouverte ;
    // on cible précisément l'option du sélecteur de statut.
    final statusOption = find.widgetWithText(ListTile, 'À payer');
    expect(statusOption, findsOneWidget);
    await tester.tap(statusOption);
    await tester.pumpAndSettle();

    expect(find.text('À payer'), findsWidgets);

    await _disposeTree(tester);
  });

  testWidgets('annuler marque la carte comme annulée', (tester) async {
    final database = await _databaseWithCommande();
    addTearDown(database.close);
    await _pump(tester, database: database);

    await tester.longPress(find.byType(ActivityCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Annulée'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('glisser révèle Imprimer des deux côtés et déclenche un retour', (
    tester,
  ) async {
    final database = await _databaseWithCommande();
    addTearDown(database.close);
    await _pump(tester, database: database);

    await tester.drag(find.byType(ActivityCard).first, const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Imprimer'), findsOneWidget);

    await tester.tap(find.text('Imprimer'));
    await tester.pump();

    expect(find.textContaining('Impression de la facture'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets(
    "cliquer sur Ajouter un établissement ouvre le formulaire de création",
    (tester) async {
      await _pump(tester);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Établissements'), findsOneWidget);
      expect(find.text('Créer un établissement'), findsOneWidget);

      await tester.tap(find.text('Créer un établissement'));
      await tester.pumpAndSettle();

      expect(find.text('Établissements'), findsNothing);
      expect(find.text('Nouvel établissement'), findsOneWidget);
      expect(find.text('Créer l’établissement'), findsOneWidget);
    },
  );

  testWidgets(
    'le sélecteur affiche plusieurs établissements avec leurs rôles',
    (tester) async {
      final garage = Establishment(
        id: 'etab-2',
        name: 'Garage Zuri',
        category: BusinessCategory.garageAuto,
        ownerId: 'owner-2',
        managerName: 'Amina Kabasele',
        phone: '+243911111111',
        phoneVerified: true,
        createdAt: DateTime(2026, 1, 2),
      );

      await _pump(
        tester,
        extraOverrides: [
          userEstablishmentsProvider.overrideWith(
            (ref) => Stream.value([_establishment, garage]),
          ),
          userMembershipsProvider.overrideWith(
            (ref) => Stream.value([
              EstablishmentMember(
                uid: 'uid-test',
                establishmentId: _establishment.id,
                phone: '+243900000000',
                fullName: 'Jean Kalonji',
                role: EstablishmentRole.owner,
                phoneVerified: true,
                joinedAt: DateTime(2026, 1, 1),
              ),
              EstablishmentMember(
                uid: 'uid-test',
                establishmentId: garage.id,
                phone: '+243900000000',
                fullName: 'Jean Kalonji',
                role: EstablishmentRole.manager,
                phoneVerified: true,
                joinedAt: DateTime(2026, 1, 2),
              ),
            ]),
          ),
          userProfileProvider.overrideWith(
            (ref) => Stream.value(
              UserProfile(
                uid: 'uid-test',
                phone: '+243900000000',
                fullName: 'Jean Kalonji',
                establishmentId: _establishment.id,
                role: 'owner',
                phoneVerified: true,
                createdAt: DateTime(2026, 1, 1),
                establishmentIds: [_establishment.id, garage.id],
                activeEstablishmentId: _establishment.id,
                rolesByEstablishment: {
                  _establishment.id: 'owner',
                  garage.id: 'manager',
                },
              ),
            ),
          ),
        ],
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Établissements'), findsOneWidget);
      expect(find.text('Le Goût Parfait'), findsWidgets);
      expect(find.text('Garage Zuri'), findsOneWidget);
      expect(find.textContaining('Restaurant'), findsWidgets);
      expect(find.textContaining('Propriétaire'), findsOneWidget);
      expect(find.textContaining('Garage Auto-Mobile'), findsOneWidget);
      expect(find.textContaining('Gérant'), findsOneWidget);
    },
  );
}
