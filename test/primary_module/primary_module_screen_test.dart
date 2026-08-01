import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/primary_module/screens/primary_module_screen.dart';

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

Future<void> _pump(WidgetTester tester, BusinessCategory category) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(_establishment(category)),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PrimaryModuleScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche la config garage : établissement, filtres, activité',
      (tester) async {
    await _pump(tester, BusinessCategory.garageAuto);

    expect(find.text('Garage Zuri'), findsOneWidget);
    expect(
      find.text('Rechercher une prestation, un véhicule ou un client…'),
      findsOneWidget,
    );
    expect(find.text('Diagnostic'), findsWidgets);
    expect(find.text('Toyota Corolla — CD 214 KM'), findsOneWidget);
  });

  testWidgets('affiche la config restaurant sans libellé garage codé en dur',
      (tester) async {
    await _pump(tester, BusinessCategory.restaurant);

    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('Livraison'), findsOneWidget);
    expect(find.text('Toyota Corolla — CD 214 KM'), findsNothing);
  });

  testWidgets('la recherche filtre instantanément la liste', (tester) async {
    await _pump(tester, BusinessCategory.restaurant);

    expect(find.text('Table 5'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Table 12');
    await tester.pumpAndSettle();

    expect(find.text('Table 12'), findsWidgets);
    expect(find.text('Table 5'), findsNothing);
  });

  testWidgets('un filtre de statut restreint la liste', (tester) async {
    await _pump(tester, BusinessCategory.restaurant);

    await tester.tap(find.text('Prêtes'));
    await tester.pumpAndSettle();

    expect(find.text('À emporter #1256'), findsOneWidget);
    expect(find.text('Table 12'), findsNothing);
  });
}
