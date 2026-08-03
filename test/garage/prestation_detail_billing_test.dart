import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/garage/data/repositories/prestation_repository_impl.dart';
import 'package:auto_mobile_software/features/garage/presentation/screens/prestation_detail_screen.dart';
import 'package:auto_mobile_software/features/services/data/repositories/service_repository_impl.dart';

void main() {
  late AppDatabase database;
  late PrestationRepositoryImpl prestationRepository;
  late ServiceRepositoryImpl serviceRepository;

  final establishment = Establishment(
    id: 'garage-1',
    name: 'Garage Zolana',
    category: BusinessCategory.garageAuto,
    ownerId: 'owner-1',
    managerName: 'Jean Kalonji',
    phone: '+243900000000',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    prestationRepository = PrestationRepositoryImpl(database: database);
    serviceRepository = ServiceRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets("l'onglet facture expose le montant d'une prestation garage", (
    tester,
  ) async {
    final prestation = await prestationRepository
        .createPrestationForImmatriculation(
          establishmentId: establishment.id,
          immatriculation: 'CD 214 KM',
        );
    final service = await serviceRepository.createService(
      establishmentId: establishment.id,
      name: 'Diagnostic',
      price: 35,
      currency: AppCurrency.usd,
      intervalDays: 0,
    );
    await prestationRepository.addServiceLine(
      establishmentId: establishment.id,
      prestationId: prestation.id,
      serviceId: service.id,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentEstablishmentProvider.overrideWith(
            (ref) => Stream.value(establishment),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PrestationDetailScreen(prestationId: prestation.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Facture'));
    await tester.pumpAndSettle();

    expect(find.text('Facture'), findsWidgets);
    expect(find.text('Montant à facturer : 35.00'), findsOneWidget);
    expect(find.text('Émettre la facture'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
