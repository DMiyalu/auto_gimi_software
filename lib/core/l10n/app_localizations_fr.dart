// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Konnect One';

  @override
  String get login => 'Connexion';

  @override
  String get loginSubtitle =>
      'Gérez vos ventes et prestations en un seul endroit.';

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

  @override
  String get signUpTitle => 'Créer votre établissement';

  @override
  String get signUpSubtitle =>
      'Inscrivez-vous et commencez à gérer votre activité.';

  @override
  String get businessCategory => 'Catégorie d\'activité';

  @override
  String get establishmentName => 'Nom de l\'établissement';

  @override
  String get managerName => 'Nom complet du gestionnaire / propriétaire';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneNumberInvalid => 'Numéro de téléphone invalide';

  @override
  String get createAccount => 'Créer mon compte';

  @override
  String get noAccountYet => 'Pas encore de compte ? S\'inscrire';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShort => '6 caractères minimum';

  @override
  String get categoryRestaurant => 'Restaurant';

  @override
  String get categoryGarageAuto => 'Garage Auto-Mobile';

  @override
  String get categoryPressing => 'Pressing';

  @override
  String get categorySanitation => 'Service Assainissement';

  @override
  String get categoryGym => 'Salle de sport';

  @override
  String get categoryPharmacy => 'Pharmacie';

  @override
  String get verificationTitle => 'Vérification du numéro';

  @override
  String verificationSubtitle(String phone) {
    return 'Un code à 6 chiffres a été envoyé au $phone.';
  }

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get verificationCodeInvalid => 'Code à 6 chiffres requis';

  @override
  String get verificationCodeSent => 'Code envoyé par SMS';

  @override
  String get verifyCode => 'Vérifier';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get clientName => 'Nom du client';

  @override
  String get whatsappNumber => 'Numéro WhatsApp';

  @override
  String get addClient => 'Ajouter un client';

  @override
  String get saveClient => 'Enregistrer';

  @override
  String get noClients => 'Aucun client';

  @override
  String get noClientsHint =>
      'Ajoutez votre premier client avec son nom et son numéro WhatsApp.';

  @override
  String get clientCreated => 'Client enregistré';
}
