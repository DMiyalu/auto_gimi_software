import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../providers/signup_otp_pending_provider.dart';
import '../providers/verification_providers.dart';

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
  Timer? _cooldownTimer;
  int _resendCooldown = 0;
  bool _initialCodeSent = false;

  static const _resendDelaySeconds = 60;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeController.dispose();
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

  Future<void> _sendCode({bool showFeedback = true}) async {
    final l10n = AppLocalizations.of(context);
    final result =
        await ref.read(verificationControllerProvider.notifier).sendCode();

    if (!mounted) return;

    if (result != null) {
      _startCooldown();
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

    final otpPending = ref.watch(signupOtpPendingProvider);

    ref.listen(verificationControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.sms_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.verificationTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verificationSubtitle(phone),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      key: const Key('verify_code_field'),
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: l10n.verificationCode,
                        prefixIcon: const Icon(Icons.pin_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.length != 6) {
                          return l10n.verificationCodeInvalid;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _verify(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('verify_submit_button'),
                      onPressed: verificationState.isLoading ? null : _verify,
                      child: verificationState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.verifyCode),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: const Key('verify_resend_button'),
                      onPressed: verificationState.isLoading ||
                              _resendCooldown > 0
                          ? null
                          : () => _sendCode(),
                      child: Text(
                        _resendCooldown > 0
                            ? l10n.resendCodeIn(_resendCooldown)
                            : l10n.resendCode,
                      ),
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
