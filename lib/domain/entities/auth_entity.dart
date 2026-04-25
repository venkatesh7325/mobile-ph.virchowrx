import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String username;
  final String token;
  final String? pharmacyCode;
  final String? role;
  final String? email;
  final DateTime? tokenExpiresAt;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.token,
    this.pharmacyCode,
    this.role,
    this.email,
    this.tokenExpiresAt,
  });

  bool get isTokenValid =>
      tokenExpiresAt == null || tokenExpiresAt!.isAfter(DateTime.now());

  @override
  List<Object?> get props =>
      [userId, username, token, pharmacyCode, role, email, tokenExpiresAt];
}