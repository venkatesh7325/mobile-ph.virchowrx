import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/pharmacy_registration.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  RegisterController({required this.repository});

  final AuthRepository repository;

  final isLoading = false.obs;
  final sendingVerification = false.obs;
  final errorMessage = RxnString();

  void clearError() => errorMessage.value = null;

  Future<Either<Failure, SendVerificationResult>> sendVerification(String email) async {
    sendingVerification.value = true;
    errorMessage.value = null;
    final result = await repository.sendPharmacyEmailVerification(email.trim());
    sendingVerification.value = false;
    result.fold((f) => errorMessage.value = f.message, (_) {});
    return result;
  }

  Future<Either<Failure, UniqueFieldResult>> checkUnique({
    required String apiFieldName,
    required String value,
  }) {
    return repository.checkPharmacyFieldUnique(field: apiFieldName, value: value);
  }

  Future<Either<Failure, String>> register(PharmacyRegistrationPayload payload) async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await repository.registerPharmacy(payload);
    isLoading.value = false;
    result.fold((f) => errorMessage.value = f.message, (_) {});
    return result;
  }
}
