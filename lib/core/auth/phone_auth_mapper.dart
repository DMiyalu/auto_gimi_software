/// Mappe un numéro de téléphone vers l'e-mail technique Firebase Auth.
abstract final class PhoneAuthMapper {
  static String normalize(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '');

  static String toAuthEmail(String phone) {
    final digits = normalize(phone);
    if (digits.length < 8) {
      throw ArgumentError('Numéro de téléphone invalide.');
    }
    return '$digits@gimiauto.app';
  }
}
