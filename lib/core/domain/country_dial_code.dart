/// Pays avec indicatif téléphonique international.
class CountryDialCode {
  const CountryDialCode({
    required this.isoCode,
    required this.name,
    required this.dialCode,
  });

  final String isoCode;
  final String name;
  final String dialCode;

  String get flagEmoji {
    final code = isoCode.toUpperCase();
    if (code.length != 2) return '';
    return String.fromCharCodes(
      code.runes.map((unit) => 0x1F1E6 + unit - 0x41),
    );
  }

  String get displayCode => '+$dialCode';

  @override
  bool operator ==(Object other) =>
      other is CountryDialCode && other.isoCode == isoCode;

  @override
  int get hashCode => isoCode.hashCode;
}

/// Indicatifs supportés (marché international + Afrique francophone).
abstract final class SupportedCountries {
  static const france = CountryDialCode(
    isoCode: 'FR',
    name: 'France',
    dialCode: '33',
  );

  static const senegal = CountryDialCode(
    isoCode: 'SN',
    name: 'Sénégal',
    dialCode: '221',
  );

  static const all = <CountryDialCode>[
    senegal,
    france,
    CountryDialCode(isoCode: 'CI', name: "Côte d'Ivoire", dialCode: '225'),
    CountryDialCode(isoCode: 'CM', name: 'Cameroun', dialCode: '237'),
    CountryDialCode(isoCode: 'CD', name: 'RD Congo', dialCode: '243'),
    CountryDialCode(isoCode: 'ML', name: 'Mali', dialCode: '223'),
    CountryDialCode(isoCode: 'BF', name: 'Burkina Faso', dialCode: '226'),
    CountryDialCode(isoCode: 'GN', name: 'Guinée', dialCode: '224'),
    CountryDialCode(isoCode: 'BJ', name: 'Bénin', dialCode: '229'),
    CountryDialCode(isoCode: 'TG', name: 'Togo', dialCode: '228'),
    CountryDialCode(isoCode: 'GA', name: 'Gabon', dialCode: '241'),
    CountryDialCode(isoCode: 'CG', name: 'Congo', dialCode: '242'),
    CountryDialCode(isoCode: 'MA', name: 'Maroc', dialCode: '212'),
    CountryDialCode(isoCode: 'DZ', name: 'Algérie', dialCode: '213'),
    CountryDialCode(isoCode: 'TN', name: 'Tunisie', dialCode: '216'),
    CountryDialCode(isoCode: 'NG', name: 'Nigeria', dialCode: '234'),
    CountryDialCode(isoCode: 'GH', name: 'Ghana', dialCode: '233'),
    CountryDialCode(isoCode: 'KE', name: 'Kenya', dialCode: '254'),
    CountryDialCode(isoCode: 'ZA', name: 'Afrique du Sud', dialCode: '27'),
    CountryDialCode(isoCode: 'US', name: 'États-Unis', dialCode: '1'),
    CountryDialCode(isoCode: 'CA', name: 'Canada', dialCode: '1'),
    CountryDialCode(isoCode: 'GB', name: 'Royaume-Uni', dialCode: '44'),
    CountryDialCode(isoCode: 'BE', name: 'Belgique', dialCode: '32'),
    CountryDialCode(isoCode: 'CH', name: 'Suisse', dialCode: '41'),
    CountryDialCode(isoCode: 'DE', name: 'Allemagne', dialCode: '49'),
    CountryDialCode(isoCode: 'ES', name: 'Espagne', dialCode: '34'),
    CountryDialCode(isoCode: 'IT', name: 'Italie', dialCode: '39'),
    CountryDialCode(isoCode: 'PT', name: 'Portugal', dialCode: '351'),
    CountryDialCode(isoCode: 'AE', name: 'Émirats arabes unis', dialCode: '971'),
    CountryDialCode(isoCode: 'IN', name: 'Inde', dialCode: '91'),
    CountryDialCode(isoCode: 'CN', name: 'Chine', dialCode: '86'),
  ];

  static CountryDialCode get defaultCountry => senegal;

  static CountryDialCode? findByIso(String isoCode) {
    for (final country in all) {
      if (country.isoCode == isoCode) return country;
    }
    return null;
  }
}
