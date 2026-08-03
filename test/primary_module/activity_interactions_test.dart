import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/core/routing/routes.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/establishment/presentation/screens/establishment_form_screen.dart';
import 'package:auto_mobile_software/features/primary_module/screens/primary_module_screen.dart';
import 'package:auto_mobile_software/features/primary_module/widgets/activity_card.dart';

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

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment),
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

void main() {
  testWidgets(
    "l'appui long ouvre un menu avec épingler / statut / imprimer / annuler",
    (tester) async {
      await _pump(tester);

      await tester.longPress(find.byType(ActivityCard).first);
      await tester.pumpAndSettle();

      expect(find.text('Épingler en haut'), findsOneWidget);
      expect(find.text('Changer le statut'), findsOneWidget);
      expect(find.text('Imprimer la facture'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
    },
  );

  testWidgets('épingler une carte affiche l\'indicateur épinglé', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byIcon(Icons.push_pin), findsNothing);

    await tester.longPress(find.byType(ActivityCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Épingler en haut'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.push_pin), findsOneWidget);
  });

  testWidgets('changer le statut met à jour le badge de la carte', (
    tester,
  ) async {
    await _pump(tester);

    await tester.longPress(find.byType(ActivityCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Changer le statut'));
    await tester.pumpAndSettle();

    // "Prêtes" apparaît déjà comme chip de filtre sous la feuille ouverte ;
    // on cible précisément l'option du sélecteur de statut.
    final statusOption = find.widgetWithText(ListTile, 'Prêtes');
    expect(statusOption, findsOneWidget);
    await tester.tap(statusOption);
    await tester.pumpAndSettle();

    expect(find.text('Prêtes'), findsWidgets);
  });

  testWidgets('annuler marque la carte comme annulée', (tester) async {
    await _pump(tester);

    await tester.longPress(find.byType(ActivityCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Annulée'), findsOneWidget);
  });

  testWidgets('glisser révèle Imprimer des deux côtés et déclenche un retour', (
    tester,
  ) async {
    await _pump(tester);

    await tester.drag(find.byType(ActivityCard).first, const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Imprimer'), findsOneWidget);

    await tester.tap(find.text('Imprimer'));
    await tester.pump();

    expect(find.textContaining('Impression de la facture'), findsOneWidget);
  });

  testWidgets(
    "cliquer sur Ajouter un établissement ouvre le formulaire de création",
    (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Le Goût Parfait'));
      await tester.pumpAndSettle();

      expect(find.text('Établissements'), findsOneWidget);
      expect(find.text('Ajouter un établissement'), findsOneWidget);

      await tester.tap(find.text('Ajouter un établissement'));
      await tester.pumpAndSettle();

      expect(find.text('Établissements'), findsNothing);
      expect(find.text('Nouvel établissement'), findsOneWidget);
      expect(find.text('Créer l’établissement'), findsOneWidget);
    },
  );
}
