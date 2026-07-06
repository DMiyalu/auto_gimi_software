import 'package:intl/intl.dart';

abstract final class DateUtilsHelper {
  static String formatDate(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).format(date);
  }

  static String formatDateTime(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).add_Hm().format(date);
  }
}
