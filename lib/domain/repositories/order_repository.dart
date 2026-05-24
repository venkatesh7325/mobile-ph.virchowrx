import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/delivery_tracking_entity.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders({int page = 1, int limit = 20});
  Future<Either<Failure, OrderEntity>> getOrderById(String id);
  Future<Either<Failure, DeliveryTrackingEntity>> getDeliveryTracking(String id);
  Future<Either<Failure, OrderEntity>> placeOrder(Map<String, dynamic> orderData);
  Future<Either<Failure, bool>> cancelOrder(String id);
}
