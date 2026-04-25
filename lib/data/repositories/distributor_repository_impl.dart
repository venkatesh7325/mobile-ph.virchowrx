import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/distributor_entity.dart';
import '../../domain/repositories/distributor_repository.dart';
import '../datasources/distributor_remote_datasource.dart';

class DistributorRepositoryImpl implements DistributorRepository {
  final DistributorRemoteDataSource remoteDataSource;
  const DistributorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DistributorEntity>>> getDistributors({
    String? search, double? latitude, double? longitude, int page = 1, int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getDistributors(
        search: search, latitude: latitude, longitude: longitude, page: page, limit: limit,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DistributorEntity>> getDistributorById(String id) async {
    try {
      return Right(await remoteDataSource.getDistributorById(id));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
