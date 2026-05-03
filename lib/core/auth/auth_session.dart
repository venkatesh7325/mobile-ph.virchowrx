import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the pharmacy JWT and exposes it to [ApiClient] via GetX.
class AuthSession extends GetxService {
  static const _tokenKey = 'pharmacy_token';

  final RxString token = ''.obs;

  /// Drive [GoRouter.refreshListenable] so redirects run when the token changes.
  final ValueNotifier<int> authListenable = ValueNotifier(0);

  void _notifyAuthChanged() {
    authListenable.value++;
  }

  Future<AuthSession> init() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    if (t != null && t.isNotEmpty) {
      token.value = t;
    }
    _notifyAuthChanged();
    return this;
  }

  Future<void> setToken(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      token.value = '';
      await prefs.remove(_tokenKey);
    } else {
      token.value = value;
      await prefs.setString(_tokenKey, value);
    }
    _notifyAuthChanged();
  }

  Future<void> clear() => setToken(null);
}
