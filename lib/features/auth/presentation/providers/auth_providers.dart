import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/sign_up_request.dart';
import 'auth_state_provider.dart';
import 'signup_success_pending_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String phone, String password) async {
    ref.read(signupSuccessPendingProvider.notifier).state = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(phone: phone, password: password);
    });
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            SignUpRequest(fullName: fullName, phone: phone, password: password),
          );
      ref.read(signupSuccessPendingProvider.notifier).state = true;
    });
  }

  Future<void> signOut() async {
    ref.read(signupSuccessPendingProvider.notifier).state = false;
    await ref.read(authRepositoryProvider).signOut();
  }
}
