import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/signup_success_pending_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_invitation.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';
import 'helpers/fake_repositories.dart';
import 'helpers/pump_test_app.dart';

class MockFirebaseUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseUser user;
  late FakeAuthRepository authRepository;
  late FakeEstablishmentRepository establishmentRepository;
  late AppDatabase database;

  UserProfile profileWithoutEstablishment() => UserProfile(
    uid: 'uid-test',
    phone: '33612345678',
    fullName: 'Test Manager',
    establishmentId: '',
    role: 'agent',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  UserProfile profileWithEstablishment() => UserProfile(
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

  List<Override> testOverrides({bool signupSuccessPending = false}) => [
    authRepositoryProvider.overrideWithValue(authRepository),
    establishmentRepositoryProvider.overrideWithValue(establishmentRepository),
    signupSuccessPendingProvider.overrideWith((ref) => signupSuccessPending),
  ];

  setUp(() {
    user = MockFirebaseUser();
    when(() => user.uid).thenReturn('uid-test');

    authRepository = FakeAuthRepository();
    establishmentRepository = FakeEstablishmentRepository();
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
      establishmentRepository.setProfile(profileWithEstablishment());
      establishmentRepository.setEstablishments([testEstablishment()]);

      database = await pumpTestApp(tester, overrides: testOverrides());
      await tester.pumpAndSettle();

      expect(find.text('Prestations'), findsWidgets);
      expect(find.text('Phone verification'), findsNothing);
      expect(find.text('Mes établissements'), findsNothing);
    },
  );

  testWidgets('signup : redirige vers l’écran de succès', (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(profileWithoutEstablishment());

    database = await pumpTestApp(
      tester,
      overrides: testOverrides(signupSuccessPending: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registration successful!'), findsOneWidget);
    expect(
      find.byKey(const Key('signup_success_continue_button')),
      findsOneWidget,
    );
  });

  testWidgets('flux e2e: signup -> succès -> landing post-auth', (
    tester,
  ) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(profileWithoutEstablishment());

    database = await pumpTestApp(
      tester,
      overrides: testOverrides(signupSuccessPending: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registration successful!'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('signup_success_continue_button')),
    );
    await tester.tap(find.byKey(const Key('signup_success_continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('Créer un établissement'), findsOneWidget);
    expect(find.text('Aucune invitation en attente'), findsOneWidget);
  });

  testWidgets('affiche la landing quand connecté sans établissement', (
    tester,
  ) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(profileWithoutEstablishment());

    database = await pumpTestApp(tester, overrides: testOverrides());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue, Test Manager'), findsOneWidget);
    expect(
      find.byKey(const Key('onboarding_create_establishment_button')),
      findsOneWidget,
    );
    expect(find.text('Verify your number'), findsNothing);
  });

  testWidgets('landing : icône utilisateur ouvre le profil', (tester) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(profileWithoutEstablishment());

    database = await pumpTestApp(tester, overrides: testOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Test Manager'), findsWidgets);
    expect(find.text('33612345678'), findsOneWidget);
    expect(find.text('Déconnexion'), findsOneWidget);
  });

  testWidgets('création établissement : formulaire clair en trois champs', (
    tester,
  ) async {
    authRepository.setUser(user);
    establishmentRepository.setProfile(profileWithoutEstablishment());

    database = await pumpTestApp(tester, overrides: testOverrides());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const Key('onboarding_create_establishment_button'),
    );
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Nouvel établissement'), findsOneWidget);
    expect(find.text('Catégorie d’activité'), findsOneWidget);
    expect(find.text('Nom de l’établissement'), findsOneWidget);
    expect(find.text('Logo'), findsOneWidget);
    expect(find.text('Créer l’établissement'), findsOneWidget);
    expect(find.text('Nom du gérant'), findsNothing);
    expect(find.text('Numéro de téléphone'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom de l’établissement'),
      'Restaurant Clair',
    );
    final submitButton = find.widgetWithText(
      FilledButton,
      'Créer l’établissement',
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    final created = establishmentRepository.establishments.single;
    expect(created.name, 'Restaurant Clair');
    expect(created.managerName, 'Test Manager');
    expect(created.phone, '33612345678');
    expect(created.logoBase64, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('landing : accepter une invitation puis ouvrir l’établissement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    authRepository.setUser(user);
    establishmentRepository.setProfile(profileWithoutEstablishment());
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
  });
}
