import 'package:equatable/equatable.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, productName, quantity, price];
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String? trackingNumber;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [id, orderNumber, status, total];
}
