import 'package:get/get.dart';

import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository repository;
  LoginController({required this.repository});

  // ---- UI state ----
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final obscurePassword = true.obs;
  final currentUser = Rxn<UserEntity>();

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void clearError() => errorMessage.value = null;

  /// Returns true on success, false on failure.
  /// On failure, [errorMessage] is populated and the UI can read it.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (isLoading.value) return false;

    isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.login(
      username: username.trim(),
      password: password,
    );

    isLoading.value = false;

    return result.fold(
          (failure) {
        errorMessage.value = failure.message;
        return false;
      },
          (user) {
        currentUser.value = user;
        // TODO: persist token securely (e.g. flutter_secure_storage) here
        // so subsequent API calls can attach it as a Bearer header.
        return true;
      },
    );
  }

  Future<void> logout() async {
    isLoading.value = true;
    final result = await repository.logout();
    isLoading.value = false;
    result.fold(
          (failure) => errorMessage.value = failure.message,
          (_) => currentUser.value = null,
    );
  }
}