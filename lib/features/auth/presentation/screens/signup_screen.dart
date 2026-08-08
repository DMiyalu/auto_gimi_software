import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_brand_chrome.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  String _phone = '';
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signUp(
          fullName: _fullNameController.text,
          phone: _phone,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

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
                          onPressed: authState.isLoading
                              ? null
                              : () => context.go(Routes.login),
                        ),
                        const SizedBox(height: 8),
                        const AuthBrandHeader(),
                        const SizedBox(height: 22),
                        const SignUpStepper(currentStep: 1),
                        const SizedBox(height: 26),
                        Text(
                          l10n.signUpTitle,
                          style: const TextStyle(
                            color: AppColors.zuriNavy,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.signUpFormSubtitle,
                          style: const TextStyle(
                            color: authMutedColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22),
                        DecoratedBox(
                          decoration: authSoftCardDecoration,
                          child: TextFormField(
                            controller: _fullNameController,
                            enabled: !authState.isLoading,
                            decoration: authFieldDecoration(
                              labelText: l10n.fullName,
                              prefixIcon: Icons.person_outline_rounded,
                              hintText: l10n.fullNameHint,
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? l10n.fullName
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        DecoratedBox(
                          decoration: authSoftCardDecoration,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, top: 18),
                                  child: Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.zuriRed,
                                    size: 22,
                                  ),
                                ),
                                Expanded(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      inputDecorationTheme:
                                          const InputDecorationTheme(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                      ),
                                    ),
                                    child: PhoneNumberField(
                                      key: const Key('signup_phone_field'),
                                      labelText: l10n.phoneShort,
                                      enabled: !authState.isLoading,
                                      localNumberKey: const Key(
                                        'signup_phone_local_field',
                                      ),
                                      onFullNumberChanged: (value) =>
                                          _phone = value,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return l10n.phoneNumber;
                                        }
                                        if (!PhoneAuthMapper.isValidFullNumber(
                                          value,
                                        )) {
                                          return l10n.phoneNumberInvalid;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DecoratedBox(
                          decoration: authSoftCardDecoration,
                          child: TextFormField(
                            controller: _passwordController,
                            enabled: !authState.isLoading,
                            decoration: authFieldDecoration(
                              labelText: l10n.password,
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: authMutedColor,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.password;
                              if (v.length < 6) return l10n.passwordTooShort;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        DecoratedBox(
                          decoration: authSoftCardDecoration,
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            enabled: !authState.isLoading,
                            decoration: authFieldDecoration(
                              labelText: l10n.confirmPassword,
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: authMutedColor,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l10n.confirmPassword;
                              }
                              if (v != _passwordController.text) {
                                return l10n.passwordsDoNotMatch;
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.zuriPink.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.zuriRed,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.signUpOtpInfo,
                                  style: const TextStyle(
                                    color: AppColors.zuriNavy,
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        AuthPrimaryButton(
                          label: l10n.continueLabel,
                          isLoading: authState.isLoading,
                          onPressed: authState.isLoading ? null : _submit,
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
                                l10n.alreadyHaveAccountShort,
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
                          onPressed: authState.isLoading
                              ? null
                              : () => context.go(Routes.login),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.zuriRed,
                          ),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AuthSecurityFooter(text: l10n.signUpDataSecurity),
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
