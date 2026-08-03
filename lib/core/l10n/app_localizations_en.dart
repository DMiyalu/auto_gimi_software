// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZOLANA';

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
      'Add your first product (with or without a category).';

  @override
  String get noServices => 'No services yet';

  @override
  String get noServicesHint =>
      'Add your first service (with or without a category).';

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
  String get noCategory => 'None';

  @override
  String get noProductsMatchFilter => 'No product matches this filter.';

  @override
  String get noServicesMatchFilter => 'No service matches this filter.';

  @override
  String get productsListTitle => 'Product list';

  @override
  String get servicesListTitle => 'Service list';

  @override
  String get searchProductPlaceholder => 'Search a product...';

  @override
  String get searchServicePlaceholder => 'Search a service...';

  @override
  String get productStock => 'Stock';

  @override
  String get productStockInvalid => 'Invalid quantity';

  @override
  String get productFilterOutOfStock => 'Out of stock';

  @override
  String productInStockLabel(int count) {
    return 'In stock ($count)';
  }

  @override
  String productStockLowLabel(int count) {
    return 'Low stock ($count)';
  }

  @override
  String get productOutOfStockLabel => 'Out of stock';

  @override
  String get currency => 'Currency';

  @override
  String get editProduct => 'Edit product';

  @override
  String get editService => 'Edit service';

  @override
  String get editCategory => 'Edit category';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String get deleteProductConfirm =>
      'Do you really want to delete this product?';

  @override
  String get deleteService => 'Delete service';

  @override
  String get deleteServiceConfirm =>
      'Do you really want to delete this service?';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteCategoryConfirm =>
      'Products/services in this category will become uncategorized. Continue?';

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
  String get productUpdated => 'Product updated';

  @override
  String get serviceUpdated => 'Service updated';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get serviceDeleted => 'Service deleted';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get productCategoryCreated => 'Category saved';

  @override
  String get serviceCategoryCreated => 'Category saved';

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
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get systemDefault => 'System default';

  @override
  String get todayPrestations => 'Today\'s services';

  @override
  String get todayRevenue => 'Today\'s revenue';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle =>
      'Verify your phone, then create or join an establishment.';

  @override
  String get fullName => 'Full name';

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

  @override
  String get clientEmail => 'Email (optional)';

  @override
  String get clientAddress => 'Address (optional)';

  @override
  String get clientTypeLabel => 'Client type';

  @override
  String get clientTypeIndividual => 'Individual';

  @override
  String get clientTypeBusiness => 'Business';

  @override
  String get clientNotes => 'Notes (optional)';

  @override
  String get editClient => 'Edit client';

  @override
  String get clientUpdated => 'Client updated';

  @override
  String get clientDetailTitle => 'Client details';

  @override
  String get tabInformations => 'Information';

  @override
  String get tabHistory => 'History';

  @override
  String get tabNotes => 'Notes';

  @override
  String get registeredOn => 'Registered on';

  @override
  String get totalOrders => 'Total orders';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get modify => 'Edit';

  @override
  String get seeAll => 'See all';

  @override
  String get noNotesYet => 'No notes for this client yet.';

  @override
  String get noHistoryYet => 'No history for this client yet.';

  @override
  String get searchClientPlaceholder => 'Search a client...';

  @override
  String get clientFilterAll => 'All';

  @override
  String get clientFilterNew => 'New';

  @override
  String get clientFilterLoyal => 'Loyal';

  @override
  String get clientFilterActiveThisMonth => 'Active this month';

  @override
  String get clientFilterInactive => 'Inactive';

  @override
  String get noClientsMatchFilter => 'No client matches this filter.';

  @override
  String get clientsListTitle => 'Client list';

  @override
  String clientsCount(int count) {
    return '$count clients';
  }

  @override
  String get filters => 'Filters';

  @override
  String get clientTierGold => 'Gold member';

  @override
  String get clientTierLoyal => 'Loyal';

  @override
  String get totalOrderedAmount => 'Total ordered';

  @override
  String get lastOrderLabel => 'Last order';

  @override
  String get noOrdersYet => 'No orders yet';
}
