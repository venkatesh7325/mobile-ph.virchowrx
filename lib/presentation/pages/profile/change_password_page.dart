import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

/// Change password while signed in (`PUT /auth/change-password`).
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _success;

  static const Color _primary = Color(0xFF008197);

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _success = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newPassword = _newCtrl.text;
    if (newPassword.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (newPassword != _confirmCtrl.text) {
      setState(() => _error = 'New password and confirmation do not match.');
      return;
    }

    setState(() => _loading = true);
    final result = await Get.find<AuthRepository>().changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: newPassword,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (f) => setState(() => _error = f.message),
      (message) {
        setState(() {
          _success = message;
          _currentCtrl.clear();
          _newCtrl.clear();
          _confirmCtrl.clear();
        });
        AppSnackBar.showSuccess(context, message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Change password',
      currentRoute: AppRoutes.changePassword,
      showCartIcon: false,
      body: Container(
        color: const Color(0xFFF6FBF9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change password',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your current password and a new password for your pharmacy portal account.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        _AlertBanner(message: _error!, isError: true),
                        const SizedBox(height: 16),
                      ],
                      if (_success != null) ...[
                        _AlertBanner(message: _success!, isError: false),
                        const SizedBox(height: 16),
                      ],
                      _PasswordField(
                        controller: _currentCtrl,
                        label: 'Current password',
                        obscure: _obscureCurrent,
                        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        validator: Validators.currentPassword,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _newCtrl,
                        label: 'New password',
                        obscure: _obscureNew,
                        onToggle: () => setState(() => _obscureNew = !_obscureNew),
                        validator: Validators.password,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _confirmCtrl,
                        label: 'Confirm new password',
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => Validators.confirmNewPassword(_newCtrl.text, v),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            disabledBackgroundColor: _primary.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Update password',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
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
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.2),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textLight,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _AlertBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFB91C1C) : const Color(0xFF166534),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: isError ? const Color(0xFFB91C1C) : const Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
