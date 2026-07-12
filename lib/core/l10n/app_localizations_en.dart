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
