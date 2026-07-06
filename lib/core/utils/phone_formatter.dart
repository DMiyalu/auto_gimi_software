/// Normalise et valide un numéro de téléphone au format E.164.
abstract final class PhoneFormatter {
  static final _e164Pattern = RegExp(r'^\+[1-9]\d{6,14}$');

  static bool isValidE164(String phone) => _e164Pattern.hasMatch(phone.trim());

  /// Retire espaces et tirets ; ajoute + si absent (usage basique MVP).
  static String normalize(String phone) {
    var value = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!value.startsWith('+')) {
      value = '+$value';
    }
    return value;
  }
}
