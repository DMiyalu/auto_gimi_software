import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../domain/models/send_code_result.dart';
import 'phone_verification_repository_provider.dart';
import 'signup_otp_pending_provider.dart';

final verificationControllerProvider =
    AsyncNotifierProvider<VerificationController, void>(
  VerificationController.new,
);

class VerificationController extends AsyncNotifier<void> {
  SendCodeResult? lastSendResult;

  @override
  Future<void> build() async {}

  Future<SendCodeResult?> sendCode() async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null) {
      throw StateError('Profil utilisateur introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      lastSendResult = await ref
          .read(phoneVerificationRepositoryProvider)
          .sendCode(profile.phone);
    });
    return lastSendResult;
  }

  Future<void> verifyCode(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(phoneVerificationRepositoryProvider).verifyCode(code);
      ref.read(signupOtpPendingProvider.notifier).state = false;
    });
  }
}
