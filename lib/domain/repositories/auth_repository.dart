import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  /// Returns the cached user if one is signed in, otherwise null.
  Future<UserEntity?> getCachedUser();
}