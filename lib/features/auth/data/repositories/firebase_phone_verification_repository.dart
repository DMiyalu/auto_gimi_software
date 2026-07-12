import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/firebase/firebase_functions_config.dart';
import '../../domain/models/send_code_result.dart';
import '../../domain/repositories/phone_verification_repository.dart';

class FirebasePhoneVerificationRepository
    implements PhoneVerificationRepository {
  FirebasePhoneVerificationRepository({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: FirebaseFunctionsConfig.region,
            );

  final FirebaseFunctions _functions;

  @override
  Future<SendCodeResult> sendCode(String phone) async {
    final callable = _functions.httpsCallable('sendVerificationCode');
    final result = await callable.call<Map<String, dynamic>>({
      'phone': PhoneAuthMapper.normalize(phone),
    });
    final data = result.data;

    return SendCodeResult(
      expiresInSeconds: (data['expiresInSeconds'] as num?)?.toInt() ?? 600,
      debugCode: data['debugCode'] as String?,
    );
  }

  @override
  Future<void> verifyCode(String code) async {
    final callable = _functions.httpsCallable('verifyVerificationCode');
    await callable.call<Map<String, dynamic>>({'code': code.trim()});
  }
}
