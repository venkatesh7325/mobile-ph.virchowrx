import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/enquiry_entity.dart';
import '../../domain/repositories/enquiry_repository.dart';
import '../datasources/enquiry_remote_datasource.dart';

class EnquiryRepositoryImpl implements EnquiryRepository {
  final EnquiryRemoteDataSource remoteDataSource;
  const EnquiryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<EnquiryEntity>>> getEnquiries({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      return Right(
        await remoteDataSource.getEnquiries(page: page, limit: limit, search: search),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnquiryEntity>> getEnquiryById(String id) async {
    try {
      return Right(await remoteDataSource.getEnquiryById(id));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnquiryEntity>> submitEnquiry(Map<String, dynamic> data) async {
    try {
      return Right(await remoteDataSource.submitEnquiry(data));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnquiryEntity>> acceptEnquiryReply(int enquiryId) async {
    try {
      return Right(await remoteDataSource.acceptEnquiryReply(enquiryId));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ParseException catch (e) {
      return Left(UnexpectedFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
