import 'package:drift/drift.dart';
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
  final now = DateTime.now();

  await repository.createClient(
    establishmentId: _establishment.id,
    name: 'Patrick Mbala',
    whatsappPhone: '243812345678',
  );
  await database
      .update(database.clients)
      .write(
        ClientsCompanion(
          createdAt: Value(now.subtract(const Duration(days: 5))),
        ),
      );

  final router = GoRouter(
    initialLocation: '/clients',
    routes: [
      GoRoute(path: '/clients', builder: (_, __) => const ClientsListScreen()),
      GoRoute(
        path: '/clients/new',
        builder: (_, __) => const ClientFormScreen(),
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
  testWidgets('affiche les initiales du client (pas de photo)', (tester) async {
    final database = await _pump(tester);

    expect(find.text('PM'), findsOneWidget);

    await database.close();
    await tester.pump();
  });

  testWidgets('la recherche filtre la liste par nom', (tester) async {
    final database = await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'zzz-introuvable');
    await tester.pumpAndSettle();

    expect(find.text('Patrick Mbala'), findsNothing);
    expect(
      find.text('Aucun client ne correspond à ce filtre.'),
      findsOneWidget,
    );

    await database.close();
    await tester.pump();
  });

  testWidgets('le filtre "Fidèles" exclut un client sans points', (
    tester,
  ) async {
    final database = await _pump(tester);

    expect(find.text('Patrick Mbala'), findsOneWidget);

    await tester.tap(find.text('Fidèles'));
    await tester.pumpAndSettle();

    expect(find.text('Patrick Mbala'), findsNothing);

    await tester.tap(find.text('Tous'));
    await tester.pumpAndSettle();
    expect(find.text('Patrick Mbala'), findsOneWidget);

    await database.close();
    await tester.pump();
  });

  testWidgets('la carte client affiche dernière commande et chevron Zuri', (
    tester,
  ) async {
    final database = await _pump(tester);

    expect(find.text('Aucune commande'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.text('Clients récents'), findsOneWidget);
    expect(find.text('Patrick Mbala'), findsOneWidget);
    expect(find.text('+243812345678'), findsOneWidget);

    await database.close();
    await tester.pump();
  });

  testWidgets('le bouton flottant ouvre une feuille avec "Ajouter un client"', (
    tester,
  ) async {
    final database = await _pump(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter un client'), findsOneWidget);
    await tester.tap(find.text('Ajouter un client'));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter un client'), findsOneWidget);
    expect(find.byKey(const Key('client_name_field')), findsOneWidget);

    await database.close();
    await tester.pump();
  });
}
