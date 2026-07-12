import '../models/send_code_result.dart';

abstract class PhoneVerificationRepository {
  Future<SendCodeResult> sendCode(String phone);
  Future<void> verifyCode(String code);
}
