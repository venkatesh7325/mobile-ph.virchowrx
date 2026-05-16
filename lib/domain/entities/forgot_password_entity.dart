/// Response from `POST /auth/forgot-password`.
class ForgotPasswordRequestResult {
  const ForgotPasswordRequestResult({
    required this.message,
    this.pharmacyEmailMasked,
    this.devCode,
  });

  final String message;
  final String? pharmacyEmailMasked;
  final String? devCode;

  factory ForgotPasswordRequestResult.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestResult(
      message: json['message']?.toString() ?? 'If an account exists, a code was sent.',
      pharmacyEmailMasked: json['pharmacy_email_masked']?.toString(),
      devCode: json['code']?.toString(),
    );
  }

  bool get canProceedToConfirm =>
      (pharmacyEmailMasked != null && pharmacyEmailMasked!.isNotEmpty) ||
      (devCode != null && devCode!.isNotEmpty);
}

/// Arguments passed to the confirm screen after step 1 succeeds.
class ForgotPasswordConfirmArgs {
  const ForgotPasswordConfirmArgs({
    required this.username,
    required this.message,
    this.maskedEmail,
    this.devCode,
  });

  final String username;
  final String message;
  final String? maskedEmail;
  final String? devCode;
}
