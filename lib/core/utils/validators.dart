/// Form validators used by login and other forms.
/// Each validator returns null on valid input, or an error message string.
class Validators {
  Validators._();

  /// Username or pharmacy code. Accepts:
  ///  • Pharmacy code format `PH###` (e.g. PH001, PH042)
  ///  • Plain alphanumeric usernames, 3–32 chars, may contain . _ -
  static String? usernameOrPharmacyCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username or pharmacy code is required';

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
}