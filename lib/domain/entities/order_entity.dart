import 'package:equatable/equatable.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

OrderStatus? orderStatusFromQuery(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'processing':
    case 'approved':
      return OrderStatus.processing;
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
    case 'rejected':
      return OrderStatus.cancelled;
    default:
      return null;
  }
}

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
  /// OTP for pharmacy to verify delivery (when driver arrives).
  final String? deliveryOtp;
  final String? poNumber;
  final String? distributorNotes;
  final String? deliveryAddress;
  final String? invoiceNumber;
  final String? driverName;
  final String? deliveryStatus;
  final double? driverLatitude;
  final double? driverLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime? processedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? poCopyUrl;
  final String? poCopyOriginalName;
  final int? poCopySizeBytes;
  final DateTime? poCopyUploadedAt;

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
    this.deliveryOtp,
    this.poNumber,
    this.distributorNotes,
    this.deliveryAddress,
    this.invoiceNumber,
    this.driverName,
    this.deliveryStatus,
    this.driverLatitude,
    this.driverLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.processedAt,
    this.shippedAt,
    this.deliveredAt,
    this.poCopyUrl,
    this.poCopyOriginalName,
    this.poCopySizeBytes,
    this.poCopyUploadedAt,
  });

  @override
  List<Object?> get props => [id, orderNumber, status, total];
}
