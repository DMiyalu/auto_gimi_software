import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../data/repositories/disabled_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (isFirebaseConfigured) {
    return FirebaseAuthRepository();
  }
  return DisabledAuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
