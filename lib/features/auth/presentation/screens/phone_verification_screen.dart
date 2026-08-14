import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../providers/signup_otp_pending_provider.dart';
import '../providers/verification_providers.dart';
import '../widgets/auth_brand_chrome.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  Timer? _cooldownTimer;
  Timer? _expiryTimer;
  int _resendCooldown = 0;
  int _expirySeconds = 0;
  bool _initialCodeSent = false;

  static const _resendDelaySeconds = 60;
  static const _expiryDelaySeconds = 180;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _expiryTimer?.cancel();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = _resendDelaySeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown -= 1);
      }
    });
  }

  void _startExpiry() {
    _expiryTimer?.cancel();
    setState(() => _expirySeconds = _expiryDelaySeconds);
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_expirySeconds <= 1) {
        timer.cancel();
        setState(() => _expirySeconds = 0);
      } else {
        setState(() => _expirySeconds -= 1);
      }
    });
  }

  String _formatMmSs(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _sendCode({bool showFeedback = true}) async {
    final l10n = AppLocalizations.of(context);
    final result =
        await ref.read(verificationControllerProvider.notifier).sendCode();

    if (!mounted) return;

    if (result != null) {
      _startCooldown();
      _startExpiry();
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verificationCodeSent)),
        );
      }
      if (kDebugMode && result.debugCode != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug code: ${result.debugCode}'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(verificationControllerProvider.notifier)
        .verifyCode(_codeController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verificationState = ref.watch(verificationControllerProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final phone = profile?.phone ?? '';
    final phoneDisplay = formatPhoneForDisplay(phone);

    final otpPending = ref.watch(signupOtpPendingProvider);

    ref.listen(verificationControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    if (otpPending &&
        profile != null &&
        !profile.phoneVerified &&
        !_initialCodeSent) {
      _initialCodeSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendCode(showFeedback: false);
      });
    }

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthBackButton(
                          onPressed: verificationState.isLoading
                              ? null
                              : () => context.go(Routes.signUp),
                        ),
                        const SizedBox(height: 8),
                        const AuthBrandHeader(),
                        const SizedBox(height: 22),
                        const SignUpStepper(currentStep: 2),
                        const SizedBox(height: 26),
                        Text(
                          l10n.verificationTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.zuriNavy,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              color: authMutedColor,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: l10n.verificationSubtitlePrefix),
                              TextSpan(
                                text: phoneDisplay,
                                style: const TextStyle(
                                  color: AppColors.zuriRed,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(text: l10n.verificationSubtitleSuffix),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 56,
                          child: Stack(
                            children: [
                              _OtpDigitBoxes(
                                controller: _codeController,
                                focusNode: _codeFocus,
                                enabled: !verificationState.isLoading,
                              ),
                              // Champ focusable (saisie, collage, tests).
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.02,
                                  child: TextFormField(
                                    key: const Key('verify_code_field'),
                                    controller: _codeController,
                                    focusNode: _codeFocus,
                                    enabled: !verificationState.isLoading,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    buildCounter: (
                                      _, {
                                      required currentLength,
                                      required isFocused,
                                      required maxLength,
                                    }) =>
                                        const SizedBox.shrink(),
                                    style: const TextStyle(
                                      color: Colors.transparent,
                                      fontSize: 1,
                                    ),
                                    cursorColor: Colors.transparent,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.length != 6) {
                                        return l10n.verificationCodeInvalid;
                                      }
                                      return null;
                                    },
                                    onChanged: (_) => setState(() {}),
                                    onFieldSubmitted: (_) => _verify(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (_expirySeconds > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: AppColors.zuriRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.verificationCodeExpiresIn(
                                  _formatMmSs(_expirySeconds),
                                ),
                                style: const TextStyle(
                                  color: AppColors.zuriRed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              color: authMutedColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(text: '${l10n.verificationNoCode} '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: verificationState.isLoading ||
                                          _resendCooldown > 0
                                      ? null
                                      : () => _sendCode(),
                                  child: Text(
                                    key: const Key('verify_resend_button'),
                                    _resendCooldown > 0
                                        ? l10n.resendCodeIn(_resendCooldown)
                                        : l10n.resendCode,
                                    style: TextStyle(
                                      color: verificationState.isLoading ||
                                              _resendCooldown > 0
                                          ? authMutedColor
                                          : AppColors.zuriRed,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.zuriPink.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.zuriRed,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.secureAndConfidential,
                                      style: const TextStyle(
                                        color: AppColors.zuriNavy,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.verificationSecurityDetail,
                                      style: const TextStyle(
                                        color: authMutedColor,
                                        fontSize: 12.5,
                                        height: 1.35,
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
                          key: const Key('verify_submit_button'),
                          label: l10n.verifyAndContinue,
                          isLoading: verificationState.isLoading,
                          onPressed:
                              verificationState.isLoading ? null : _verify,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFE4E6EE)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                l10n.needHelp,
                                style: const TextStyle(
                                  color: authMutedColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xFFE4E6EE)),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.zuriRed,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: AppColors.zuriPink,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.contactUs,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthSecurityFooter(
                          text: l10n.signUpDataSecurityShort,
                          icon: Icons.lock_outline_rounded,
                        ),
                      ],
                    ),
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

class _OtpDigitBoxes extends StatelessWidget {
  const _OtpDigitBoxes({
    required this.controller,
    required this.focusNode,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final code = controller.text;
    return GestureDetector(
      onTap: enabled ? () => focusNode.requestFocus() : null,
      child: Row(
        children: List.generate(6, (index) {
          final digit = index < code.length ? code[index] : '';
          final focused = focusNode.hasFocus &&
              (code.length == index || (code.length == 6 && index == 5));
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: index == 5 ? 0 : 8),
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.zuriWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused ? AppColors.zuriRed : const Color(0xFFE0E3EC),
                  width: focused ? 1.6 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.zuriNavy.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                digit,
                style: const TextStyle(
                  color: AppColors.zuriNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
