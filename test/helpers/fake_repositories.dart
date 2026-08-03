import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:auto_mobile_software/features/auth/domain/models/sign_up_request.dart';
import 'package:auto_mobile_software/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_member.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/domain/repositories/establishment_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  void setUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String phone, required String password}) async {
    if (_currentUser == null) {
      throw StateError('Aucun utilisateur de test configuré.');
    }
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    if (_currentUser == null) {
      throw StateError('Aucun utilisateur de test configuré.');
    }
  }

  @override
  Future<void> signOut() async {
    setUser(null);
  }
}

class FakeEstablishmentRepository implements EstablishmentRepository {
  UserProfile? profile;
  Establishment? establishment;
  List<Establishment> establishments = const [];
  List<EstablishmentMember> memberships = const [];

  final _profileController = StreamController<UserProfile?>.broadcast();
  final _establishmentController = StreamController<Establishment?>.broadcast();
  final _establishmentsController =
      StreamController<List<Establishment>>.broadcast();
  final _membershipsController =
      StreamController<List<EstablishmentMember>>.broadcast();

  void setProfile(UserProfile value) {
    profile = value;
    _profileController.add(value);
  }

  void setEstablishments(List<Establishment> value) {
    establishments = value;
    _establishmentsController.add(value);
  }

  void setMemberships(List<EstablishmentMember> value) {
    memberships = value;
    _membershipsController.add(value);
  }

  @override
  Future<Establishment> createEstablishmentForOwner({
    required String ownerId,
    required SignUpRequest request,
  }) async {
    throw UnimplementedError();
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) async* {
    yield profile;
    yield* _profileController.stream;
  }

  @override
  Stream<Establishment?> watchEstablishment(String establishmentId) async* {
    yield establishment;
    yield* _establishmentController.stream;
  }

  @override
  Stream<List<Establishment>> watchUserEstablishments(String uid) async* {
    yield establishments.isEmpty && establishment != null
        ? [establishment!]
        : establishments;
    yield* _establishmentsController.stream;
  }

  @override
  Stream<List<EstablishmentMember>> watchUserMemberships(String uid) async* {
    yield memberships;
    yield* _membershipsController.stream;
  }

  @override
  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  }) async {
    final current = profile;
    if (current == null) return;
    profile = UserProfile(
      uid: current.uid,
      phone: current.phone,
      fullName: current.fullName,
      establishmentId: current.establishmentId,
      role: current.role,
      phoneVerified: current.phoneVerified,
      createdAt: current.createdAt,
      establishmentIds: current.establishmentIds,
      activeEstablishmentId: establishmentId,
      rolesByEstablishment: current.rolesByEstablishment,
    );
    _profileController.add(profile);
  }
}
