import '../../core/errors/exceptions.dart';
import '../../domain/entities/auth_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.username,
    required super.token,
    super.pharmacyCode,
    super.role,
    super.email,
    super.tokenExpiresAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      token: json['token'] ?? json['access_token'] ?? '',
      pharmacyCode: json['pharmacy_code']?.toString(),
      role: json['role']?.toString(),
      email: json['email']?.toString(),
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.tryParse(json['token_expires_at'].toString())
          : null,
    );
  }

  /// `POST /auth/login` body: `{ token, user }`.
  factory UserModel.fromPharmacyLogin(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw const ParseException(message: 'Invalid login response');
    }
    final pharmacy = user['pharmacy'] as Map<String, dynamic>?;
    final token = json['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ParseException(message: 'Missing token in login response');
    }
    return UserModel(
      userId: user['id']?.toString() ?? '',
      username: user['username']?.toString() ?? '',
      token: token,
      pharmacyCode: pharmacy?['license_number']?.toString(),
      role: user['role']?.toString(),
      email: user['email']?.toString(),
      tokenExpiresAt: null,
    );
  }

  /// `GET /auth/profile` → `{ user: { ... } }` (token kept from session).
  factory UserModel.fromPharmacyProfile(Map<String, dynamic> json, {required String token}) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    final pharmacy = user['pharmacy'] as Map<String, dynamic>?;
    return UserModel(
      userId: user['id']?.toString() ?? '',
      username: user['username']?.toString() ?? '',
      token: token,
      pharmacyCode: pharmacy?['license_number']?.toString(),
      role: user['role']?.toString(),
      email: user['email']?.toString(),
      tokenExpiresAt: null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'token': token,
        'pharmacy_code': pharmacyCode,
        'role': role,
        'email': email,
        'token_expires_at': tokenExpiresAt?.toIso8601String(),
      };
}
