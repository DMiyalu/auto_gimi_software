// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Zuri Business';

  @override
  String get login => 'Se connecter';

  @override
  String get loginSubtitle =>
      'Gérez tous vos établissements, depuis un seul endroit.';

  @override
  String get loginWelcome => 'Bienvenue !';

  @override
  String get loginWelcomeSubtitle => 'Connectez-vous à votre compte';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get continueWith => 'ou continuer avec';

  @override
  String get continueWithGoogle => 'Google';

  @override
  String get continueWithMicrosoft => 'Microsoft';

  @override
  String get continueWithApple => 'Apple';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get secureAndConfidential => 'Sécurisé et confidentiel';

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
  String get products => 'Produits';

  @override
  String get services => 'Services';

  @override
  String get productCategories => 'Catégories';

  @override
  String get serviceCategories => 'Catégories';

  @override
  String get productCategory => 'Catégorie';

  @override
  String get serviceCategory => 'Catégorie';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get productName => 'Nom du produit';

  @override
  String get serviceName => 'Nom du service';

  @override
  String get price => 'Prix';

  @override
  String get priceInvalid => 'Prix invalide';

  @override
  String get maintenanceInterval => 'Intervalle d\'entretien (jours)';

  @override
  String get maintenanceIntervalHint => '0 = pas d\'alerte d\'entretien';

  @override
  String intervalDays(int days) {
    return '$days j';
  }

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get addService => 'Ajouter un service';

  @override
  String get addProductCategory => 'Ajouter une catégorie';

  @override
  String get addServiceCategory => 'Ajouter une catégorie';

  @override
  String get save => 'Enregistrer';

  @override
  String get noProducts => 'Aucun produit';

  @override
  String get noProductsHint =>
      'Ajoutez votre premier produit (avec ou sans catégorie).';

  @override
  String get noServices => 'Aucun service';

  @override
  String get noServicesHint =>
      'Ajoutez votre premier service (avec ou sans catégorie).';

  @override
  String get noProductCategories => 'Aucune catégorie';

  @override
  String get noProductCategoriesHint =>
      'Créez une catégorie pour regrouper vos produits.';

  @override
  String get noServiceCategories => 'Aucune catégorie';

  @override
  String get noServiceCategoriesHint =>
      'Créez une catégorie pour regrouper vos services.';

  @override
  String get noCategory => 'Aucune';

  @override
  String get noProductsMatchFilter =>
      'Aucun produit ne correspond à ce filtre.';

  @override
  String get noServicesMatchFilter =>
      'Aucun service ne correspond à ce filtre.';

  @override
  String get productsListTitle => 'Liste des produits';

  @override
  String get servicesListTitle => 'Liste des services';

  @override
  String get searchProductPlaceholder => 'Rechercher un produit...';

  @override
  String get searchServicePlaceholder => 'Rechercher un service...';

  @override
  String get productStock => 'Stock';

  @override
  String get productStockInvalid => 'Quantité invalide';

  @override
  String get productFilterOutOfStock => 'En rupture';

  @override
  String productInStockLabel(int count) {
    return 'En stock ($count)';
  }

  @override
  String productStockLowLabel(int count) {
    return 'Stock faible ($count)';
  }

  @override
  String get productOutOfStockLabel => 'En rupture';

  @override
  String get currency => 'Devise';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get editService => 'Modifier le service';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String get deleteProductConfirm =>
      'Voulez-vous vraiment supprimer ce produit ?';

  @override
  String get deleteService => 'Supprimer le service';

  @override
  String get deleteServiceConfirm =>
      'Voulez-vous vraiment supprimer ce service ?';

  @override
  String get deleteCategory => 'Supprimer la catégorie';

  @override
  String get deleteCategoryConfirm =>
      'Les produits/services de cette catégorie resteront sans catégorie. Continuer ?';

  @override
  String productsCount(int count) {
    return '$count produit(s)';
  }

  @override
  String servicesCount(int count) {
    return '$count service(s)';
  }

  @override
  String get productCreated => 'Produit enregistré';

  @override
  String get serviceCreated => 'Service enregistré';

  @override
  String get productUpdated => 'Produit modifié';

  @override
  String get serviceUpdated => 'Service modifié';

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get serviceDeleted => 'Service supprimé';

  @override
  String get categoryUpdated => 'Catégorie modifiée';

  @override
  String get categoryDeleted => 'Catégorie supprimée';

  @override
  String get productCategoryCreated => 'Catégorie enregistrée';

  @override
  String get serviceCategoryCreated => 'Catégorie enregistrée';

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
  String get theme => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get systemDefault => 'Système';

  @override
  String get todayPrestations => 'Prestations du jour';

  @override
  String get todayRevenue => 'Chiffre d\'affaires du jour';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get signUpTitle => 'Créer votre compte';

  @override
  String get signUpSubtitle =>
      'Vérifiez votre numéro, puis créez ou rejoignez un établissement.';

  @override
  String get signUpBrandTagline =>
      'Un seul compte pour gérer tous vos établissements.';

  @override
  String get signUpFormSubtitle =>
      'Renseignez votre nom et votre numéro de téléphone pour commencer.';

  @override
  String get signUpStepInfos => 'Infos';

  @override
  String get signUpStepVerification => 'Vérification';

  @override
  String get signUpStepDone => 'Terminé';

  @override
  String get signUpOtpInfo =>
      'Un code de vérification (OTP) vous sera envoyé par WhatsApp ou SMS pour confirmer votre numéro.';

  @override
  String get signUpDataSecurity =>
      'Vos données sont sécurisées et ne seront jamais partagées.';

  @override
  String get signUpDataSecurityShort => 'Vos données sont sécurisées';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get alreadyHaveAccountShort => 'Déjà un compte ?';

  @override
  String get fullName => 'Nom complet';

  @override
  String get fullNameHint => 'Ex. : Dieudonné Miyalu';

  @override
  String get phoneShort => 'Téléphone';

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
  String get noAccountYet => 'Vous n\'avez pas de compte ?';

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
  String get verificationTitle => 'Vérifiez votre numéro';

  @override
  String verificationSubtitle(String phone) {
    return 'Un code à 6 chiffres a été envoyé au $phone.';
  }

  @override
  String get verificationSubtitlePrefix =>
      'Nous avons envoyé un code de vérification (OTP) au ';

  @override
  String get verificationSubtitleSuffix => ' via WhatsApp.';

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get verificationCodeInvalid => 'Code à 6 chiffres requis';

  @override
  String get verificationCodeSent => 'Code envoyé par SMS';

  @override
  String verificationCodeExpiresIn(String time) {
    return 'Le code expire dans $time';
  }

  @override
  String get verificationNoCode => 'Vous n’avez pas reçu le code ?';

  @override
  String get verificationSecurityDetail =>
      'Vos informations sont protégées et ne seront jamais partagées avec des tiers.';

  @override
  String get verifyAndContinue => 'Vérifier et continuer';

  @override
  String get needHelp => 'Besoin d’aide ?';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get verifyCode => 'Vérifier';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get signUpSuccessTitle => 'Inscription réussie !';

  @override
  String get signUpSuccessSubtitle =>
      'Votre compte a été créé avec succès. Vous pouvez maintenant commencer.';

  @override
  String get signUpAccessSpace => 'Accéder à mon espace';

  @override
  String get signUpNextStepsTitle => 'Que pouvez-vous faire maintenant ?';

  @override
  String get signUpNextStepEstablishments => 'Ajouter vos établissements';

  @override
  String get signUpNextStepActivities => 'Suivre vos activités';

  @override
  String get signUpNextStepReports => 'Consulter vos rapports';

  @override
  String get signUpNextStepTeam => 'Gérer votre équipe';

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

  @override
  String get clientEmail => 'Email (optionnel)';

  @override
  String get clientAddress => 'Adresse (optionnel)';

  @override
  String get clientTypeLabel => 'Type de client';

  @override
  String get clientTypeIndividual => 'Particulier';

  @override
  String get clientTypeBusiness => 'Entreprise';

  @override
  String get clientNotes => 'Notes (optionnel)';

  @override
  String get editClient => 'Modifier le client';

  @override
  String get clientUpdated => 'Client mis à jour';

  @override
  String get clientDetailTitle => 'Détails client';

  @override
  String get tabInformations => 'Informations';

  @override
  String get tabHistory => 'Historique';

  @override
  String get tabNotes => 'Notes';

  @override
  String get registeredOn => 'Date d\'inscription';

  @override
  String get totalOrders => 'Total commandes';

  @override
  String get totalSpent => 'Total dépensé';

  @override
  String get modify => 'Modifier';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noNotesYet => 'Aucune note pour ce client.';

  @override
  String get noHistoryYet => 'Aucun historique pour ce client.';

  @override
  String get searchClientPlaceholder => 'Rechercher un client...';

  @override
  String get clientFilterAll => 'Tous';

  @override
  String get clientFilterNew => 'Nouveaux';

  @override
  String get clientFilterLoyal => 'Fidèles';

  @override
  String get clientFilterActiveThisMonth => 'Actifs ce mois';

  @override
  String get clientFilterInactive => 'Inactifs';

  @override
  String get noClientsMatchFilter => 'Aucun client ne correspond à ce filtre.';

  @override
  String get clientsListTitle => 'Liste des clients';

  @override
  String get recentClientsTitle => 'Clients récents';

  @override
  String clientsCount(int count) {
    return '$count clients';
  }

  @override
  String get filters => 'Filtres';

  @override
  String get clientTierGold => 'Membre Gold';

  @override
  String get clientTierLoyal => 'Fidèle';

  @override
  String get totalOrderedAmount => 'Total commandé';

  @override
  String get lastOrderLabel => 'Dernière commande';

  @override
  String lastOrderAgo(String when) {
    return 'Dernière commande : $when';
  }

  @override
  String get relativeToday => 'aujourd’hui';

  @override
  String get relativeYesterday => 'hier';

  @override
  String relativeDaysAgo(int days) {
    return 'il y a $days jours';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return 'il y a $weeks sem.';
  }

  @override
  String get noOrdersYet => 'Aucune commande';
}
