import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/pharmacy_registration.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      return Right(await remoteDataSource.logout());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> currentUser() async {
    try {
      return Right(await remoteDataSource.currentUser());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendVerificationResult>> sendPharmacyEmailVerification(String email) async {
    try {
      return Right(await remoteDataSource.sendPharmacyEmailVerification(email));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UniqueFieldResult>> checkPharmacyFieldUnique({
    required String field,
    required String value,
  }) async {
    try {
      return Right(await remoteDataSource.checkPharmacyFieldUnique(field: field, value: value));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> registerPharmacy(PharmacyRegistrationPayload payload) async {
    try {
      final map = await remoteDataSource.registerPharmacy(payload);
      return Right(map['message']?.toString() ?? 'Registration submitted');
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}