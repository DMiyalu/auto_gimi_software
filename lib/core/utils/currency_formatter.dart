import 'package:intl/intl.dart';

import '../config/app_config.dart';

/// Formate les montants en USD.
abstract final class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
    locale: 'en_US',
  );

  static String format(double amount) => _formatter.format(amount);

  static String get currencyCode => AppConfig.currencyCode;
}
