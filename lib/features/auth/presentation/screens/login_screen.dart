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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phone = '';
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const _fieldRadius = 14.0;
  static const _muted = Color(0xFF8A90A5);

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_phone, _passwordController.text);
  }

  InputDecoration _fieldDecoration({
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
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.zuriRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.4),
      ),
      labelStyle: const TextStyle(
        color: AppColors.zuriNavy,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
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
          const Positioned.fill(child: _LoginBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Image.asset(
                          'public/images/logo.png',
                          height: 132,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.zuriNavy,
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.loginWelcome,
                          style: const TextStyle(
                            color: AppColors.zuriNavy,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.loginWelcomeSubtitle,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        DecoratedBox(
                          decoration: _softCardDecoration,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, top: 18),
                                  child: Icon(
                                    Icons.email_outlined,
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
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            filled: false,
                                          ),
                                    ),
                                    child: PhoneNumberField(
                                      key: const Key('login_phone_field'),
                                      labelText: l10n.phoneNumber,
                                      enabled: !authState.isLoading,
                                      localNumberKey: const Key(
                                        'login_phone_local_field',
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
                          decoration: _softCardDecoration,
                          child: TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passwordController,
                            decoration: _fieldDecoration(
                              labelText: l10n.password,
                              prefixIcon: Icons.lock_outline_rounded,
                              hintText: '••••••••••••••',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _muted,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            validator: (v) =>
                                v == null || v.isEmpty ? l10n.password : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: authState.isLoading ? null : () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.zuriPink,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.forgotPassword,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            key: const Key('login_submit_button'),
                            onPressed: authState.isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.zuriRed,
                              foregroundColor: AppColors.zuriWhite,
                              disabledBackgroundColor: AppColors.zuriRed
                                  .withValues(alpha: 0.55),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: authState.isLoading
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
                                        l10n.login,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _OrDivider(label: l10n.continueWith),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SocialLoginButton(
                                label: l10n.continueWithGoogle,
                                leading: const _GoogleMark(),
                                onPressed: authState.isLoading ? null : () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SocialLoginButton(
                                label: l10n.continueWithMicrosoft,
                                leading: const _MicrosoftMark(),
                                onPressed: authState.isLoading ? null : () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SocialLoginButton(
                                label: l10n.continueWithApple,
                                leading: const Icon(
                                  Icons.apple,
                                  size: 18,
                                  color: AppColors.zuriNavy,
                                ),
                                onPressed: authState.isLoading ? null : () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.noAccountYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.go(Routes.signUp),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.zuriPink,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: Text(
                            l10n.loginCreateAccount,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: _muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.secureAndConfidential,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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

BoxDecoration get _softCardDecoration => BoxDecoration(
  color: AppColors.zuriWhite,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: AppColors.zuriNavy.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ],
);

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: const Color(0xFFE4E6EE)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A90A5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      shadowColor: AppColors.zuriNavy.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.zuriNavy,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4285F4),
        height: 1,
      ),
    );
  }
}

class _MicrosoftMark extends StatelessWidget {
  const _MicrosoftMark();

  @override
  Widget build(BuildContext context) {
    const size = 7.0;
    const gap = 1.5;
    Widget tile(Color color) => Container(
      width: size,
      height: size,
      color: color,
    );
    return SizedBox(
      width: size * 2 + gap,
      height: size * 2 + gap,
      child: Column(
        children: [
          Row(
            children: [
              tile(const Color(0xFFF25022)),
              const SizedBox(width: gap),
              tile(const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: gap),
          Row(
            children: [
              tile(const Color(0xFF00A4EF)),
              const SizedBox(width: gap),
              tile(const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _LoginBackdropPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LoginBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.zuriPink.withValues(alpha: 0.16),
          AppColors.zuriMagenta.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.width * 0.7));
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.02), size.width * 0.55, pink);

    final topRight = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.zuriRed.withValues(alpha: 0.10),
          AppColors.zuriPink.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width, 0),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.08),
      size.width * 0.45,
      topRight,
    );

    final bottom = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.zuriMagenta.withValues(alpha: 0.12),
          AppColors.zuriPink.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width, size.height),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.95),
      size.width * 0.55,
      bottom,
    );

    final iconPaint = Paint()
      ..color = AppColors.zuriNavy.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    _drawBag(canvas, Offset(size.width * 0.14, size.height * 0.16), iconPaint);
    _drawCar(canvas, Offset(size.width * 0.78, size.height * 0.14), iconPaint);
    _drawChefHat(canvas, Offset(size.width * 0.22, size.height * 0.28), iconPaint);
    _drawCross(canvas, Offset(size.width * 0.86, size.height * 0.26), iconPaint);
    _drawStore(canvas, Offset(size.width * 0.48, size.height * 0.11), iconPaint);
  }

  void _drawBag(Canvas canvas, Offset c, Paint paint) {
    final path = Path()
      ..moveTo(c.dx - 8, c.dy - 2)
      ..lineTo(c.dx - 8, c.dy + 9)
      ..lineTo(c.dx + 8, c.dy + 9)
      ..lineTo(c.dx + 8, c.dy - 2)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 2), width: 16, height: 12),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  void _drawCar(Canvas canvas, Offset c, Paint paint) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 22, height: 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, paint);
    canvas.drawCircle(Offset(c.dx - 6, c.dy + 6), 2.2, paint);
    canvas.drawCircle(Offset(c.dx + 6, c.dy + 6), 2.2, paint);
  }

  void _drawChefHat(Canvas canvas, Offset c, Paint paint) {
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 2), width: 18, height: 14),
      3.4,
      2.5,
      false,
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, c.dy + 6), width: 14, height: 6),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  void _drawCross(Canvas canvas, Offset c, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 6, height: 16),
        const Radius.circular(1.5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 16, height: 6),
        const Radius.circular(1.5),
      ),
      paint,
    );
  }

  void _drawStore(Canvas canvas, Offset c, Paint paint) {
    final path = Path()
      ..moveTo(c.dx - 10, c.dy)
      ..lineTo(c.dx - 10, c.dy + 10)
      ..lineTo(c.dx + 10, c.dy + 10)
      ..lineTo(c.dx + 10, c.dy)
      ..lineTo(c.dx, c.dy - 8)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
