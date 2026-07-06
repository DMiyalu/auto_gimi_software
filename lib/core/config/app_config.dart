/// Constantes applicatives et configuration garage (single-tenant MVP).
abstract final class AppConfig {
  /// Identifiant Firestore du garage — remplacer après `flutterfire configure`.
  static const String garageId = 'default-garage';

  /// 1 service consommé = 1 point de fidélité.
  static const int pointsPerService = 1;

  /// 10 points = 1 service offert.
  static const int pointsForFreeService = 10;

  /// TVA MVP (0 %).
  static const double tvaRate = 0.0;

  /// Devise facturation.
  static const String currencyCode = 'USD';

  /// Rappel WhatsApp : nombre de jours avant échéance.
  static const int reminderDaysBefore = 2;
}
