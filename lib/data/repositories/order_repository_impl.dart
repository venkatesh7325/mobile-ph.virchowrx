import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/delivery_tracking_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  const OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({int page = 1, int limit = 20}) async {
    try {
      return Right(await remoteDataSource.getOrders(page: page, limit: limit));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String id) async {
    try {
      return Right(await remoteDataSource.getOrderById(id));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryTrackingEntity>> getDeliveryTracking(String id) async {
    try {
      return Right(await remoteDataSource.getDeliveryTracking(id));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException {
      return const Left(NotFoundFailure(
        message:
            'Delivery partner not assigned yet. Your distributor will assign a driver when the order is ready.',
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      return Right(await remoteDataSource.placeOrder(orderData));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelOrder(String id) async {
    try {
      return Right(await remoteDataSource.cancelOrder(id));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
