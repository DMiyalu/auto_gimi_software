import 'package:intl/intl.dart';

import '../domain/app_currency.dart';

/// Formate les montants selon la devise choisie.
abstract final class CurrencyFormatter {
  static String format(double amount, {AppCurrency currency = AppCurrency.usd}) {
    final formatter = NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: 2,
      locale: 'en_US',
    );
    return formatter.format(amount);
  }

  static String formatWithCode(
    double amount, {
    AppCurrency currency = AppCurrency.usd,
  }) {
    return '${format(amount, currency: currency)} ${currency.label}';
  }
}
