import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/signup_otp_pending_provider.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/phone_verification_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/establishment/presentation/providers/establishment_providers.dart';
import '../../features/clients/presentation/screens/client_form_screen.dart';
import '../../features/clients/presentation/screens/clients_list_screen.dart';
import '../../features/reporting/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/screens/app_shell_screen.dart';
import '../l10n/app_localizations.dart';
import '../presentation/screens/placeholder_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.listen(userProfileProvider, (_, __) => refresh.value++);
  ref.listen(signupOtpPendingProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final profile = ref.read(userProfileProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) return null;

      final isLoggedIn = auth.valueOrNull != null;
      final onLogin = location == Routes.login;
      final onSignUp = location == Routes.signUp;
      final onVerify = location == Routes.verifyPhone;
      final onAuthScreen = onLogin || onSignUp || onVerify;

      if (!isLoggedIn) {
        if (onLogin || onSignUp) return null;
        return Routes.login;
      }

      if (profile.isLoading) return null;

      final phoneVerified = profile.valueOrNull?.phoneVerified ?? false;
      final otpPending = ref.read(signupOtpPendingProvider);

      if (otpPending && !phoneVerified) {
        if (onVerify) return null;
        return Routes.verifyPhone;
      }

      if (onAuthScreen) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.verifyPhone,
        builder: (_, __) => const PhoneVerificationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellScreen(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.clients,
            builder: (_, __) => const ClientsListScreen(),
          ),
          GoRoute(
            path: Routes.clientNew,
            builder: (_, __) => const ClientFormScreen(),
          ),
          GoRoute(
            path: Routes.catalogue,
            builder: (context, __) => PlaceholderScreen(
              title: AppLocalizations.of(context).catalog,
              icon: Icons.menu_book_outlined,
            ),
          ),
          GoRoute(
            path: Routes.prestationScan,
            builder: (context, __) => PlaceholderScreen(
              title: AppLocalizations.of(context).scanClient,
              icon: Icons.qr_code_scanner,
            ),
          ),
          GoRoute(
            path: Routes.jetonScan,
            builder: (context, __) => PlaceholderScreen(
              title: AppLocalizations.of(context).scanToken,
              icon: Icons.local_drink_outlined,
            ),
          ),
          GoRoute(
            path: Routes.alertes,
            builder: (context, __) => PlaceholderScreen(
              title: AppLocalizations.of(context).alerts,
              icon: Icons.notifications_active_outlined,
            ),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
