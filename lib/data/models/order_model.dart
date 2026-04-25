import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['product_id']?.toString() ?? '',
        productName: json['product_name'] ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'price': price,
      };
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.createdAt,
    required super.status,
    required super.items,
    required super.subtotal,
    required super.shipping,
    required super.tax,
    required super.total,
    super.trackingNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?)
            ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      status: _parseStatus(json['status']),
      items: itemsJson,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      trackingNumber: json['tracking_number'],
    );
  }

  static OrderStatus _parseStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'processing': return OrderStatus.processing;
      case 'shipped': return OrderStatus.shipped;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  static List<OrderModel> get sampleList => [
        OrderModel(
          id: '1', orderNumber: 'ORD-2024-001',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          status: OrderStatus.delivered,
          items: const [
            OrderItemModel(productId: '1', productName: 'Premium Widget A', quantity: 2, price: 1299),
          ],
          subtotal: 2598, shipping: 100, tax: 259.8, total: 2957.8,
        ),
        OrderModel(
          id: '2', orderNumber: 'ORD-2024-002',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: OrderStatus.shipped,
          items: const [
            OrderItemModel(productId: '4', productName: 'Digital Multimeter', quantity: 1, price: 2100),
          ],
          subtotal: 2100, shipping: 100, tax: 210, total: 2410,
          trackingNumber: 'TRK789012',
        ),
        OrderModel(
          id: '3', orderNumber: 'ORD-2024-003',
          createdAt: DateTime.now(),
          status: OrderStatus.pending,
          items: const [
            OrderItemModel(productId: '6', productName: 'Power Drill 18V', quantity: 1, price: 3500),
          ],
          subtotal: 3500, shipping: 150, tax: 350, total: 4000,
        ),
      ];
}
