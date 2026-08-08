/// Envoi manuel du rapport restaurant par e-mail (Cloud Function).
abstract class RestaurantReportMailRepository {
  /// [kind] : `daily` | `weekly_current` | `weekly` | `monthly`.
  Future<void> sendReport({
    required String establishmentId,
    required String kind,
  });
}
