import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/forgot_password_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'forgot_password_widgets.dart';

/// Step 1: enter username and request a reset code to the pharmacy email on file.
class ForgotPasswordRequestPage extends StatefulWidget {
  const ForgotPasswordRequestPage({super.key});

  @override
  State<ForgotPasswordRequestPage> createState() => _ForgotPasswordRequestPageState();
}

class _ForgotPasswordRequestPageState extends State<ForgotPasswordRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _info = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final result = await Get.find<AuthRepository>().requestForgotPassword(_usernameCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (f) => setState(() => _error = f.message),
      (res) {
        if (res.canProceedToConfirm) {
          context.push(
            AppRoutes.forgotPasswordConfirm,
            extra: ForgotPasswordConfirmArgs(
              username: _usernameCtrl.text.trim(),
              message: res.message,
              maskedEmail: res.pharmacyEmailMasked,
              devCode: res.devCode,
            ),
          );
        } else {
          setState(() => _info = res.message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordScaffold(
      child: Form(
        key: _formKey,
        child: ForgotPasswordCard(
          title: 'Forgot password',
          subtitle:
              'Enter your username. We will email a code to your pharmacy email on file (not your personal login email).',
          children: [
            if (_error != null) ...[
              ForgotErrorBanner(message: _error!),
              const SizedBox(height: 14),
            ],
            if (_info != null) ...[
              ForgotInfoBanner(message: _info!),
              const SizedBox(height: 14),
            ],
            ForgotTextField(
              controller: _usernameCtrl,
              label: 'Username',
              validator: Validators.usernameOrPharmacyCode,
            ),
            const SizedBox(height: 20),
            ForgotPrimaryButton(
              label: 'Send code to pharmacy email',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
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
