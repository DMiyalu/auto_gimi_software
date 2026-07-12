// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Konnect One';

  @override
  String get login => 'Sign in';

  @override
  String get loginSubtitle => 'Manage your sales and services in one place.';

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
  String get products => 'Products';

  @override
  String get services => 'Services';

  @override
  String get productCategories => 'Categories';

  @override
  String get serviceCategories => 'Categories';

  @override
  String get productCategory => 'Category';

  @override
  String get serviceCategory => 'Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get productName => 'Product name';

  @override
  String get serviceName => 'Service name';

  @override
  String get price => 'Price';

  @override
  String get priceInvalid => 'Invalid price';

  @override
  String get maintenanceInterval => 'Maintenance interval (days)';

  @override
  String get maintenanceIntervalHint => '0 = no maintenance alert';

  @override
  String intervalDays(int days) {
    return '$days d';
  }

  @override
  String get addProduct => 'Add product';

  @override
  String get addService => 'Add service';

  @override
  String get addProductCategory => 'Add category';

  @override
  String get addServiceCategory => 'Add category';

  @override
  String get save => 'Save';

  @override
  String get noProducts => 'No products yet';

  @override
  String get noProductsHint =>
      'Create a category first, then add your products.';

  @override
  String get noServices => 'No services yet';

  @override
  String get noServicesHint =>
      'Create a category first, then add your services.';

  @override
  String get noProductCategories => 'No categories yet';

  @override
  String get noProductCategoriesHint =>
      'Create a category to group your products.';

  @override
  String get noServiceCategories => 'No categories yet';

  @override
  String get noServiceCategoriesHint =>
      'Create a category to group your services.';

  @override
  String productsCount(int count) {
    return '$count product(s)';
  }

  @override
  String servicesCount(int count) {
    return '$count service(s)';
  }

  @override
  String get productCreated => 'Product saved';

  @override
  String get serviceCreated => 'Service saved';

  @override
  String get productCategoryCreated => 'Category saved';

  @override
  String get serviceCategoryCreated => 'Category saved';

  @override
  String get createCategoryFirst =>
      'Create a category first before adding an item.';

  @override
  String get prestations => 'Jobs';

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

  @override
  String get signUpTitle => 'Create your establishment';

  @override
  String get signUpSubtitle => 'Sign up and start managing your business.';

  @override
  String get businessCategory => 'Business category';

  @override
  String get establishmentName => 'Establishment name';

  @override
  String get managerName => 'Manager / owner full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberInvalid => 'Invalid phone number';

  @override
  String get createAccount => 'Create my account';

  @override
  String get noAccountYet => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get categoryRestaurant => 'Restaurant';

  @override
  String get categoryGarageAuto => 'Auto repair shop';

  @override
  String get categoryPressing => 'Dry cleaning';

  @override
  String get categorySanitation => 'Sanitation service';

  @override
  String get categoryGym => 'Gym';

  @override
  String get categoryPharmacy => 'Pharmacy';

  @override
  String get verificationTitle => 'Phone verification';

  @override
  String verificationSubtitle(String phone) {
    return 'A 6-digit code was sent to $phone.';
  }

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verificationCodeInvalid => '6-digit code required';

  @override
  String get verificationCodeSent => 'Code sent via SMS';

  @override
  String get verifyCode => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get clientName => 'Client name';

  @override
  String get whatsappNumber => 'WhatsApp number';

  @override
  String get addClient => 'Add client';

  @override
  String get saveClient => 'Save';

  @override
  String get noClients => 'No clients yet';

  @override
  String get noClientsHint =>
      'Add your first client with their name and WhatsApp number.';

  @override
  String get clientCreated => 'Client saved';
}
