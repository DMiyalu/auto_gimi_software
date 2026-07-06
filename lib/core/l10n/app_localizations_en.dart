// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Garage Manager';

  @override
  String get login => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get logout => 'Sign out';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get clients => 'Clients';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get catalog => 'Catalog';

  @override
  String get prestations => 'Services';

  @override
  String get scanClient => 'Scan client';

  @override
  String get scanToken => 'Scan drink token';

  @override
  String get alerts => 'Maintenance alerts';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get todayPrestations => 'Today\'s services';

  @override
  String get todayRevenue => 'Today\'s revenue';

  @override
  String get comingSoon => 'Coming soon';
}
