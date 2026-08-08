import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/phone_verification_repository_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/signup_otp_pending_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_invitation.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
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

  UserProfile unverifiedProfileWithoutEstablishment() => UserProfile(
    uid: 'uid-test',
    phone: '33612345678',
    fullName: 'Test Manager',
    establishmentId: '',
    role: 'agent',
    phoneVerified: false,
    createdAt: DateTime(2026, 1, 1),
  );

  UserProfile verifiedProfileWithoutEstablishment() => UserProfile(
    uid: 'uid-test',
    phone: '33612345678',
    fullName: 'Test Manager',
    establishmentId: '',
    role: 'agent',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  UserProfile verifiedProfileWithEstablishment() => UserProfile(
    uid: 'uid-test',
    phone: '33612345678',
    fullName: 'Test Manager',
    establishmentId: 'est-test',
    role: 'owner',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
    establishmentIds: const ['est-test'],
    activeEstablishmentId: 'est-test',
    rolesByEstablishment: const {'est-test': 'owner'},
  );

  Establishment testEstablishment() => Establishment(
    id: 'est-test',
    name: 'Garage Test',
    category: BusinessCategory.garageAuto,
    ownerId: 'uid-test',
    managerName: 'Test Manager',
    phone: '33612345678',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  List<Override> testOverrides({bool otpPending = false}) => [
    authRepositoryProvider.overrideWithValue(authRepository),
    establishmentRepositoryProvider.overrideWithValue(establishmentRepository),
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
        establishmentRepository.setProfile(
          verifiedProfileWithoutEstablishment(),
        );
      },
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('affiche la page de connexion quand déconnecté', (tester) async {
    database = await pumpTestApp(tester, overrides: testOverrides());
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets(
    'login : reprise directe de l’activité si un établissement actif existe',
    (tester) async {
      authRepository.setUser(user);
      establishmentRepository.setProfile(verifiedProfileWithEstablishment());
      establishmentRepository.setEstablishments([testEstablishment()]);

      database = await pumpTestApp(
        tester,
        overrides: testOverrides(otpPending: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prestations'), findsWidgets);
      expect(find.text('Phone verification'), findsNothing);
      expect(find.text('Mes établissements'), findsNothing);
    },
  );

  testWidgets('signup : redirige vers la vérification OTP', (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(unverifiedProfileWithoutEstablishment());

    database = await pumpTestApp(
      tester,
      overrides: testOverrides(otpPending: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phone verification'), findsOneWidget);
    expect(find.byKey(const Key('verify_code_field')), findsOneWidget);
  });

  testWidgets('flux e2e: signup -> vérification OTP -> landing post-auth', (
    tester,
  ) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(unverifiedProfileWithoutEstablishment());

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

    expect(find.text('Créer un établissement'), findsOneWidget);
    expect(find.text('Aucune invitation en attente'), findsOneWidget);
  });

  testWidgets(
    'affiche la landing quand le téléphone est vérifié sans établissement',
    (tester) async {
      authRepository.setUser(user);
      establishmentRepository.setProfile(verifiedProfileWithoutEstablishment());

      database = await pumpTestApp(tester, overrides: testOverrides());
      await tester.pumpAndSettle();

      expect(find.text('Bienvenue, Test Manager'), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_create_establishment_button')),
        findsOneWidget,
      );
      expect(find.text('Phone verification'), findsNothing);
    },
  );

  testWidgets(
    'landing : accepter une invitation puis ouvrir l’établissement',
    (tester) async {
      authRepository.setUser(user);
      establishmentRepository.setProfile(verifiedProfileWithoutEstablishment());
      establishmentRepository.setInvitations([
        EstablishmentInvitation(
          id: 'inv-1',
          establishmentId: 'est-invited',
          establishmentName: 'Restaurant invité',
          invitedPhone: '33612345678',
          role: EstablishmentRole.manager,
          status: EstablishmentInvitationStatus.pending,
          invitedBy: 'owner-1',
          invitedByName: 'Propriétaire',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]);

      database = await pumpTestApp(tester, overrides: testOverrides());
      await tester.pumpAndSettle();

      expect(find.text('Invitations reçues'), findsOneWidget);
      expect(find.text('Restaurant invité'), findsOneWidget);

      await tester.tap(find.byKey(const Key('accept_invitation_inv-1')));
      await tester.pumpAndSettle();

      // Reste sur la landing ; l'établissement apparaît dans la liste.
      expect(find.text('Mes établissements'), findsOneWidget);
      expect(find.text('Restaurant invité'), findsWidgets);
      expect(find.text('Créer un établissement'), findsOneWidget);

      await tester.tap(find.byKey(const Key('open_establishment_est-invited')));
      await tester.pumpAndSettle();

      expect(find.text('Commandes'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
