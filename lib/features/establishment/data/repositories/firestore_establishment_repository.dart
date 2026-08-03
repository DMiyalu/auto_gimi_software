import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/domain/models/sign_up_request.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../domain/models/establishment.dart';
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

  @override
  Future<Establishment> createEstablishmentForOwner({
    required String ownerId,
    required SignUpRequest request,
  }) async {
    final establishmentId = _uuid.v4();
    final phone = PhoneAuthMapper.normalize(request.phone);
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    final establishmentRef = _establishments.doc(establishmentId);
    final userRef = _users.doc(ownerId);
    final userSnapshot = await userRef.get();

    batch.set(establishmentRef, {
      'name': request.establishmentName.trim(),
      'category': request.category.firestoreValue,
      'ownerId': ownerId,
      'managerName': request.managerName.trim(),
      'phone': phone,
      'phoneVerified': false,
      'createdAt': now,
      'updatedAt': now,
    });

    if (userSnapshot.exists) {
      batch.update(userRef, {
        'establishmentIds': FieldValue.arrayUnion([establishmentId]),
        'activeEstablishmentId': establishmentId,
        'rolesByEstablishment.$establishmentId': 'owner',
        'updatedAt': now,
      });
    } else {
      batch.set(userRef, {
        'phone': phone,
        'fullName': request.managerName.trim(),
        'establishmentId': establishmentId,
        'establishmentIds': [establishmentId],
        'activeEstablishmentId': establishmentId,
        'role': 'owner',
        'rolesByEstablishment': {establishmentId: 'owner'},
        'phoneVerified': false,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    batch.set(establishmentRef.collection('members').doc(ownerId), {
      'uid': ownerId,
      'establishmentId': establishmentId,
      'phone': phone,
      'fullName': request.managerName.trim(),
      'role': 'owner',
      'phoneVerified': false,
      'joinedAt': now,
    });

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

      final ids = profile.establishmentIds.isEmpty
          ? [profile.establishmentId]
          : profile.establishmentIds;

      final snapshots = await Future.wait(
        ids.map((id) => _establishments.doc(id).get()),
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

      final ids = profile.establishmentIds.isEmpty
          ? [profile.establishmentId]
          : profile.establishmentIds;

      final snapshots = await Future.wait(
        ids.map(
          (id) => _establishments.doc(id).collection('members').doc(uid).get(),
        ),
      );

      return snapshots
          .where((snapshot) => snapshot.exists)
          .map(_memberFromSnapshot)
          .toList();
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
    );
  }

  UserProfile _userProfileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    final legacyEstablishmentId = data['establishmentId'] as String? ?? '';
    final establishmentIds = _stringList(data['establishmentIds']);
    final rolesByEstablishment = _stringMap(data['rolesByEstablishment']);
    final activeEstablishmentId = data['activeEstablishmentId'] as String?;

    return UserProfile(
      uid: snapshot.id,
      phone: data['phone'] as String,
      fullName: data['fullName'] as String,
      establishmentId: legacyEstablishmentId,
      role: data['role'] as String? ?? 'agent',
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      createdAt: _timestampToDateTime(data['createdAt']),
      establishmentIds:
          establishmentIds.isEmpty && legacyEstablishmentId.isNotEmpty
          ? [legacyEstablishmentId]
          : establishmentIds,
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
      uid: data['uid'] as String? ?? snapshot.id,
      establishmentId: establishmentId,
      phone: data['phone'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: EstablishmentRole.fromFirestore(data['role'] as String?),
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      joinedAt: _timestampToDateTime(data['joinedAt']),
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
