import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/phone_verification_repository_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/signup_otp_pending_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';
import 'helpers/fake_phone_verification_repository.dart';
import 'helpers/fake_repositories.dart';
import 'helpers/pump_test_app.dart';

class MockFirebaseUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseUser user;
  late FakeAuthRepository authRepository;
  late FakeEstablishmentRepository establishmentRepository;
  late FakePhoneVerificationRepository phoneVerificationRepository;
  late AppDatabase database;

  UserProfile unverifiedProfile() => UserProfile(
        uid: 'uid-test',
        phone: '33612345678',
        fullName: 'Test Manager',
        establishmentId: 'est-test',
        role: 'owner',
        phoneVerified: false,
        createdAt: DateTime(2026, 1, 1),
      );

  UserProfile verifiedProfile() => UserProfile(
        uid: 'uid-test',
        phone: '33612345678',
        fullName: 'Test Manager',
        establishmentId: 'est-test',
        role: 'owner',
        phoneVerified: true,
        createdAt: DateTime(2026, 1, 1),
      );

  List<Override> testOverrides({bool otpPending = false}) => [
        authRepositoryProvider.overrideWithValue(authRepository),
        establishmentRepositoryProvider.overrideWithValue(
          establishmentRepository,
        ),
        phoneVerificationRepositoryProvider.overrideWithValue(
          phoneVerificationRepository,
        ),
        signupOtpPendingProvider.overrideWith((ref) => otpPending),
      ];

  setUp(() {
    user = MockFirebaseUser();
    when(() => user.uid).thenReturn('uid-test');

    authRepository = FakeAuthRepository();
    establishmentRepository = FakeEstablishmentRepository();
    phoneVerificationRepository = FakePhoneVerificationRepository(
      onVerified: () {
        establishmentRepository.setProfile(verifiedProfile());
      },
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('affiche la page de connexion quand déconnecté', (tester) async {
    database = await pumpTestApp(tester, overrides: testOverrides());
    await tester.pumpAndSettle();

    expect(find.text('Konnect One'), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('login sans OTP : accès direct au tableau de bord', (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(unverifiedProfile());

    database = await pumpTestApp(
      tester,
      overrides: testOverrides(otpPending: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prestations'), findsWidgets);
    expect(find.text('Phone verification'), findsNothing);
  });

  testWidgets('signup : redirige vers la vérification OTP', (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(unverifiedProfile());

    database = await pumpTestApp(
      tester,
      overrides: testOverrides(otpPending: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phone verification'), findsOneWidget);
    expect(find.byKey(const Key('verify_code_field')), findsOneWidget);
  });

  testWidgets('flux e2e: signup -> vérification OTP -> tableau de bord',
      (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(unverifiedProfile());

    database = await pumpTestApp(
      tester,
      overrides: testOverrides(otpPending: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phone verification'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('verify_code_field')),
      FakePhoneVerificationRepository.testCode,
    );
    await tester.tap(find.byKey(const Key('verify_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Prestations'), findsWidgets);
    expect(find.text('Rapports'), findsWidgets);
  });

  testWidgets('affiche le tableau de bord quand le téléphone est vérifié',
      (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(verifiedProfile());

    database = await pumpTestApp(tester, overrides: testOverrides());
    await tester.pumpAndSettle();

    expect(find.text('Prestations'), findsWidgets);
    expect(find.text('Phone verification'), findsNothing);
  });
}
