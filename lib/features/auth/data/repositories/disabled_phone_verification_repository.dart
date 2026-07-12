import '../../domain/models/send_code_result.dart';
import '../../domain/repositories/phone_verification_repository.dart';

class DisabledPhoneVerificationRepository
    implements PhoneVerificationRepository {
  @override
  Future<SendCodeResult> sendCode(String phone) async {
    throw StateError(
      'Firebase non configuré. Exécutez: flutterfire configure',
    );
  }

  @override
  Future<void> verifyCode(String code) async {
    throw StateError(
      'Firebase non configuré. Exécutez: flutterfire configure',
    );
  }
}
