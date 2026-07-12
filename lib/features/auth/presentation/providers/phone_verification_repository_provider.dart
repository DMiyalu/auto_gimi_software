import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../data/repositories/disabled_phone_verification_repository.dart';
import '../../data/repositories/firebase_phone_verification_repository.dart';
import '../../domain/repositories/phone_verification_repository.dart';

final phoneVerificationRepositoryProvider =
    Provider<PhoneVerificationRepository>((ref) {
  if (isFirebaseConfigured) {
    return FirebasePhoneVerificationRepository();
  }
  return DisabledPhoneVerificationRepository();
});
