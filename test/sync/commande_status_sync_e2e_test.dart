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
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';

import '../helpers/fake_phone_verification_repository.dart';
import '../helpers/fake_repositories.dart';
import '../helpers/pump_test_app.dart';

class MockFirebaseUser extends Mock implements User {}

const _establishmentId = 'est-restaurant-test';

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
        name: 'Le Goût Parfait',
        category: BusinessCategory.restaurant,
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
          role: 'owner',
          phoneVerified: true,
          createdAt: DateTime(2026, 1, 1),
          establishmentIds: const [_establishmentId],
          activeEstablishmentId: _establishmentId,
          rolesByEstablishment: const {_establishmentId: 'owner'},
        ),
      )
      ..setEstablishments([
        Establishment(
          id: _establishmentId,
          name: 'Le Goût Parfait',
          category: BusinessCategory.restaurant,
          ownerId: 'uid-test',
          managerName: 'Test Manager',
          phone: '221771234567',
          phoneVerified: true,
          createdAt: DateTime(2026, 1, 1),
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

  testWidgets(
    'flux e2e : création de commande synchronisée, puis chaque changement '
    'de statut re-synchronisé automatiquement',
    (tester) async {
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
          // fois pour le push débouncé déclenché après chaque écriture
          // locale (schedulePush, via syncEngineProvider) et pour ses
          // écouteurs temps réel.
          firestoreProvider.overrideWithValue(firestore),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Commandes'), findsWidgets);

      final remoteCommandes = firestore.collection(
        'establishments/$_establishmentId/commandes',
      );

      // 1. Création d'une commande (sans table, pour rester simple) via le
      // vrai flux UI.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Nouvelle commande'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // Visible localement tout de suite, sans attendre le réseau.
      expect(find.text('Ajoutez des produits à la commande'), findsOneWidget);
      expect((await remoteCommandes.get()).docs, isEmpty);

      // Le push est débouncé (~1.5s) après l'écriture locale.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      var synced = await remoteCommandes.get();
      expect(synced.docs, hasLength(1));
      expect(synced.docs.single.data()['statut'], 'en_cours');
      final commandeId = synced.docs.single.id;

      // 2. Encaissement direct (sans facture imprimée) : en_cours -> clôturée.
      await tester.tap(find.text('Encaisser paiement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Argent encaissé'));
      await tester.pumpAndSettle();
      expect(find.text('Mode de paiement'), findsWidgets);
      await tester.tap(find.text('Valider'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Payée'), findsOneWidget);

      // Le nouveau changement de statut doit lui aussi se re-synchroniser
      // automatiquement, sans action manuelle. On évite pumpAndSettle ici :
      // les confettis animent en continu pendant toute leur durée (par
      // design) et ne "se stabilisent" jamais au sens strict attendu par
      // pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      synced = await remoteCommandes.get();
      expect(synced.docs, hasLength(1));
      expect(synced.docs.single.id, commandeId);
      expect(synced.docs.single.data()['statut'], 'cloturee');

      final localRow = await (database.select(
        database.commandes,
      )..where((c) => c.id.equals(commandeId))).getSingle();
      expect(localRow.isDirty, isFalse);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
