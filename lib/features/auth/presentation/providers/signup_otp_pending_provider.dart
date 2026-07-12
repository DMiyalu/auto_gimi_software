import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vrai uniquement après un signup réussi — déclenche l'écran OTP.
/// Le login ne passe pas par la vérification téléphone.
final signupOtpPendingProvider = StateProvider<bool>((ref) => false);
