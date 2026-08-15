import 'package:firebase_auth/firebase_auth.dart';

import '../models/sign_up_request.dart';

/// Contrat d'authentification (couche domaine).
abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<void> signIn({required String phone, required String password});
  Future<void> signInWithGoogle();
  Future<void> signUp(SignUpRequest request);
  Future<void> signOut();
}
