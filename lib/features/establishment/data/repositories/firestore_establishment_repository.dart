import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/domain/models/sign_up_request.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../domain/models/establishment.dart';
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

    batch.set(_users.doc(ownerId), {
      'phone': phone,
      'fullName': request.managerName.trim(),
      'establishmentId': establishmentId,
      'role': 'owner',
      'phoneVerified': false,
      'createdAt': now,
      'updatedAt': now,
    });

    batch.set(establishmentRef.collection('members').doc(ownerId), {
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
    return UserProfile(
      uid: snapshot.id,
      phone: data['phone'] as String,
      fullName: data['fullName'] as String,
      establishmentId: data['establishmentId'] as String,
      role: data['role'] as String,
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      createdAt: _timestampToDateTime(data['createdAt']),
    );
  }

  DateTime _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
