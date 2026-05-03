/// Fields for `POST /auth/register` (multipart), aligned with the Pharmacy web
/// portal registration form.
class PharmacyRegistrationPayload {
  const PharmacyRegistrationPayload({
    required this.pharmacyLicenseNumber,
    required this.pharmacyName,
    required this.pharmacyAddress,
    required this.pharmacyCity,
    required this.pharmacyState,
    required this.pharmacyPincode,
    required this.pharmacyPhone,
    required this.pharmacyEmail,
    required this.pharmacyGstNumber,
    required this.pharmacyPanNumber,
    required this.pharmacyContactPerson,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.emailVerificationCode,
    required this.panDocumentPath,
    required this.gstDocumentPath,
    required this.licenseDocumentPath,
  });

  final String pharmacyLicenseNumber;
  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyCity;
  final String pharmacyState;
  final String pharmacyPincode;
  final String pharmacyPhone;
  final String pharmacyEmail;
  final String pharmacyGstNumber;
  final String pharmacyPanNumber;
  final String pharmacyContactPerson;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String emailVerificationCode;
  final String panDocumentPath;
  final String gstDocumentPath;
  final String licenseDocumentPath;

  Map<String, String> toFields() => {
        'pharmacy_license_number': pharmacyLicenseNumber,
        'pharmacy_name': pharmacyName,
        'pharmacy_address': pharmacyAddress,
        'pharmacy_city': pharmacyCity,
        'pharmacy_state': pharmacyState,
        'pharmacy_pincode': pharmacyPincode,
        'pharmacy_phone': pharmacyPhone,
        'pharmacy_email': pharmacyEmail,
        'pharmacy_gst_number': pharmacyGstNumber,
        'pharmacy_pan_number': pharmacyPanNumber,
        'pharmacy_contact_person': pharmacyContactPerson,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'email_verification_code': emailVerificationCode,
      };
}

class UniqueFieldResult {
  final bool isUnique;
  final String message;

  const UniqueFieldResult({required this.isUnique, required this.message});

  factory UniqueFieldResult.fromJson(Map<String, dynamic> json) {
    final unique = json['isUnique'] ?? json['is_unique'];
    return UniqueFieldResult(
      isUnique: unique == true || unique == 1,
      message: json['message']?.toString() ?? '',
    );
  }
}

class SendVerificationResult {
  final String message;
  final String? devCode;

  const SendVerificationResult({required this.message, this.devCode});

  factory SendVerificationResult.fromJson(Map<String, dynamic> json) {
    return SendVerificationResult(
      message: json['message']?.toString() ?? 'Verification code sent',
      devCode: json['code']?.toString(),
    );
  }
}
