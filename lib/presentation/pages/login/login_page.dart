import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../dependency_injection.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/app_states.dart';

// =============================================================================
// VirchowRx — Sign-in screen
// =============================================================================

const _bgDarkest = Color(0xFF052420);
const _bgDeep = Color(0xFF0A3A35);
const _bgMid = Color(0xFF12695F);
const _bgGlow = Color(0xFF2EAB99);

const _teal = Color(0xFF1A8B7E);
const _tealLight = Color(0xFF2BAE9C);

const _ink = Color(0xFF0E2624);
const _muted = Color(0xFF6F7E7C);
const _hint = Color(0xFFA3B0AE);
const _danger = Color(0xFFD93B3B);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    DependencyInjection.bindLogin();
    _controller = Get.find<LoginController>();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    _controller.clearError();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await _controller.login(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      AppSnackBar.showSuccess(context, 'Signed in successfully');
      context.go(AppRoutes.products);
    } else {
      AppSnackBar.showError(
        context,
        _controller.errorMessage.value ?? 'Sign-in failed',
      );
    }
  }

  void _handleForgotPassword() => context.push(AppRoutes.forgotPassword);

  void _handleBiometric() =>
      AppSnackBar.showInfo(context, 'Biometric sign-in not yet implemented');

  void _handleRequestAccount() => context.push(AppRoutes.register);

// ONLY CHANGED PART: LoginPage build method

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgDarkest,
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final cardTop = constraints.maxHeight * 0.18 + 12;

            return Stack(
              children: [
                const Positioned.fill(child: _GradientBackground()),

                // Positioned.fill(
                //   child: IgnorePointer(
                //     child: CustomPaint(painter: _DotPatternPainter()),
                //   ),
                // ),

                // const Positioned(
                //   top: 60,
                //   right: -120,
                //   child: IgnorePointer(child: _RingDecoration()),
                // ),

                // const Positioned(
                //   top: 0,
                //   left: 0,
                //   right: 0,
                //   child: SafeArea(
                //     bottom: false,
                //     child: Padding(
                //       padding: EdgeInsets.fromLTRB(24, 16, 16, 0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           _BrandRow(),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                /// ✅ FIXED SECTION
                Positioned(
                  top: cardTop,
                  left: 0,
                  right: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SafeArea(
                      top: false,
                      child: _LoginCard(
                        formKey: _formKey,
                        controller: _controller,
                        usernameCtrl: _usernameCtrl,
                        passwordCtrl: _passwordCtrl,
                        onSignIn: _handleSignIn,
                        onForgotPassword: _handleForgotPassword,
                        onBiometric: _handleBiometric,
                        onRequestAccount: _handleRequestAccount,
                      ),
                    ),
                  ),
                ),

                // Logo above the login card
                Positioned(
                  top: cardTop - 54,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/virchow_rx_logo.svg',
                        height: 34,
                        fit: BoxFit.contain,
                       // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),

                // Bottom footer: tagline
                // const Positioned(
                //   left: 0,
                //   right: 0,
                //   bottom: 0,
                //   child: SafeArea(
                //     top: false,
                //     child: Padding(
                //       padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           _LoginHeroTagline(),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Background layers
// -----------------------------------------------------------------------------

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.5),
          radius: 1.4,
          colors: [_bgGlow, _bgMid, _bgDeep, _bgDarkest],
          stops: [0.0, 0.30, 0.65, 1.0],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05);
    const spacing = 14.0;
    const radius = 0.7;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingDecoration extends StatelessWidget {
  const _RingDecoration();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 5; i++)
            Container(
              width: 320.0 - i * 50,
              height: 320.0 - i * 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.04 + i * 0.015),
                  width: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.5),
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'HOSPITAL PHARMACY BRIDGE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'EST. SECURE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginHeroTagline extends StatelessWidget {
  const _LoginHeroTagline();

  static const String _text =
      'Trusted hospitals. Reliable distributors. Seamless medical supplies for hospital pharmacies';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Text(
        _text,
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.82),
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Frosted glass login card (Form-validated)
// -----------------------------------------------------------------------------

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginController controller;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onSignIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onBiometric;
  final VoidCallback onRequestAccount;

  const _LoginCard({
    required this.formKey,
    required this.controller,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.onSignIn,
    required this.onForgotPassword,
    required this.onBiometric,
    required this.onRequestAccount,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.50),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 50,
              ),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign in',
                      style: AppTypography.headlineMedium.copyWith(
                        fontSize: 28,
                        color: _ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const _FieldLabel('Username'),
                    const SizedBox(height: 8),
                    _AppTextField(
                      controller: usernameCtrl,
                      hint: 'Username', 
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: Validators.usernameOrPharmacyCode,
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel('Password'),
                    const SizedBox(height: 8),
                    Obx(
                          () => _AppTextField(
                        controller: passwordCtrl,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: controller.obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => onSignIn(),
                        suffix: GestureDetector(
                          onTap: controller.togglePasswordVisibility,
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _muted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onForgotPassword,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _teal,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Inline server-error banner (e.g. "Invalid credentials")
                    Obx(() {
                      final err = controller.errorMessage.value;
                      if (err == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: _InlineError(message: err),
                      );
                    }),

                    const SizedBox(height: 10),

                    Obx(
                          () => _PrimaryButton(
                        label: 'Login',
                        isLoading: controller.isLoading.value,
                        onPressed: onSignIn,
                      ),
                    ),

                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: onRequestAccount,
                        child: const Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // const _OrDivider(),
                    // const SizedBox(height: 18),
                    //
                    // Center(
                    //   child: RichText(
                    //     text: TextSpan(
                    //       style: const TextStyle(
                    //         fontSize: 14,
                    //         color: _muted,
                    //         height: 1.4,
                    //       ),
                    //       children: [
                    //         const TextSpan(text: 'New to VirchowRx?  '),
                    //         TextSpan(
                    //           text: 'Request account →',
                    //           style: const TextStyle(
                    //             color: _teal,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //           recognizer: TapGestureRecognizer()
                    //             ..onTap = onRequestAccount,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 26),
                    //
                    // const _ComplianceFooter(),
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

// -----------------------------------------------------------------------------
// Reusable card components
// -----------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.titleSmall.copyWith(color: _ink, fontWeight: FontWeight.w600),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _danger.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: _danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: AppTypography.bodyLarge.copyWith(fontSize: 15, color: _ink),
      cursorColor: _teal,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyLarge.copyWith(color: _hint, fontSize: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10),
          child: Icon(prefixIcon, color: _muted, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 16), child: suffix),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.transparent),
        focusedBorder: _border(_teal.withOpacity(0.6), width: 1.2),
        errorBorder: _border(_danger),
        focusedErrorBorder: _border(_danger, width: 1.2),
        errorStyle: AppTypography.caption.copyWith(
          color: _danger,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _teal.withOpacity(0.32),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_teal, _tealLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onPressed,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 20),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    final line = Container(height: 1, color: _muted.withOpacity(0.25));
    return Row(
      children: [
        Expanded(child: line),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _muted,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Expanded(child: line),
      ],
    );
  }
}

class _ComplianceFooter extends StatelessWidget {
  const _ComplianceFooter();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ComplianceBadge(icon: Icons.shield_outlined, label: 'ISO 27001'),
          _ComplianceSep(),
          _ComplianceBadge(icon: Icons.verified_outlined, label: 'HIPAA'),
          _ComplianceSep(),
          _ComplianceBadge(icon: null, label: 'GDPR'),
        ],
      ),
    );
  }
}

class _ComplianceBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  const _ComplianceBadge({this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: _muted, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: _muted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceSep extends StatelessWidget {
  const _ComplianceSep();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: _muted.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}