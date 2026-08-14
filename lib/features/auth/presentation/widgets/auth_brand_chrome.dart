import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

const authMutedColor = Color(0xFF8A90A5);
const authFieldRadius = 14.0;

BoxDecoration get authSoftCardDecoration => BoxDecoration(
  color: AppColors.zuriWhite,
  borderRadius: BorderRadius.circular(authFieldRadius),
  boxShadow: [
    BoxShadow(
      color: AppColors.zuriNavy.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ],
);

InputDecoration authFieldDecoration({
  required String labelText,
  required IconData prefixIcon,
  String? hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    prefixIcon: Icon(prefixIcon, color: AppColors.zuriRed, size: 22),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.zuriWhite,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(authFieldRadius),
      borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(authFieldRadius),
      borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(authFieldRadius),
      borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(authFieldRadius),
      borderSide: const BorderSide(color: AppColors.zuriRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(authFieldRadius),
      borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.4),
    ),
    labelStyle: const TextStyle(
      color: AppColors.zuriNavy,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
    hintStyle: const TextStyle(color: authMutedColor, fontSize: 14),
  );
}

class AuthBrandBackdrop extends StatelessWidget {
  const AuthBrandBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(
        painter: _AuthBackdropPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _AuthBackdropPainter extends CustomPainter {
  const _AuthBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topRight = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.zuriPink.withValues(alpha: 0.18),
          AppColors.zuriMagenta.withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width, 0),
          radius: size.width * 0.65,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.06),
      size.width * 0.5,
      topRight,
    );

    final bottomLeft = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.zuriMagenta.withValues(alpha: 0.14),
          AppColors.zuriPink.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(0, size.height),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.94),
      size.width * 0.55,
      bottomLeft,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.zuriWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EAF0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.zuriNavy.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              color: AppColors.zuriWhite,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.zuriNavy,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key, this.tagline});

  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Image.asset(
          'public/images/logo.png',
          height: 88,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: const [
              TextSpan(
                text: 'Zuri',
                style: TextStyle(
                  color: AppColors.zuriRed,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: ' Business',
                style: TextStyle(
                  color: AppColors.zuriNavy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          tagline ?? l10n.signUpBrandTagline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: authMutedColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Stepper d'inscription : 1 Infos · 2 Terminé.
class SignUpStepper extends StatelessWidget {
  const SignUpStepper({super.key, required this.currentStep});

  /// 1-based step index (1 or 2).
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.signUpStepInfos,
      l10n.signUpStepDone,
    ];

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: currentStep > i
                    ? AppColors.zuriRed
                    : const Color(0xFFE4E6EE),
              ),
            ),
          _StepNode(
            index: i + 1,
            label: labels[i],
            state: currentStep > i + 1
                ? _StepState.done
                : currentStep == i + 1
                    ? _StepState.active
                    : _StepState.todo,
          ),
        ],
      ],
    );
  }
}

enum _StepState { todo, active, done }

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.index,
    required this.label,
    required this.state,
  });

  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final active = state == _StepState.active;
    final done = state == _StepState.done;
    final color = (active || done) ? AppColors.zuriRed : authMutedColor;

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.zuriRed : AppColors.zuriWhite,
            border: Border.all(
              color: (active || done) ? AppColors.zuriRed : const Color(0xFFD5D8E2),
              width: 1.6,
            ),
          ),
          child: Text(
            '$index',
            style: TextStyle(
              color: active ? AppColors.zuriWhite : color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.zuriRed, AppColors.zuriPink],
          ),
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.zuriWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.zuriWhite,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showArrow) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class AuthSecurityFooter extends StatelessWidget {
  const AuthSecurityFooter({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon ?? Icons.verified_user_outlined,
          size: 14,
          color: AppColors.zuriPink,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: authMutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

String formatPhoneForDisplay(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return raw;

  String groupLocal(String local) {
    if (local.length <= 2) return local;
    if (local.length <= 5) {
      return '${local.substring(0, 2)} ${local.substring(2)}';
    }
    return '${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5)}';
  }

  if (digits.startsWith('243') && digits.length >= 9) {
    return '+243 ${groupLocal(digits.substring(3))}';
  }
  if (digits.startsWith('221') && digits.length >= 9) {
    return '+221 ${groupLocal(digits.substring(3))}';
  }
  if (digits.startsWith('33') && digits.length >= 9) {
    return '+33 ${groupLocal(digits.substring(2))}';
  }
  return '+$digits';
}
