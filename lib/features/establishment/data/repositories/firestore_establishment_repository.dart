import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_invitation.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/establishment_role.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/establishment_repository.dart';

class FirestoreEstablishmentRepository implements EstablishmentRepository {
  FirestoreEstablishmentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _establishments =>
      _firestore.collection('establishments');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _pendingInvitations =>
      _firestore.collection('pendingInvitations');

  CollectionReference<Map<String, dynamic>> get _phoneIndex =>
      _firestore.collection('phoneIndex');

  @override
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    final normalizedPhone = PhoneAuthMapper.normalize(phone);
    final batch = _firestore.batch();
    final userRef = _users.doc(uid);

    batch.set(userRef, {
      'phone': normalizedPhone,
      'fullName': fullName.trim(),
      'establishmentId': '',
      'establishments': const <String>[],
      'establishmentIds': const <String>[],
      'activeEstablishmentId': null,
      'role': 'agent',
      'rolesByEstablishment': const <String, String>{},
      'phoneVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_phoneIndex.doc(normalizedPhone), {
      'uid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<Establishment> createOwnedEstablishment({
    required String ownerId,
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
  }) async {
    final establishmentId = _uuid.v4();
    final normalizedPhone = PhoneAuthMapper.normalize(phone);
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    final establishmentRef = _establishments.doc(establishmentId);
    final userRef = _users.doc(ownerId);
    final userSnapshot = await userRef.get();

    batch.set(establishmentRef, {
      'name': establishmentName.trim(),
      'category': category.firestoreValue,
      'ownerId': ownerId,
      'managerName': managerName.trim(),
      'phone': normalizedPhone,
      'phoneVerified': false,
      'logoBase64': null,
      'invoiceHeaderLines': const <String>[],
      'invoiceFooterLines': const <String>[],
      'createdAt': now,
      'updatedAt': now,
    });

    if (userSnapshot.exists) {
      final currentLegacyId =
          userSnapshot.data()?['establishmentId'] as String?;
      batch.update(userRef, {
        if (currentLegacyId == null || currentLegacyId.isEmpty)
          'establishmentId': establishmentId,
        'establishments': FieldValue.arrayUnion([establishmentId]),
        'establishmentIds': FieldValue.arrayUnion([establishmentId]),
        'activeEstablishmentId': establishmentId,
        'rolesByEstablishment.$establishmentId': 'owner',
        'updatedAt': now,
      });
    } else {
      batch.set(userRef, {
        'phone': normalizedPhone,
        'fullName': managerName.trim(),
        'establishmentId': establishmentId,
        'establishments': [establishmentId],
        'establishmentIds': [establishmentId],
        'activeEstablishmentId': establishmentId,
        'role': 'owner',
        'rolesByEstablishment': {establishmentId: 'owner'},
        'phoneVerified': false,
        'createdAt': now,
        'updatedAt': now,
      });
      batch.set(_phoneIndex.doc(normalizedPhone), {
        'uid': ownerId,
        'updatedAt': now,
      });
    }

    final teamPayload = {
      'userId': ownerId,
      'roleId': 'owner',
      'uid': ownerId,
      'establishmentId': establishmentId,
      'phone': normalizedPhone,
      'fullName': managerName.trim(),
      'role': 'owner',
      'phoneVerified': false,
      'joinedAt': now,
    };
    batch.set(establishmentRef.collection('team').doc(ownerId), teamPayload);
    // Migration douce : miroir legacy `members`.
    batch.set(establishmentRef.collection('members').doc(ownerId), teamPayload);

    await batch.commit();

    final snapshot = await establishmentRef.get();
    return _establishmentFromSnapshot(snapshot);
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return _userProfileFromSnapshot(snapshot);
    });
  }

  @override
  Stream<Establishment?> watchEstablishment(String establishmentId) {
    return _establishments.doc(establishmentId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return _establishmentFromSnapshot(snapshot);
    });
  }

  @override
  Stream<List<Establishment>> watchUserEstablishments(String uid) {
    return watchUserProfile(uid).asyncMap((profile) async {
      if (profile == null) return const <Establishment>[];

      final validIds = profile.establishments
          .where((id) => id.isNotEmpty)
          .toList();
      if (validIds.isEmpty) return const <Establishment>[];

      final snapshots = await Future.wait(
        validIds.map((id) => _establishments.doc(id).get()),
      );

      return snapshots
          .where((snapshot) => snapshot.exists)
          .map(_establishmentFromSnapshot)
          .toList();
    });
  }

  @override
  Stream<List<EstablishmentMember>> watchUserMemberships(String uid) {
    return watchUserProfile(uid).asyncMap((profile) async {
      if (profile == null) return const <EstablishmentMember>[];

      final validIds = profile.establishments
          .where((id) => id.isNotEmpty)
          .toList();
      if (validIds.isEmpty) return const <EstablishmentMember>[];

      final members = <EstablishmentMember>[];
      for (final id in validIds) {
        final member = await _readTeamOrMember(establishmentId: id, uid: uid);
        if (member != null) members.add(member);
      }
      return members;
    });
  }

  @override
  Stream<List<EstablishmentMember>> watchEstablishmentMembers(
    String establishmentId,
  ) {
    final teamStream = _establishments
        .doc(establishmentId)
        .collection('team')
        .snapshots();

    return teamStream.asyncMap((teamSnapshot) async {
      if (teamSnapshot.docs.isNotEmpty) {
        return teamSnapshot.docs.map(_memberFromSnapshot).toList();
      }

      // Fallback legacy `members` pendant la migration.
      final membersSnapshot = await _establishments
          .doc(establishmentId)
          .collection('members')
          .get();
      return membersSnapshot.docs.map(_memberFromSnapshot).toList();
    });
  }

  @override
  Stream<List<EstablishmentInvitation>> watchPendingInvitations(String uid) {
    return _users
        .doc(uid)
        .collection('invitations')
        .where(
          'status',
          isEqualTo: EstablishmentInvitationStatus.pending.firestoreValue,
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_invitationFromSnapshot).toList());
  }

  @override
  Future<void> claimPendingInvitations({
    required String uid,
    required String phone,
  }) async {
    final normalizedPhone = PhoneAuthMapper.normalize(phone);
    final pending = await _pendingInvitations
        .where('invitedPhone', isEqualTo: normalizedPhone)
        .where(
          'status',
          isEqualTo: EstablishmentInvitationStatus.pending.firestoreValue,
        )
        .get();

    if (pending.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in pending.docs) {
      final data = doc.data();
      final inboxRef = _users.doc(uid).collection('invitations').doc(doc.id);
      batch.set(inboxRef, {
        ...data,
        'claimedFromPending': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      batch.update(doc.reference, {
        'status': 'claimed',
        'claimedBy': uid,
        'claimedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> createInvitation({
    required String establishmentId,
    required String establishmentName,
    required String invitedPhone,
    required EstablishmentRole role,
    required String invitedBy,
    required String invitedByName,
  }) async {
    if (role == EstablishmentRole.owner) {
      throw StateError('Impossible d’inviter avec le rôle propriétaire.');
    }

    final normalizedPhone = PhoneAuthMapper.normalize(invitedPhone);
    final invitationId = _uuid.v4();
    final payload = {
      'establishmentId': establishmentId,
      'establishmentName': establishmentName,
      'invitedPhone': normalizedPhone,
      'roleId': role.firestoreValue,
      'role': role.firestoreValue,
      'status': EstablishmentInvitationStatus.pending.firestoreValue,
      'invitedBy': invitedBy,
      'invitedByName': invitedByName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final phoneLookup = await _phoneIndex.doc(normalizedPhone).get();
    final existingUid = phoneLookup.data()?['uid'] as String?;

    if (existingUid != null && existingUid.isNotEmpty) {
      await _users
          .doc(existingUid)
          .collection('invitations')
          .doc(invitationId)
          .set(payload);
      return;
    }

    await _pendingInvitations.doc(invitationId).set(payload);
  }

  @override
  Future<void> acceptInvitation({
    required String uid,
    required String fullName,
    required String phone,
    required EstablishmentInvitation invitation,
  }) async {
    final normalizedPhone = PhoneAuthMapper.normalize(phone);
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    final userRef = _users.doc(uid);
    final establishmentRef = _establishments.doc(invitation.establishmentId);
    final invitationRef = userRef
        .collection('invitations')
        .doc(invitation.id);
    final teamRef = establishmentRef.collection('team').doc(uid);
    final membersRef = establishmentRef.collection('members').doc(uid);

    final teamPayload = {
      'userId': uid,
      'roleId': invitation.role.firestoreValue,
      'uid': uid,
      'establishmentId': invitation.establishmentId,
      'phone': normalizedPhone,
      'fullName': fullName.trim(),
      'role': invitation.role.firestoreValue,
      'sourceInvitationId': invitation.id,
      'phoneVerified': true,
      'joinedAt': now,
    };

    batch.set(teamRef, teamPayload, SetOptions(merge: true));
    batch.set(membersRef, teamPayload, SetOptions(merge: true));

    batch.set(userRef, {
      'phone': normalizedPhone,
      'fullName': fullName.trim(),
      'establishmentId': invitation.establishmentId,
      'establishments': FieldValue.arrayUnion([invitation.establishmentId]),
      'establishmentIds': FieldValue.arrayUnion([invitation.establishmentId]),
      // Ne force pas l'entrée dans l'activité : la landing gère le switch.
      'rolesByEstablishment.${invitation.establishmentId}':
          invitation.role.firestoreValue,
      'phoneVerified': true,
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.set(_phoneIndex.doc(normalizedPhone), {
      'uid': uid,
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.update(invitationRef, {
      'status': EstablishmentInvitationStatus.accepted.firestoreValue,
      'acceptedBy': uid,
      'acceptedAt': now,
      'updatedAt': now,
    });

    await batch.commit();
  }

  @override
  Future<void> refuseInvitation({
    required String uid,
    required EstablishmentInvitation invitation,
  }) async {
    await _users.doc(uid).collection('invitations').doc(invitation.id).update({
      'status': EstablishmentInvitationStatus.revoked.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  }) async {
    await _users.doc(uid).update({
      'activeEstablishmentId': establishmentId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUserFullName({
    required String uid,
    required String fullName,
  }) async {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Le nom ne peut pas être vide.');
    }
    await _users.doc(uid).update({
      'fullName': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUserEmail({
    required String uid,
    required String email,
  }) async {
    final trimmed = email.trim();
    if (!UserProfile.isValidReportEmail(trimmed)) {
      throw ArgumentError('Adresse e-mail invalide.');
    }
    await _users.doc(uid).update({
      'email': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<EstablishmentMember?> _readTeamOrMember({
    required String establishmentId,
    required String uid,
  }) async {
    final teamSnap = await _establishments
        .doc(establishmentId)
        .collection('team')
        .doc(uid)
        .get();
    if (teamSnap.exists) return _memberFromSnapshot(teamSnap);

    final memberSnap = await _establishments
        .doc(establishmentId)
        .collection('members')
        .doc(uid)
        .get();
    if (memberSnap.exists) return _memberFromSnapshot(memberSnap);
    return null;
  }

  @override
  Future<void> updateEstablishmentSettings({
    required String establishmentId,
    required String name,
    String? logoBase64,
    bool clearLogo = false,
    required List<String> invoiceHeaderLines,
    required List<String> invoiceFooterLines,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom de l’établissement est obligatoire.');
    }

    final payload = <String, dynamic>{
      'name': trimmedName,
      'invoiceHeaderLines': Establishment.sanitizeInvoiceLines(
        invoiceHeaderLines,
      ),
      'invoiceFooterLines': Establishment.sanitizeInvoiceLines(
        invoiceFooterLines,
      ),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (clearLogo) {
      payload['logoBase64'] = null;
    } else if (logoBase64 != null) {
      payload['logoBase64'] = logoBase64;
    }

    await _establishments.doc(establishmentId).update(payload);
  }

  Establishment _establishmentFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Establishment(
      id: snapshot.id,
      name: data['name'] as String,
      category: BusinessCategory.fromFirestore(data['category'] as String),
      ownerId: data['ownerId'] as String,
      managerName: data['managerName'] as String,
      phone: data['phone'] as String,
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      createdAt: _timestampToDateTime(data['createdAt']),
      logoBase64: data['logoBase64'] as String?,
      invoiceHeaderLines: _stringList(data['invoiceHeaderLines']),
      invoiceFooterLines: _stringList(data['invoiceFooterLines']),
    );
  }

  UserProfile _userProfileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    final legacyEstablishmentId = data['establishmentId'] as String? ?? '';
    final establishments = _stringList(data['establishments']);
    final establishmentIds = _stringList(data['establishmentIds']);
    final resolvedIds = establishments.isNotEmpty
        ? establishments
        : establishmentIds;
    final rolesByEstablishment = _stringMap(data['rolesByEstablishment']);
    final activeEstablishmentId = data['activeEstablishmentId'] as String?;

    return UserProfile(
      uid: snapshot.id,
      phone: data['phone'] as String,
      fullName: data['fullName'] as String,
      email: data['email'] as String?,
      establishmentId: legacyEstablishmentId,
      role: data['role'] as String? ?? 'agent',
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      createdAt: _timestampToDateTime(data['createdAt']),
      establishmentIds:
          resolvedIds.isEmpty && legacyEstablishmentId.isNotEmpty
          ? [legacyEstablishmentId]
          : resolvedIds,
      activeEstablishmentId: activeEstablishmentId,
      rolesByEstablishment: rolesByEstablishment,
    );
  }

  EstablishmentMember _memberFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    final establishmentId =
        data['establishmentId'] as String? ??
        snapshot.reference.parent.parent?.id ??
        '';
    return EstablishmentMember(
      uid: data['userId'] as String? ?? data['uid'] as String? ?? snapshot.id,
      establishmentId: establishmentId,
      phone: data['phone'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: EstablishmentRole.fromFirestore(
        data['roleId'] as String? ?? data['role'] as String?,
      ),
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      joinedAt: _timestampToDateTime(data['joinedAt']),
    );
  }

  EstablishmentInvitation _invitationFromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return EstablishmentInvitation(
      id: snapshot.id,
      establishmentId: data['establishmentId'] as String? ?? '',
      establishmentName: data['establishmentName'] as String? ?? '',
      invitedPhone: data['invitedPhone'] as String? ?? '',
      role: EstablishmentRole.fromFirestore(
        data['roleId'] as String? ?? data['role'] as String?,
      ),
      status: EstablishmentInvitationStatus.fromFirestore(
        data['status'] as String?,
      ),
      invitedBy: data['invitedBy'] as String? ?? '',
      invitedByName: data['invitedByName'] as String? ?? '',
      createdAt: _timestampToDateTime(data['createdAt']),
      acceptedBy: data['acceptedBy'] as String?,
      acceptedAt: data['acceptedAt'] == null
          ? null
          : _timestampToDateTime(data['acceptedAt']),
    );
  }

  DateTime _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return const {};
    return value.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }
}
