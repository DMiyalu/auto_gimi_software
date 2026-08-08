import '../domain/repositories/restaurant_report_mail_repository.dart';

class DisabledRestaurantReportMailRepository
    implements RestaurantReportMailRepository {
  @override
  Future<void> sendReport({
    required String establishmentId,
    required String kind,
  }) async {
    throw StateError(
      'L’envoi de rapport par e-mail nécessite Firebase configuré.',
    );
  }
}
