import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/distributor_entity.dart';

abstract class DistributorRepository {
  Future<Either<Failure, List<DistributorEntity>>> getDistributors({
    String? search,
    double? latitude,
    double? longitude,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, DistributorEntity>> getDistributorById(String id);
}
