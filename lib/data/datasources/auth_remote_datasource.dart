import 'dart:convert';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  const AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/pharmacy/auth/login',
        body: {'username': username, 'password': password},
      );

      // ApiClient already JSON-decodes successful responses.
      final json = response is Map<String, dynamic>
          ? response
          : jsonDecode(response.toString()) as Map<String, dynamic>;

      final token = json['token']?.toString();
      if (token == null || token.isEmpty) {
        throw const ServerException(
          message: 'Invalid response: token missing',
        );
      }

      return UserModel.fromLoginResponse(json);
    } on UnauthorizedException {
      // Surface a friendly message for wrong credentials
      throw const UnauthorizedException(
        message: 'Invalid username or password',
      );
    }
  }
}