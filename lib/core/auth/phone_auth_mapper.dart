/// Mappe un numéro de téléphone vers l'e-mail technique Firebase Auth.
abstract final class PhoneAuthMapper {
  static String normalize(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '');

  /// Combine indicatif pays + numéro local (chiffres uniquement).
  static String combine({
    required String dialCode,
    required String localNumber,
  }) {
    final countryDigits = normalize(dialCode);
    var localDigits = normalize(localNumber);

    if (localDigits.startsWith('0')) {
      localDigits = localDigits.substring(1);
    }

    return '$countryDigits$localDigits';
  }

  static bool isValidFullNumber(String fullDigits) {
    final digits = normalize(fullDigits);
    return digits.length >= 8 && digits.length <= 15;
  }

  static String toAuthEmail(String phone) {
    final digits = normalize(phone);
    if (!isValidFullNumber(digits)) {
      throw ArgumentError('Numéro de téléphone invalide.');
    }
    return '$digits@gimiauto.app';
  }
}
