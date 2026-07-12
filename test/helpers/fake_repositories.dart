import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:auto_mobile_software/features/auth/domain/models/sign_up_request.dart';
import 'package:auto_mobile_software/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
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
  Future<void> signIn({
    required String phone,
    required String password,
  }) async {
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

  final _profileController = StreamController<UserProfile?>.broadcast();
  final _establishmentController = StreamController<Establishment?>.broadcast();

  void setProfile(UserProfile value) {
    profile = value;
    _profileController.add(value);
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
}
