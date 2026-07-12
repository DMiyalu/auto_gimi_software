import 'package:auto_mobile_software/features/auth/domain/models/send_code_result.dart';
import 'package:auto_mobile_software/features/auth/domain/repositories/phone_verification_repository.dart';

class FakePhoneVerificationRepository implements PhoneVerificationRepository {
  FakePhoneVerificationRepository({this.onVerified});

  static const testCode = '123456';

  final void Function()? onVerified;

  @override
  Future<SendCodeResult> sendCode(String phone) async {
    return const SendCodeResult(
      expiresInSeconds: 600,
      debugCode: testCode,
    );
  }

  @override
  Future<void> verifyCode(String code) async {
    if (code != testCode) {
      throw Exception('Code incorrect.');
    }
    onVerified?.call();
  }
}
