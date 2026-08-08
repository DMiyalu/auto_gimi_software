import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/firebase/firebase_functions_config.dart';
import '../domain/repositories/restaurant_report_mail_repository.dart';

class FirebaseRestaurantReportMailRepository
    implements RestaurantReportMailRepository {
  FirebaseRestaurantReportMailRepository({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(
            region: FirebaseFunctionsConfig.region,
          );

  final FirebaseFunctions _functions;

  @override
  Future<void> sendReport({
    required String establishmentId,
    required String kind,
  }) async {
    final callable = _functions.httpsCallable('sendTestRestaurantReport');
    await callable.call<Map<String, dynamic>>({
      'establishmentId': establishmentId,
      'kind': kind,
    });
  }
}
