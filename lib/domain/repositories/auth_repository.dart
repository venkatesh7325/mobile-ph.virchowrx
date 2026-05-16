import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../entities/forgot_password_entity.dart';
import '../entities/pharmacy_registration.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password
  });

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, UserEntity>> currentUser();

  Future<Either<Failure, SendVerificationResult>> sendPharmacyEmailVerification(String email);

  Future<Either<Failure, UniqueFieldResult>> checkPharmacyFieldUnique({
    required String field,
    required String value,
  });

  Future<Either<Failure, String>> registerPharmacy(PharmacyRegistrationPayload payload);

  Future<Either<Failure, ForgotPasswordRequestResult>> requestForgotPassword(String username);

  Future<Either<Failure, String>> confirmForgotPassword({
    required String username,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}