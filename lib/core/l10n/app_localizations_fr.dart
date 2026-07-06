// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Gestion Garage';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get logout => 'Déconnexion';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get clients => 'Clients';

  @override
  String get vehicles => 'Véhicules';

  @override
  String get catalog => 'Catalogue';

  @override
  String get prestations => 'Prestations';

  @override
  String get scanClient => 'Scanner client';

  @override
  String get scanToken => 'Scanner jeton boisson';

  @override
  String get alerts => 'Alertes entretien';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get todayPrestations => 'Prestations du jour';

  @override
  String get todayRevenue => 'Chiffre d\'affaires du jour';

  @override
  String get comingSoon => 'Bientôt disponible';
}
