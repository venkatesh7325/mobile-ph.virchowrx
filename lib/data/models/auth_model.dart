import '../../domain/entities/auth_entity.dart';

class PharmacyModel extends PharmacyEntity {
  const PharmacyModel({
    required super.id,
    required super.name,
    super.licenseNumber,
    super.address,
    super.city,
    super.state,
    super.pincode,
    super.phone,
    super.email,
    super.gstNumber,
    super.contactPerson,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) => PharmacyModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name']?.toString() ?? '',
    licenseNumber: json['license_number']?.toString(),
    address: json['address']?.toString(),
    city: json['city']?.toString(),
    state: json['state']?.toString(),
    pincode: json['pincode']?.toString(),
    phone: json['phone']?.toString(),
    email: json['email']?.toString(),
    gstNumber: json['gst_number']?.toString(),
    contactPerson: json['contact_person']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'license_number': licenseNumber,
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
    'phone': phone,
    'email': email,
    'gst_number': gstNumber,
    'contact_person': contactPerson,
  };
}

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.token,
    super.firstName,
    super.lastName,
    super.email,
    super.phone,
    super.role,
    super.pharmacy,
  });

  /// Parses the full login response:
  /// { "message": "...", "token": "...", "user": { "id":.., "username":.., "pharmacy": {...} } }
  factory UserModel.fromLoginResponse(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final pharmacyJson = user['pharmacy'] as Map<String, dynamic>?;

    return UserModel(
      id: (user['id'] as num?)?.toInt() ?? 0,
      username: user['username']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      firstName: user['first_name']?.toString(),
      lastName: user['last_name']?.toString(),
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      role: user['role']?.toString(),
      pharmacy: pharmacyJson != null ? PharmacyModel.fromJson(pharmacyJson) : null,
    );
  }

  /// Re-hydrates a saved session from secure storage.
  factory UserModel.fromCachedJson(Map<String, dynamic> json) {
    final pharmacyJson = json['pharmacy'] as Map<String, dynamic>?;
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      pharmacy: pharmacyJson != null
          ? PharmacyModel.fromJson(pharmacyJson)
          : null,
    );
  }

  /// Used when persisting to secure storage.
  Map<String, dynamic> toCachedJson() => {
    'id': id,
    'username': username,
    'token': token,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'role': role,
    'pharmacy': pharmacy is PharmacyModel
        ? (pharmacy as PharmacyModel).toJson()
        : null,
  };
}