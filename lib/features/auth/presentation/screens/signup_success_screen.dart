import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../providers/signup_success_pending_provider.dart';
import '../widgets/auth_brand_chrome.dart';

class SignUpSuccessScreen extends ConsumerWidget {
  const SignUpSuccessScreen({super.key});

  void _continue(WidgetRef ref, BuildContext context) {
    ref.read(signupSuccessPendingProvider.notifier).state = false;
    context.go(Routes.establishmentOnboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final fullName = profile?.fullName ?? '—';
    final phone = formatPhoneForDisplay(profile?.phone ?? '');

    return Scaffold(
      backgroundColor: AppColors.zuriWhite,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBrandBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthBackButton(
                        onPressed: () => _continue(ref, context),
                      ),
                      const SizedBox(height: 8),
                      const AuthBrandHeader(),
                      const SizedBox(height: 22),
                      const SignUpStepper(currentStep: 2),
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.25),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF22C55E),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.signUpSuccessTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.signUpSuccessSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: authMutedColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: authSoftCardDecoration,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppColors.zuriPink.withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.zuriPink,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.fullName,
                                    style: const TextStyle(
                                      color: authMutedColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    fullName,
                                    style: const TextStyle(
                                      color: AppColors.zuriNavy,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.phoneShort,
                                    style: const TextStyle(
                                      color: authMutedColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    phone,
                                    style: const TextStyle(
                                      color: AppColors.zuriNavy,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      AuthPrimaryButton(
                        key: const Key('signup_success_continue_button'),
                        label: l10n.signUpAccessSpace,
                        onPressed: () => _continue(ref, context),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.zuriPink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.zuriRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.signUpNextStepsTitle,
                                    style: const TextStyle(
                                      color: AppColors.zuriNavy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _NextStepRow(
                              icon: Icons.storefront_outlined,
                              label: l10n.signUpNextStepEstablishments,
                            ),
                            _NextStepRow(
                              icon: Icons.assignment_outlined,
                              label: l10n.signUpNextStepActivities,
                            ),
                            _NextStepRow(
                              icon: Icons.bar_chart_rounded,
                              label: l10n.signUpNextStepReports,
                            ),
                            _NextStepRow(
                              icon: Icons.groups_outlined,
                              label: l10n.signUpNextStepTeam,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthSecurityFooter(text: l10n.signUpDataSecurity),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepRow extends StatelessWidget {
  const _NextStepRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.zuriRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.zuriRed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.zuriNavy,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
