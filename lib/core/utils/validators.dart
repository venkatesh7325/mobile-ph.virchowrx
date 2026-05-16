/// Form validators used by login and other forms.
/// Each validator returns null on valid input, or an error message string.
class Validators {
  Validators._();

  /// Username or pharmacy code. Accepts:
  ///  • Pharmacy code format `PH###` (e.g. PH001, PH042)
  ///  • Plain alphanumeric usernames, 3–32 chars, may contain . _ -
  static String? usernameOrPharmacyCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username is required';

    final pharmacyCodeRegex = RegExp(r'^PH\d{3,}$', caseSensitive: false);
    if (pharmacyCodeRegex.hasMatch(v)) return null;

    if (v.length < 3) return 'Must be at least 3 characters';
    if (v.length > 32) return 'Must be at most 32 characters';

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
    if (!usernameRegex.hasMatch(v)) {
      return 'Use letters, numbers, dot, underscore or hyphen';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    if (v.length > 64) return 'Password is too long';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\+-]+@[\w-]+\.[\w\.-]+$');
    if (!emailRegex.hasMatch(v)) return 'Please enter a valid email';
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Indian GST: exactly 15 characters (format check kept light for backend validation).
  static String? gstNumber(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return 'GST number is required';
    if (v.length != 15) return 'Must be exactly 15 characters';
    return null;
  }

  /// PAN: 10 chars, standard pattern.
  static String? panNumber(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return 'PAN is required';
    if (v.length != 10) return 'Must be exactly 10 characters';
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(v)) return 'Invalid PAN format';
    return null;
  }

  static String? pincodeIndia(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Pincode is required';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'Enter a valid 6-digit pincode';
    return null;
  }

  static String? latitude(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Latitude is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid latitude';
    if (n < -90 || n > 90) return 'Latitude must be between -90 and 90';
    return null;
  }

  static String? longitude(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Longitude is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid longitude';
    if (n < -180 || n > 180) return 'Longitude must be between -180 and 180';
    return null;
  }

  /// Both coordinates required together (registration / pharmacy location).
  static String? pharmacyCoordinates(String? latitude, String? longitude) {
    final latErr = Validators.latitude(latitude);
    if (latErr != null) return latErr;
    final lngErr = Validators.longitude(longitude);
    if (lngErr != null) return lngErr;
    return null;
  }

  static String? confirmPassword(String? password, String? confirm) {
    final c = confirm ?? '';
    if (c.isEmpty) return 'Confirm password is required';
    if (password != c) return 'Passwords do not match';
    return null;
  }

  /// Matches Pharmacy web change-password confirmation message.
  static String? confirmNewPassword(String? newPassword, String? confirm) {
    final c = confirm ?? '';
    if (c.isEmpty) return 'Confirm new password is required';
    if (newPassword != c) return 'New password and confirmation do not match.';
    return null;
  }

  static String? currentPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Current password is required';
    return null;
  }

  static String? verificationCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Verification code is required';
    if (v.length < 4) return 'Enter the code from your pharmacy email';
    if (v.length > 8) return 'Code is too long';
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(v)) {
      return 'Code must contain only letters and numbers';
    }
    return null;
  }
}
