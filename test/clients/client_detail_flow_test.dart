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
import 'package:auto_mobile_software/features/clients/data/repositories/client_repository_impl.dart';
import 'package:auto_mobile_software/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:auto_mobile_software/features/clients/presentation/screens/client_form_screen.dart';
import 'package:auto_mobile_software/features/clients/presentation/screens/clients_list_screen.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';

final _establishment = Establishment(
  id: 'etab-1',
  name: 'Garage Zuri',
  category: BusinessCategory.garageAuto,
  ownerId: 'owner-1',
  managerName: 'Jean Kalonji',
  phone: '+243900000000',
  phoneVerified: true,
  createdAt: DateTime(2026, 1, 1),
);

Future<AppDatabase> _pump(WidgetTester tester) async {
  final database = AppDatabase(NativeDatabase.memory());
  final repository = ClientRepositoryImpl(database: database);
  await repository.createClient(
    establishmentId: _establishment.id,
    name: 'Patrick Mbala',
    whatsappPhone: '243812345678',
    email: 'patrick.mbala@email.com',
    address: 'Avenue de la Paix, Gombe',
  );

  final router = GoRouter(
    initialLocation: '/clients',
    routes: [
      GoRoute(path: '/clients', builder: (_, __) => const ClientsListScreen()),
      GoRoute(
        path: '/clients/edit/:id',
        builder: (_, state) =>
            ClientFormScreen(clientId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/clients/:id',
        builder: (_, state) =>
            ClientDetailScreen(clientId: state.pathParameters['id']!),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
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
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return database;
}

void main() {
  testWidgets(
    "taper sur un client ouvre son détail avec informations et historique",
    (tester) async {
      final database = await _pump(tester);

      await tester.tap(find.text('Patrick Mbala'));
      await tester.pumpAndSettle();

      expect(find.text('Détails client'), findsOneWidget);
      expect(find.text('patrick.mbala@email.com'), findsOneWidget);
      expect(find.text('Avenue de la Paix, Gombe'), findsOneWidget);

      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun historique pour ce client.'), findsOneWidget);

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('Aucune note pour ce client.'), findsOneWidget);

      await database.close();
      await tester.pump();
    },
  );

  testWidgets("Modifier depuis le détail met à jour le nom du client", (
    tester,
  ) async {
    final database = await _pump(tester);

    await tester.tap(find.text('Patrick Mbala'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();

    expect(find.text('Modifier le client'), findsOneWidget);
    final nameField = find.byKey(const Key('client_name_field'));
    expect(find.widgetWithText(TextFormField, 'Patrick Mbala'), findsOneWidget);

    await tester.enterText(nameField, 'Patrick M. Kalonji');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Détails client'), findsOneWidget);
    expect(find.text('Patrick M. Kalonji'), findsOneWidget);

    await database.close();
    await tester.pump();
  });
}
