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
      pharmacyCode: json['pharmacy_code'],
      role: json['role'],
      email: json['email'],
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.tryParse(json['token_expires_at'])
          : null,
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