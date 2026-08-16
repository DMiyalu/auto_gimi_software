import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/sync/sync_engine.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/phone_verification_repository_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/signup_otp_pending_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_member.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';

import '../helpers/fake_phone_verification_repository.dart';
import '../helpers/fake_repositories.dart';
import '../helpers/pump_test_app.dart';

class MockFirebaseUser extends Mock implements User {}

const _establishmentId = 'est-test';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseUser user;
  late FakeAuthRepository authRepository;
  late FakeEstablishmentRepository establishmentRepository;
  late FakePhoneVerificationRepository phoneVerificationRepository;
  late FakeFirebaseFirestore firestore;
  late AppDatabase database;

  setUp(() {
    user = MockFirebaseUser();
    when(() => user.uid).thenReturn('uid-test');

    authRepository = FakeAuthRepository()..setUser(user);
    establishmentRepository = FakeEstablishmentRepository()
      ..establishment = Establishment(
        id: _establishmentId,
        name: 'Garage Test',
        category: BusinessCategory.garageAuto,
        ownerId: 'uid-test',
        managerName: 'Test Manager',
        phone: '221771234567',
        phoneVerified: true,
        createdAt: DateTime(2026, 1, 1),
      )
      ..setProfile(
        UserProfile(
          uid: 'uid-test',
          phone: '33612345678',
          fullName: 'Test Manager',
          establishmentId: _establishmentId,
          establishmentIds: const [_establishmentId],
          activeEstablishmentId: _establishmentId,
          rolesByEstablishment: const {_establishmentId: 'owner'},
          role: 'owner',
          phoneVerified: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      );
    establishmentRepository.setMemberships([
      EstablishmentMember(
        uid: 'uid-test',
        establishmentId: _establishmentId,
        phone: '33612345678',
        fullName: 'Test Manager',
        role: EstablishmentRole.owner,
        phoneVerified: true,
        joinedAt: DateTime(2026, 1, 1),
      ),
    ]);
    phoneVerificationRepository = FakePhoneVerificationRepository(
      onVerified: () {},
    );
    firestore = FakeFirebaseFirestore();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('flux e2e : création client hors-ligne, visible immédiatement, '
      'puis synchronisé automatiquement au retour du réseau', (tester) async {
    database = await pumpTestApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        establishmentRepositoryProvider.overrideWithValue(
          establishmentRepository,
        ),
        phoneVerificationRepositoryProvider.overrideWithValue(
          phoneVerificationRepository,
        ),
        signupOtpPendingProvider.overrideWith((ref) => false),
        // Un Firestore de test pour toute la chaîne de synchro :
        // AutoSyncCoordinator (câblé dans AppShellScreen) l'utilise à la
        // fois pour le push débouncé déclenché après l'écriture locale
        // (via syncEngineProvider) et pour ses écouteurs temps réel.
        firestoreProvider.overrideWithValue(firestore),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Prestations'), findsWidgets);

    await tester.tap(find.text('Clients'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add client'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('client_name_field')),
      'Amadou Diallo',
    );
    await tester.enterText(
      find.byKey(const Key('client_whatsapp_local_field')),
      '771234567',
    );
    await tester.ensureVisible(find.byKey(const Key('client_submit_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('client_submit_button')));
    await tester.pumpAndSettle();

    // Retour sur la liste : le client créé "hors-ligne" est visible tout de
    // suite, l'écriture locale n'attend jamais le réseau.
    expect(find.text('Amadou Diallo'), findsOneWidget);

    final remoteClients = firestore.collection(
      'establishments/$_establishmentId/clients',
    );
    expect((await remoteClients.get()).docs, isEmpty);

    // Le push est débouncé (~1.5s) après l'écriture locale : on avance le
    // temps pour simuler le retour du réseau sans quitter l'écran.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    final synced = await remoteClients.get();
    expect(synced.docs, hasLength(1));
    expect(synced.docs.single.data()['name'], 'Amadou Diallo');

    // L'écran n'a jamais été interrompu par la synchro : le client est
    // toujours affiché.
    expect(find.text('Amadou Diallo'), findsOneWidget);

    final localRow = await (database.select(
      database.clients,
    )..where((c) => c.nom.equals('Amadou Diallo'))).getSingle();
    expect(localRow.isDirty, isFalse);

    // Démonte explicitement l'arbre de widgets (au lieu de laisser le
    // framework le faire après la fin du test) : la fermeture des flux
    // Drift .watch() actifs programme un timer interne de nettoyage à
    // durée nulle, qu'il faut laisser s'exécuter avant la fin du test pour
    // éviter l'assertion "Timer still pending" du framework de test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'la synchro attend le membership actif avant de lire ou pousser Firestore',
    (tester) async {
      establishmentRepository.setMemberships(const []);
      database = await pumpTestApp(
        tester,
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          establishmentRepositoryProvider.overrideWithValue(
            establishmentRepository,
          ),
          phoneVerificationRepositoryProvider.overrideWithValue(
            phoneVerificationRepository,
          ),
          signupOtpPendingProvider.overrideWith((ref) => false),
          firestoreProvider.overrideWithValue(firestore),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clients'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add client'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('client_name_field')),
        'Client Sync Retardée',
      );
      await tester.enterText(
        find.byKey(const Key('client_whatsapp_local_field')),
        '771234568',
      );
      await tester.ensureVisible(find.byKey(const Key('client_submit_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('client_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Client Sync Retardée'), findsOneWidget);

      final remoteClients = firestore.collection(
        'establishments/$_establishmentId/clients',
      );
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
      expect((await remoteClients.get()).docs, isEmpty);

      establishmentRepository.setMemberships([
        EstablishmentMember(
          uid: 'uid-test',
          establishmentId: _establishmentId,
          phone: '33612345678',
          fullName: 'Test Manager',
          role: EstablishmentRole.owner,
          phoneVerified: true,
          joinedAt: DateTime(2026, 1, 1),
        ),
      ]);
      await tester.pumpAndSettle();

      final synced = await remoteClients.get();
      expect(synced.docs, hasLength(1));
      expect(synced.docs.single.data()['name'], 'Client Sync Retardée');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
