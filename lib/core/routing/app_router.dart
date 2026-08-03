import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/signup_otp_pending_provider.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/phone_verification_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/establishment/presentation/screens/establishment_form_screen.dart';
import '../../features/establishment/presentation/providers/establishment_providers.dart';
import '../../features/establishment/presentation/screens/invitations_screen.dart';
import '../../features/establishment/presentation/screens/invite_member_screen.dart';
import '../../features/establishment/presentation/screens/team_members_screen.dart';
import '../../features/clients/presentation/screens/client_detail_screen.dart';
import '../../features/clients/presentation/screens/client_form_screen.dart';
import '../../features/clients/presentation/screens/clients_list_screen.dart';
import '../../features/garage/presentation/screens/new_prestation_screen.dart';
import '../../features/garage/presentation/screens/prestation_detail_screen.dart';
import '../../features/primary_module/models/activity_item.dart';
import '../../features/primary_module/screens/activity_detail_screen.dart';
import '../../features/primary_module/screens/primary_module_screen.dart';
import '../../features/produits/presentation/screens/product_category_form_screen.dart';
import '../../features/produits/presentation/screens/produit_form_screen.dart';
import '../../features/produits/presentation/screens/produits_screen.dart';
import '../../features/reporting/presentation/screens/dashboard_screen.dart';
import '../../features/services/presentation/screens/service_category_form_screen.dart';
import '../../features/services/presentation/screens/service_form_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/screens/app_shell_screen.dart';
import '../../features/shell/presentation/widgets/more_menu_screen.dart';
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
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.signUp, builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: Routes.verifyPhone,
        builder: (_, __) => const PhoneVerificationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellScreen(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (_, __) => const PrimaryModuleScreen(),
          ),
          GoRoute(
            path: Routes.establishmentNew,
            builder: (_, __) => const EstablishmentFormScreen(),
          ),
          GoRoute(
            path: Routes.invitationNew,
            builder: (_, __) => const InviteMemberScreen(),
          ),
          GoRoute(
            path: Routes.invitations,
            builder: (_, __) => const InvitationsScreen(),
          ),
          GoRoute(
            path: Routes.team,
            builder: (_, __) => const TeamMembersScreen(),
          ),
          GoRoute(
            path: Routes.reports,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.more,
            builder: (_, __) => const MoreMenuScreen(),
          ),
          GoRoute(
            path: Routes.activityDetail,
            builder: (_, state) =>
                ActivityDetailScreen(item: state.extra as ActivityItem?),
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
            path: Routes.clientDetail,
            builder: (_, state) =>
                ClientDetailScreen(clientId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: Routes.clientEdit,
            builder: (_, state) =>
                ClientFormScreen(clientId: state.pathParameters['id']),
          ),
          GoRoute(
            path: Routes.services,
            builder: (_, __) => const ServicesScreen(),
          ),
          GoRoute(
            path: Routes.serviceNew,
            builder: (_, __) => const ServiceFormScreen(),
          ),
          GoRoute(
            path: Routes.serviceEdit,
            builder: (_, state) =>
                ServiceFormScreen(serviceId: state.pathParameters['id']),
          ),
          GoRoute(
            path: Routes.serviceCategoryNew,
            builder: (_, __) => const ServiceCategoryFormScreen(),
          ),
          GoRoute(
            path: Routes.serviceCategoryEdit,
            builder: (_, state) => ServiceCategoryFormScreen(
              categoryId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: Routes.produits,
            builder: (_, __) => const ProduitsScreen(),
          ),
          GoRoute(
            path: Routes.produitNew,
            builder: (_, __) => const ProduitFormScreen(),
          ),
          GoRoute(
            path: Routes.produitEdit,
            builder: (_, state) =>
                ProduitFormScreen(produitId: state.pathParameters['id']),
          ),
          GoRoute(
            path: Routes.productCategoryNew,
            builder: (_, __) => const ProductCategoryFormScreen(),
          ),
          GoRoute(
            path: Routes.productCategoryEdit,
            builder: (_, state) => ProductCategoryFormScreen(
              categoryId: state.pathParameters['id'],
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
            path: Routes.prestationNew,
            builder: (_, __) => const NewPrestationScreen(),
          ),
          GoRoute(
            path: Routes.prestationDetail,
            builder: (_, state) => PrestationDetailScreen(
              prestationId: state.pathParameters['id']!,
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
