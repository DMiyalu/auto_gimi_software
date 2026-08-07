import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/features/establishment/data/repositories/firestore_establishment_repository.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_invitation.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreEstablishmentRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreEstablishmentRepository(firestore: firestore);
  });

  test('createUserProfile écrit establishments[] et phoneIndex', () async {
    await repository.createUserProfile(
      uid: 'u1',
      fullName: 'Alice',
      phone: '+243 900 111 222',
    );

    final user = await firestore.collection('users').doc('u1').get();
    expect(user.data()!['establishments'], isEmpty);
    expect(user.data()!['establishmentIds'], isEmpty);
    expect(user.data()!['phone'], '243900111222');

    final index = await firestore
        .collection('phoneIndex')
        .doc('243900111222')
        .get();
    expect(index.data()!['uid'], 'u1');
  });

  test('createOwnedEstablishment écrit team + members (migration douce)', () async {
    await repository.createUserProfile(
      uid: 'owner',
      fullName: 'Boss',
      phone: '243900000001',
    );

    final est = await repository.createOwnedEstablishment(
      ownerId: 'owner',
      category: BusinessCategory.restaurant,
      establishmentName: 'Chez Nous',
      managerName: 'Boss',
      phone: '243900000001',
    );

    final team = await firestore
        .collection('establishments')
        .doc(est.id)
        .collection('team')
        .doc('owner')
        .get();
    expect(team.exists, isTrue);
    expect(team.data()!['userId'], 'owner');
    expect(team.data()!['roleId'], 'owner');

    final members = await firestore
        .collection('establishments')
        .doc(est.id)
        .collection('members')
        .doc('owner')
        .get();
    expect(members.exists, isTrue);

    final user = await firestore.collection('users').doc('owner').get();
    expect(user.data()!['establishments'], contains(est.id));
    expect(user.data()!['establishmentIds'], contains(est.id));
  });

  test(
    'createInvitation écrit dans l’inbox user si phoneIndex existe',
    () async {
      await repository.createUserProfile(
        uid: 'invitee',
        fullName: 'Bob',
        phone: '243900222333',
      );

      await repository.createInvitation(
        establishmentId: 'est-1',
        establishmentName: 'Resto',
        invitedPhone: '243900222333',
        role: EstablishmentRole.agent,
        invitedBy: 'owner',
        invitedByName: 'Boss',
      );

      final inbox = await firestore
          .collection('users')
          .doc('invitee')
          .collection('invitations')
          .get();
      expect(inbox.docs, hasLength(1));
      expect(inbox.docs.first.data()['status'], 'pending');
      expect(inbox.docs.first.data()['roleId'], 'agent');

      final pending = await firestore.collection('pendingInvitations').get();
      expect(pending.docs, isEmpty);
    },
  );

  test(
    'createInvitation écrit pendingInvitations si aucun user pour le téléphone',
    () async {
      await repository.createInvitation(
        establishmentId: 'est-1',
        establishmentName: 'Resto',
        invitedPhone: '243900999888',
        role: EstablishmentRole.manager,
        invitedBy: 'owner',
        invitedByName: 'Boss',
      );

      final pending = await firestore.collection('pendingInvitations').get();
      expect(pending.docs, hasLength(1));
      expect(pending.docs.first.data()['invitedPhone'], '243900999888');
    },
  );

  test('claimPendingInvitations copie vers l’inbox puis marque claimed', () async {
    await firestore.collection('pendingInvitations').doc('inv-p1').set({
      'establishmentId': 'est-1',
      'establishmentName': 'Resto',
      'invitedPhone': '243900444555',
      'roleId': 'agent',
      'role': 'agent',
      'status': 'pending',
      'invitedBy': 'owner',
      'invitedByName': 'Boss',
      'createdAt': DateTime(2026, 1, 1),
    });

    await repository.createUserProfile(
      uid: 'new-user',
      fullName: 'Carla',
      phone: '243900444555',
    );

    await repository.claimPendingInvitations(
      uid: 'new-user',
      phone: '243900444555',
    );

    final inbox = await firestore
        .collection('users')
        .doc('new-user')
        .collection('invitations')
        .doc('inv-p1')
        .get();
    expect(inbox.exists, isTrue);
    expect(inbox.data()!['status'], 'pending');

    final pending = await firestore
        .collection('pendingInvitations')
        .doc('inv-p1')
        .get();
    expect(pending.data()!['status'], 'claimed');
  });

  test('acceptInvitation crée team et ajoute establishments', () async {
    await repository.createUserProfile(
      uid: 'owner',
      fullName: 'Boss',
      phone: '243900000001',
    );
    final est = await repository.createOwnedEstablishment(
      ownerId: 'owner',
      category: BusinessCategory.restaurant,
      establishmentName: 'Resto',
      managerName: 'Boss',
      phone: '243900000001',
    );

    await repository.createUserProfile(
      uid: 'agent',
      fullName: 'Agent',
      phone: '243900777666',
    );

    final invitationId = 'inv-accept';
    await firestore
        .collection('users')
        .doc('agent')
        .collection('invitations')
        .doc(invitationId)
        .set({
          'establishmentId': est.id,
          'establishmentName': 'Resto',
          'invitedPhone': '243900777666',
          'roleId': 'agent',
          'role': 'agent',
          'status': 'pending',
          'invitedBy': 'owner',
          'invitedByName': 'Boss',
          'createdAt': DateTime(2026, 1, 1),
        });

    await repository.acceptInvitation(
      uid: 'agent',
      fullName: 'Agent',
      phone: '243900777666',
      invitation: EstablishmentInvitation(
        id: invitationId,
        establishmentId: est.id,
        establishmentName: 'Resto',
        invitedPhone: '243900777666',
        role: EstablishmentRole.agent,
        status: EstablishmentInvitationStatus.pending,
        invitedBy: 'owner',
        invitedByName: 'Boss',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    final team = await firestore
        .collection('establishments')
        .doc(est.id)
        .collection('team')
        .doc('agent')
        .get();
    expect(team.exists, isTrue);
    expect(team.data()!['roleId'], 'agent');

    final user = await firestore.collection('users').doc('agent').get();
    expect(user.data()!['establishments'], contains(est.id));

    final invitation = await firestore
        .collection('users')
        .doc('agent')
        .collection('invitations')
        .doc(invitationId)
        .get();
    expect(invitation.data()!['status'], 'accepted');
  });

  test('refuseInvitation marque revoked', () async {
    await repository.createUserProfile(
      uid: 'agent',
      fullName: 'Agent',
      phone: '243900111000',
    );
    await firestore
        .collection('users')
        .doc('agent')
        .collection('invitations')
        .doc('inv-r')
        .set({
          'establishmentId': 'est-x',
          'establishmentName': 'X',
          'invitedPhone': '243900111000',
          'roleId': 'manager',
          'status': 'pending',
          'invitedBy': 'owner',
          'invitedByName': 'Boss',
          'createdAt': DateTime(2026, 1, 1),
        });

    await repository.refuseInvitation(
      uid: 'agent',
      invitation: EstablishmentInvitation(
        id: 'inv-r',
        establishmentId: 'est-x',
        establishmentName: 'X',
        invitedPhone: '243900111000',
        role: EstablishmentRole.manager,
        status: EstablishmentInvitationStatus.pending,
        invitedBy: 'owner',
        invitedByName: 'Boss',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    final doc = await firestore
        .collection('users')
        .doc('agent')
        .collection('invitations')
        .doc('inv-r')
        .get();
    expect(doc.data()!['status'], 'revoked');
  });

  test('watchEstablishmentMembers lit team en priorité, sinon members', () async {
    await firestore.collection('establishments').doc('est-legacy').set({
      'name': 'Legacy',
      'category': 'restaurant',
      'ownerId': 'o1',
      'managerName': 'O',
      'phone': '1',
      'phoneVerified': false,
      'createdAt': DateTime(2026, 1, 1),
    });
    await firestore
        .collection('establishments')
        .doc('est-legacy')
        .collection('members')
        .doc('o1')
        .set({
          'uid': 'o1',
          'establishmentId': 'est-legacy',
          'phone': '1',
          'fullName': 'Owner',
          'role': 'owner',
          'phoneVerified': true,
          'joinedAt': DateTime(2026, 1, 1),
        });

    final fromMembers = await repository
        .watchEstablishmentMembers('est-legacy')
        .first;
    expect(fromMembers, hasLength(1));
    expect(fromMembers.first.uid, 'o1');

    await firestore
        .collection('establishments')
        .doc('est-legacy')
        .collection('team')
        .doc('o1')
        .set({
          'userId': 'o1',
          'roleId': 'owner',
          'fullName': 'Owner Team',
          'phone': '1',
          'joinedAt': DateTime(2026, 1, 1),
        });

    final fromTeam = await repository.watchEstablishmentMembers('est-legacy').first;
    expect(fromTeam, hasLength(1));
    expect(fromTeam.first.fullName, 'Owner Team');
  });
}
