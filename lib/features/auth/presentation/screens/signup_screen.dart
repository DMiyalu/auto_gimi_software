import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../../../../core/routing/routes.dart';
import '../providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _establishmentNameController = TextEditingController();
  final _managerNameController = TextEditingController();
  String _phone = '';
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  BusinessCategory _category = BusinessCategory.restaurant;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _establishmentNameController.dispose();
    _managerNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signUp(
          category: _category,
          establishmentName: _establishmentNameController.text,
          managerName: _managerNameController.text,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.signUpTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.signUpSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),
                    DropdownButtonFormField<BusinessCategory>(
                      value: _category,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.businessCategory,
                      ),
                      items: BusinessCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label(l10n)),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (context) {
                        return BusinessCategory.values
                            .map(
                              (category) => Row(
                                children: [
                                  Icon(category.icon, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category.label(l10n),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList();
                      },
                      onChanged: authState.isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _category = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _establishmentNameController,
                      decoration:
                          InputDecoration(labelText: l10n.establishmentName),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? l10n.establishmentName
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _managerNameController,
                      decoration: InputDecoration(labelText: l10n.managerName),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.managerName : null,
                    ),
                    const SizedBox(height: 16),
                    PhoneNumberField(
                      key: const Key('signup_phone_field'),
                      labelText: l10n.phoneNumber,
                      enabled: !authState.isLoading,
                      localNumberKey: const Key('signup_phone_local_field'),
                      onFullNumberChanged: (value) => _phone = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.phoneNumber;
                        }
                        if (!PhoneAuthMapper.isValidFullNumber(value)) {
                          return l10n.phoneNumberInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                        if (v == null || v.isEmpty) return l10n.confirmPassword;
                        if (v != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.createAccount),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.go(Routes.login),
                      child: Text(l10n.alreadyHaveAccount),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
