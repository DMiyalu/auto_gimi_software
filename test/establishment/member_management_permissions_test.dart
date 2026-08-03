import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';
import 'package:auto_mobile_software/features/establishment/presentation/screens/invite_member_screen.dart';
import 'package:auto_mobile_software/features/establishment/presentation/screens/team_members_screen.dart';

import '../helpers/fake_repositories.dart';

class MockFirebaseUser extends Mock implements User {}

void main() {
  final profile = UserProfile(
    uid: 'agent-1',
    phone: '33612345678',
    fullName: 'Agent Zolana',
    establishmentId: 'est-1',
    role: EstablishmentRole.agent.firestoreValue,
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
    establishmentIds: const ['est-1'],
    activeEstablishmentId: 'est-1',
    rolesByEstablishment: {'est-1': EstablishmentRole.agent.firestoreValue},
  );

  final establishment = Establishment(
    id: 'est-1',
    name: 'Garage Zolana',
    category: BusinessCategory.garageAuto,
    ownerId: 'owner-1',
    managerName: 'Amina Kabasele',
    phone: '33612345678',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  Widget testApp(Widget child) {
    return ProviderScope(
      overrides: [canInviteMembersProvider.overrideWithValue(false)],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('un agent ne peut pas ouvrir la gestion equipe', (tester) async {
    await tester.pumpWidget(testApp(const TeamMembersScreen()));

    expect(find.text('Accès limité'), findsOneWidget);
    expect(find.text('Gestion d’équipe réservée'), findsOneWidget);
    expect(find.text('Inviter'), findsNothing);
  });

  testWidgets('un agent ne peut pas ouvrir le formulaire invitation', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const InviteMemberScreen()));

    expect(find.text('Accès limité'), findsOneWidget);
    expect(find.text('Gestion d’équipe réservée'), findsOneWidget);
    expect(find.text('Inviter un membre'), findsNothing);
    expect(find.byKey(const Key('invite_phone_field')), findsNothing);
  });

  test('le controleur refuse la creation invitation sans droit', () async {
    final user = MockFirebaseUser();
    when(() => user.uid).thenReturn('agent-1');

    final repository = FakeEstablishmentRepository();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(establishment),
        ),
        canInviteMembersProvider.overrideWithValue(false),
        establishmentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authStateProvider.future);
    await container.read(userProfileProvider.future);
    await container.read(currentEstablishmentProvider.future);

    await container
        .read(establishmentControllerProvider.notifier)
        .createInvitation(
          role: EstablishmentRole.agent,
          invitedPhone: '33600000000',
        );

    expect(repository.invitations, isEmpty);
    expect(container.read(establishmentControllerProvider).hasError, isTrue);
  });
}
