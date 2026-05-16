import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/forgot_password_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../widgets/app_states.dart';
import 'forgot_password_widgets.dart';

/// Step 2: enter verification code and set a new password.
class ForgotPasswordConfirmPage extends StatefulWidget {
  const ForgotPasswordConfirmPage({super.key, required this.args});

  final ForgotPasswordConfirmArgs args;

  @override
  State<ForgotPasswordConfirmPage> createState() => _ForgotPasswordConfirmPageState();
}

class _ForgotPasswordConfirmPageState extends State<ForgotPasswordConfirmPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final result = await Get.find<AuthRepository>().confirmForgotPassword(
      username: widget.args.username,
      code: _codeCtrl.text,
      newPassword: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (f) => setState(() => _error = f.message),
      (message) {
        AppSnackBar.showSuccess(context, message);
        context.go(AppRoutes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return ForgotPasswordScaffold(
      child: Form(
        key: _formKey,
        child: ForgotPasswordCard(
          title: 'Forgot password',
          subtitle: 'Enter the code from that pharmacy email and choose a new password.',
          children: [
            ForgotInfoBanner(
              message: args.message,
              maskedEmail: args.maskedEmail,
              devCode: args.devCode,
            ),
            const SizedBox(height: 18),
            if (_error != null) ...[
              ForgotErrorBanner(message: _error!),
              const SizedBox(height: 14),
            ],
            ForgotTextField(
              controller: _codeCtrl,
              label: 'Verification code',
              keyboardType: TextInputType.text,
              maxLength: 8,
              validator: Validators.verificationCode,
            ),
            const SizedBox(height: 14),
            ForgotTextField(
              controller: _passwordCtrl,
              label: 'New password',
              obscureText: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            ForgotTextField(
              controller: _confirmCtrl,
              label: 'Confirm new password',
              obscureText: true,
              validator: (v) => Validators.confirmPassword(_passwordCtrl.text, v),
            ),
            const SizedBox(height: 20),
            ForgotPrimaryButton(
              label: 'Reset password',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 4),
            ForgotTextLink(
              label: 'BACK',
              onTap: () => context.pop(),
            ),
            ForgotTextLink(
              label: 'Back to sign in',
              onTap: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
