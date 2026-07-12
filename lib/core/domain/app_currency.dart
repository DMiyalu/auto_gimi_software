/// Devises supportées pour les prix produits / services.
enum AppCurrency {
  usd('USD', r'$'),
  cdf('CDF', 'FC'),
  eur('EUR', '€');

  const AppCurrency(this.code, this.symbol);

  final String code;
  final String symbol;

  /// Libellé UI (EURO plutôt que EUR).
  String get label => switch (this) {
        AppCurrency.usd => 'USD',
        AppCurrency.cdf => 'CDF',
        AppCurrency.eur => 'EURO',
      };

  static AppCurrency fromCode(String? code) {
    return AppCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => AppCurrency.usd,
    );
  }
}
