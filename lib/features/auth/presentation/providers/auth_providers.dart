import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/business_category.dart';
import '../../domain/models/sign_up_request.dart';
import 'auth_state_provider.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String phone, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(
            phone: phone,
            password: password,
          );
    });
  }

  Future<void> signUp({
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUp(
            SignUpRequest(
              category: category,
              establishmentName: establishmentName,
              managerName: managerName,
              phone: phone,
              password: password,
            ),
          );
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
