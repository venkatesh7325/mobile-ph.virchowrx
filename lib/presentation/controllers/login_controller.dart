import 'package:get/get.dart';

import '../../core/auth/auth_session.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository repository;
  final AuthSession authSession;

  LoginController({
    required this.repository,
    required this.authSession,
  });

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final obscurePassword = true.obs;
  final currentUser = Rxn<UserEntity>();

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void clearError() => errorMessage.value = null;

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
