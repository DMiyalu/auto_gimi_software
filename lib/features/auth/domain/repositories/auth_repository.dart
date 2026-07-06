import 'package:firebase_auth/firebase_auth.dart';

/// Contrat d'authentification (couche domaine).
abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}
