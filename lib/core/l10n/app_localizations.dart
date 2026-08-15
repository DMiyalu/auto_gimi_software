import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zuri Business'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginWelcome;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginWelcomeSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get continueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithMicrosoft.
  ///
  /// In en, this message translates to:
  /// **'Microsoft'**
  String get continueWithMicrosoft;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get continueWithApple;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// No description provided for @secureAndConfidential.
  ///
  /// In en, this message translates to:
  /// **'Secure and confidential'**
  String get secureAndConfidential;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @productCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get productCategories;

  /// No description provided for @serviceCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get serviceCategories;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @serviceCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get serviceCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service name'**
  String get serviceName;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get priceInvalid;

  /// No description provided for @maintenanceInterval.
  ///
  /// In en, this message translates to:
  /// **'Maintenance interval (days)'**
  String get maintenanceInterval;

  /// No description provided for @maintenanceIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'0 = no maintenance alert'**
  String get maintenanceIntervalHint;

  /// No description provided for @intervalDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String intervalDays(int days);

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get addService;

  /// No description provided for @addProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addProductCategory;

  /// No description provided for @addServiceCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addServiceCategory;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @noProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first product (with or without a category).'**
  String get noProductsHint;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get noServices;

  /// No description provided for @noServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first service (with or without a category).'**
  String get noServicesHint;

  /// No description provided for @noProductCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noProductCategories;

  /// No description provided for @noProductCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Create a category to group your products.'**
  String get noProductCategoriesHint;

  /// No description provided for @noServiceCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noServiceCategories;

  /// No description provided for @noServiceCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Create a category to group your services.'**
  String get noServiceCategoriesHint;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noCategory;

  /// No description provided for @noProductsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No product matches this filter.'**
  String get noProductsMatchFilter;

  /// No description provided for @noServicesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No service matches this filter.'**
  String get noServicesMatchFilter;

  /// No description provided for @productsListTitle.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get productsListTitle;

  /// No description provided for @productFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get productFilterAll;

  /// No description provided for @productInStockShort.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get productInStockShort;

  /// No description provided for @productStockLowShort.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get productStockLowShort;

  /// No description provided for @servicesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Service list'**
  String get servicesListTitle;

  /// No description provided for @searchProductPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search a product...'**
  String get searchProductPlaceholder;

  /// No description provided for @searchServicePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search a service...'**
  String get searchServicePlaceholder;

  /// No description provided for @productStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get productStock;

  /// No description provided for @productStockInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity'**
  String get productStockInvalid;

  /// No description provided for @productFilterOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productFilterOutOfStock;

  /// No description provided for @productInStockLabel.
  ///
  /// In en, this message translates to:
  /// **'In stock ({count})'**
  String productInStockLabel(int count);

  /// No description provided for @productStockLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Low stock ({count})'**
  String productStockLowLabel(int count);

  /// No description provided for @productOutOfStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productOutOfStockLabel;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editService;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this product?'**
  String get deleteProductConfirm;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete service'**
  String get deleteService;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this service?'**
  String get deleteServiceConfirm;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Products/services in this category will become uncategorized. Continue?'**
  String get deleteCategoryConfirm;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s)'**
  String productsCount(int count);

  /// No description provided for @servicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} service(s)'**
  String servicesCount(int count);

  /// No description provided for @productCreated.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productCreated;

  /// No description provided for @serviceCreated.
  ///
  /// In en, this message translates to:
  /// **'Service saved'**
  String get serviceCreated;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get productUpdated;

  /// No description provided for @serviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Service updated'**
  String get serviceUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @serviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted'**
  String get serviceDeleted;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @productCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get productCategoryCreated;

  /// No description provided for @serviceCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get serviceCategoryCreated;

  /// No description provided for @prestations.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get prestations;

  /// No description provided for @scanClient.
  ///
  /// In en, this message translates to:
  /// **'Scan client'**
  String get scanClient;

  /// No description provided for @scanToken.
  ///
  /// In en, this message translates to:
  /// **'Scan drink token'**
  String get scanToken;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Maintenance alerts'**
  String get alerts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @todayPrestations.
  ///
  /// In en, this message translates to:
  /// **'Today\'s services'**
  String get todayPrestations;

  /// No description provided for @todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue'**
  String get todayRevenue;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone, then create or join an establishment.'**
  String get signUpSubtitle;

  /// No description provided for @signUpBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'One account to manage all your establishments.'**
  String get signUpBrandTagline;

  /// No description provided for @signUpFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and phone number to get started.'**
  String get signUpFormSubtitle;

  /// No description provided for @signUpStepInfos.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get signUpStepInfos;

  /// No description provided for @signUpStepVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get signUpStepVerification;

  /// No description provided for @signUpStepDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get signUpStepDone;

  /// No description provided for @signUpOtpInfo.
  ///
  /// In en, this message translates to:
  /// **'A verification code (OTP) will be sent by SMS to confirm your number.'**
  String get signUpOtpInfo;

  /// No description provided for @signUpDataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Your data is secure and will never be shared.'**
  String get signUpDataSecurity;

  /// No description provided for @signUpDataSecurityShort.
  ///
  /// In en, this message translates to:
  /// **'Your data is secure'**
  String get signUpDataSecurityShort;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @alreadyHaveAccountShort.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountShort;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Dieudonné Miyalu'**
  String get fullNameHint;

  /// No description provided for @phoneShort.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneShort;

  /// No description provided for @businessCategory.
  ///
  /// In en, this message translates to:
  /// **'Business category'**
  String get businessCategory;

  /// No description provided for @establishmentName.
  ///
  /// In en, this message translates to:
  /// **'Establishment name'**
  String get establishmentName;

  /// No description provided for @managerName.
  ///
  /// In en, this message translates to:
  /// **'Manager / owner full name'**
  String get managerName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneNumberInvalid;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @categoryRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get categoryRestaurant;

  /// No description provided for @categoryGarageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto repair shop'**
  String get categoryGarageAuto;

  /// No description provided for @categoryPressing.
  ///
  /// In en, this message translates to:
  /// **'Dry cleaning'**
  String get categoryPressing;

  /// No description provided for @categorySanitation.
  ///
  /// In en, this message translates to:
  /// **'Sanitation service'**
  String get categorySanitation;

  /// No description provided for @categoryGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get categoryGym;

  /// No description provided for @categoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get categoryPharmacy;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verificationTitle;

  /// No description provided for @verificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to {phone}.'**
  String verificationSubtitle(String phone);

  /// No description provided for @verificationSubtitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code (OTP) to '**
  String get verificationSubtitlePrefix;

  /// No description provided for @verificationSubtitleSuffix.
  ///
  /// In en, this message translates to:
  /// **' via SMS.'**
  String get verificationSubtitleSuffix;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verificationCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'6-digit code required'**
  String get verificationCodeInvalid;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent via SMS'**
  String get verificationCodeSent;

  /// No description provided for @verificationCodeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {time}'**
  String verificationCodeExpiresIn(String time);

  /// No description provided for @verificationNoCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get verificationNoCode;

  /// No description provided for @verificationSecurityDetail.
  ///
  /// In en, this message translates to:
  /// **'Your information is protected and will never be shared with third parties.'**
  String get verificationSecurityDetail;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get verifyAndContinue;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @signUpSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get signUpSuccessTitle;

  /// No description provided for @signUpSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account was created successfully. You can get started now.'**
  String get signUpSuccessSubtitle;

  /// No description provided for @signUpAccessSpace.
  ///
  /// In en, this message translates to:
  /// **'Go to my workspace'**
  String get signUpAccessSpace;

  /// No description provided for @signUpNextStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'What can you do now?'**
  String get signUpNextStepsTitle;

  /// No description provided for @signUpNextStepEstablishments.
  ///
  /// In en, this message translates to:
  /// **'Add your establishments'**
  String get signUpNextStepEstablishments;

  /// No description provided for @signUpNextStepActivities.
  ///
  /// In en, this message translates to:
  /// **'Track your activities'**
  String get signUpNextStepActivities;

  /// No description provided for @signUpNextStepReports.
  ///
  /// In en, this message translates to:
  /// **'View your reports'**
  String get signUpNextStepReports;

  /// No description provided for @signUpNextStepTeam.
  ///
  /// In en, this message translates to:
  /// **'Manage your team'**
  String get signUpNextStepTeam;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientName;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappNumber;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add client'**
  String get addClient;

  /// No description provided for @saveClient.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveClient;

  /// No description provided for @noClients.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClients;

  /// No description provided for @noClientsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first client with their name and WhatsApp number.'**
  String get noClientsHint;

  /// No description provided for @clientCreated.
  ///
  /// In en, this message translates to:
  /// **'Client saved'**
  String get clientCreated;

  /// No description provided for @clientEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get clientEmail;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get clientAddress;

  /// No description provided for @clientTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Client type'**
  String get clientTypeLabel;

  /// No description provided for @clientTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get clientTypeIndividual;

  /// No description provided for @clientTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get clientTypeBusiness;

  /// No description provided for @clientNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get clientNotes;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit client'**
  String get editClient;

  /// No description provided for @clientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Client updated'**
  String get clientUpdated;

  /// No description provided for @clientDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Client details'**
  String get clientDetailTitle;

  /// No description provided for @tabInformations.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get tabInformations;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered on'**
  String get registeredOn;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get totalOrders;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get modify;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes for this client yet.'**
  String get noNotesYet;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history for this client yet.'**
  String get noHistoryYet;

  /// No description provided for @searchClientPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search a client...'**
  String get searchClientPlaceholder;

  /// No description provided for @clientFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clientFilterAll;

  /// No description provided for @clientFilterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get clientFilterNew;

  /// No description provided for @clientFilterLoyal.
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get clientFilterLoyal;

  /// No description provided for @clientFilterActiveThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Active this month'**
  String get clientFilterActiveThisMonth;

  /// No description provided for @clientFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get clientFilterInactive;

  /// No description provided for @noClientsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No client matches this filter.'**
  String get noClientsMatchFilter;

  /// No description provided for @clientsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Client list'**
  String get clientsListTitle;

  /// No description provided for @recentClientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent clients'**
  String get recentClientsTitle;

  /// No description provided for @clientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} clients'**
  String clientsCount(int count);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clientTierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold member'**
  String get clientTierGold;

  /// No description provided for @clientTierLoyal.
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get clientTierLoyal;

  /// No description provided for @totalOrderedAmount.
  ///
  /// In en, this message translates to:
  /// **'Total ordered'**
  String get totalOrderedAmount;

  /// No description provided for @lastOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Last order'**
  String get lastOrderLabel;

  /// No description provided for @lastOrderAgo.
  ///
  /// In en, this message translates to:
  /// **'Last order: {when}'**
  String lastOrderAgo(String when);

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String relativeDaysAgo(int days);

  /// No description provided for @relativeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} wk ago'**
  String relativeWeeksAgo(int weeks);

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
