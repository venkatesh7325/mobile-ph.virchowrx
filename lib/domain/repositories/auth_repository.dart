import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, UserEntity>> currentUser();
}