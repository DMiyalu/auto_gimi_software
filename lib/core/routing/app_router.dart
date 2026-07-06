import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/reporting/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/screens/app_shell_screen.dart';
import '../l10n/app_localizations.dart';
import '../presentation/screens/placeholder_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final isLoggedIn = auth.valueOrNull != null;
      final loggingIn = state.matchedLocation == Routes.login;

      if (auth.isLoading) return null;
      if (!isLoggedIn && !loggingIn) return Routes.login;
      if (isLoggedIn && loggingIn) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
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
            builder: (context, __) => PlaceholderScreen(
              title: AppLocalizations.of(context).clients,
              icon: Icons.people_outline,
            ),
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
