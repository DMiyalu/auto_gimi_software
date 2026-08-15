import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/sign_up_request.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth désactivée tant que Firebase n'est pas configuré (`flutterfire configure`).
class DisabledAuthRepository implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<void> signIn({required String phone, required String password}) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

  @override
  Future<void> signInWithGoogle() async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

  @override
  Future<void> signOut() async {}
}
