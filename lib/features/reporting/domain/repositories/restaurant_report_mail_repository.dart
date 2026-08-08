/// Envoi manuel du rapport restaurant par e-mail (Cloud Function).
abstract class RestaurantReportMailRepository {
  /// [kind] : `weekly` ou `monthly`.
  Future<void> sendReport({
    required String establishmentId,
    required String kind,
  });
}
