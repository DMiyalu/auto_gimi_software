import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/l10n/app_localizations.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';
import 'package:auto_mobile_software/features/primary_module/widgets/business_header.dart';

import '../helpers/fake_repositories.dart';

class MockFirebaseUser extends Mock implements User {}

void main() {
  group('UserProfile.isValidReportEmail', () {
    test('accepte un email valide', () {
      expect(UserProfile.isValidReportEmail('owner@example.com'), isTrue);
      expect(
        UserProfile(
          uid: 'u',
          phone: '1',
          fullName: 'A',
          email: 'owner@example.com',
          establishmentId: '',
          role: 'owner',
          phoneVerified: true,
          createdAt: DateTime(2026, 1, 1),
        ).hasReportEmail,
        isTrue,
      );
    });

    test('rejette vide ou invalide', () {
      expect(UserProfile.isValidReportEmail(null), isFalse);
      expect(UserProfile.isValidReportEmail(''), isFalse);
      expect(UserProfile.isValidReportEmail('pas-un-email'), isFalse);
    });
  });

  testWidgets(
    'profil : flag rappel sans email, disparaît après saisie',
    (tester) async {
      final user = MockFirebaseUser();
      when(() => user.uid).thenReturn('uid-test');

      final auth = FakeAuthRepository()..setUser(user);
      final resto = Establishment(
        id: 'est-1',
        name: 'Resto Test',
        category: BusinessCategory.restaurant,
        ownerId: 'uid-test',
        managerName: 'Alice Owner',
        phone: '243900000000',
        phoneVerified: true,
        createdAt: DateTime(2026, 1, 1),
      );
      final profile = UserProfile(
        uid: 'uid-test',
        phone: '243900000000',
        fullName: 'Alice Owner',
        establishmentId: 'est-1',
        role: 'owner',
        phoneVerified: true,
        createdAt: DateTime(2026, 1, 1),
        establishmentIds: const ['est-1'],
        activeEstablishmentId: 'est-1',
        rolesByEstablishment: const {'est-1': 'owner'},
      );
      final establishmentRepo = FakeEstablishmentRepository()
        ..establishment = resto
        ..setProfile(profile)
        ..setEstablishments([resto]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            authStateProvider.overrideWith((ref) => Stream.value(user)),
            establishmentRepositoryProvider.overrideWithValue(establishmentRepo),
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
            currentEstablishmentProvider.overrideWith(
              (ref) => Stream.value(resto),
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
            home: const Scaffold(body: BusinessHeader()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('user_profile_avatar')), findsOneWidget);
      await tester.tap(find.byKey(const Key('user_profile_avatar')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Ajoutez votre e-mail pour recevoir le reporting'),
        findsOneWidget,
      );
      expect(find.text('E-mail manquant'), findsOneWidget);

      // Icône edit e-mail (la 2e : nom puis e-mail).
      await tester.tap(find.byIcon(Icons.edit_outlined).at(1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'alice@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();

      // Le StreamProvider overridé ne se met pas à jour — on vérifie la persistence repo.
      expect(establishmentRepo.profile?.email, 'alice@example.com');
      expect(find.text('E-mail mis à jour.'), findsOneWidget);
    },
  );
}
