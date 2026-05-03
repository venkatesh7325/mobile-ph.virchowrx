import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT and the full user payload so the app can:
///   • Attach `Authorization: Bearer <token>` on subsequent API calls
///   • Restore the signed-in user without hitting the network on cold start
class AuthStorage {
  AuthStorage._();
  static final AuthStorage instance = AuthStorage._();

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user_json';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUser, value: jsonEncode(userJson));
  }

  Future<String?> readToken() => _storage.read(key: _kToken);

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async => (await readToken())?.isNotEmpty ?? false;

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUser);
  }
}