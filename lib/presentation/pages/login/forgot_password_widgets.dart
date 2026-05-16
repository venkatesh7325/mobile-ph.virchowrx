import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const forgotBgDarkest = Color(0xFF052420);
const forgotBgDeep = Color(0xFF0A3A35);
const forgotBgMid = Color(0xFF12695F);
const forgotPrimary = Color(0xFF008197);
const forgotInk = Color(0xFF1A1A1A);
const forgotMuted = Color(0xFF6B7280);
const forgotLink = Color(0xFF2563EB);
const forgotDanger = Color(0xFFB91C1C);

class ForgotPasswordScaffold extends StatelessWidget {
  final Widget child;

  const ForgotPasswordScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: forgotBgDarkest,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const Positioned.fill(child: _ForgotGradientBackground()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    16 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const ForgotPasswordCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: forgotInk,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: forgotMuted,
            ),
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}

class ForgotInfoBanner extends StatelessWidget {
  final String message;
  final String? maskedEmail;
  final String? devCode;

  const ForgotInfoBanner({
    super.key,
    required this.message,
    this.maskedEmail,
    this.devCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: forgotLink, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 13.5, height: 1.4, color: forgotInk),
                ),
                if (maskedEmail != null && maskedEmail!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 13, height: 1.35, color: forgotInk),
                      children: [
                        const TextSpan(text: 'Pharmacy email (masked): '),
                        TextSpan(
                          text: maskedEmail,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
                if (devCode != null && devCode!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 13, height: 1.35, color: forgotInk),
                      children: [
                        const TextSpan(text: 'Development: code is '),
                        TextSpan(
                          text: devCode,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;

  const ForgotTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 15, color: forgotInk),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: forgotInk, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: forgotDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: forgotDanger, width: 1.4),
        ),
      ),
    );
  }
}

class ForgotPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const ForgotPrimaryButton({
    super.key,
    required this.label,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: forgotPrimary,
          disabledBackgroundColor: forgotPrimary.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: forgotPrimary.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

class ForgotTextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ForgotTextLink({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: forgotLink,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ForgotErrorBanner extends StatelessWidget {
  final String message;

  const ForgotErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: forgotDanger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13.5, color: forgotDanger, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotGradientBackground extends StatelessWidget {
  const _ForgotGradientBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [forgotBgDarkest, forgotBgDeep, forgotBgMid],
        ),
      ),
    );
  }
}
