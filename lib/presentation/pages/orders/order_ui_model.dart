import 'package:flutter/material.dart';

import '../../../domain/entities/order_entity.dart';

class OrderItem {
  final String product;
  final int sku;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.product,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class OrderModel {
  final String id;
  final String orderId;
  final String poNumber;
  final DateTime placedOn;
  final String status;
  final List<OrderItem> items;
  final String? poAttachmentName;
  final String? poAttachmentSize;
  final String? poAttachmentUrl;
  final DateTime? poAttachmentUploadedAt;
  final String? trackingNumber;
  final String? deliveryOtp;
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
  final int timelineStep;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.poNumber,
    required this.placedOn,
    required this.status,
    required this.items,
    this.poAttachmentName,
    this.poAttachmentSize,
    this.poAttachmentUrl,
    this.poAttachmentUploadedAt,
    this.trackingNumber,
    this.deliveryOtp,
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
    this.timelineStep = 1,
  });

  double get totalAmount => items.fold(0, (s, i) => s + i.total);

  bool get isDeliveryTrackable {
    final s = status.toLowerCase();
    return s == 'billed' || s == 'shipped' || s == 'processing' || s == 'approved';
  }

  bool get canTrackOtp => status.toLowerCase() == 'shipped';

  /// Driver line shown under "Live delivery & OTP" (matches web).
  String get driverDisplayLabel {
    if (driverName != null && driverName!.trim().isNotEmpty) {
      return driverName!.trim();
    }
    if (trackingNumber != null && trackingNumber!.trim().isNotEmpty) {
      return trackingNumber!.trim();
    }
    return 'Delivery partner';
  }

  /// Blue status pill text (matches web "in transit").
  String get deliveryStatusDisplay {
    final raw = deliveryStatus?.trim();
    if (raw != null && raw.isNotEmpty) {
      return raw.replaceAll('_', ' ');
    }
    final s = status.toLowerCase();
    if (s == 'shipped') return 'in transit';
    if (s == 'delivered') return 'delivered';
    if (s == 'processing' || s == 'approved') return 'processing';
    return 'in transit';
  }

  bool get showLiveDeliverySection => isDeliveryTrackable;

  bool get hasDeliveryOtp =>
      deliveryOtp != null && deliveryOtp!.trim().isNotEmpty;

  bool get showOnTheWayBanner => status.toLowerCase() == 'shipped';

  factory OrderModel.fromEntity(OrderEntity entity) {
    final poNumber = (entity.poNumber != null && entity.poNumber!.trim().isNotEmpty)
        ? entity.poNumber!.trim()
        : '—';
    final items = entity.items
        .map(
          (i) => OrderItem(
            product: i.productName,
            sku: int.tryParse(i.productId) ?? 0,
            quantity: i.quantity,
            unitPrice: i.price,
          ),
        )
        .toList();

    String? poSize;
    if (entity.poCopySizeBytes != null) {
      poSize = '${(entity.poCopySizeBytes! / 1024).toStringAsFixed(1)} KB';
      if (entity.poCopyUploadedAt != null) {
        poSize = '$poSize • Uploaded on ${formatOrderDateTime(entity.poCopyUploadedAt!)}';
      }
    }

    return OrderModel(
      id: entity.id,
      orderId: entity.orderNumber,
      poNumber: poNumber,
      placedOn: entity.createdAt,
      status: statusLabel(entity.status),
      items: items,
      poAttachmentName: entity.poCopyOriginalName,
      poAttachmentSize: poSize,
      poAttachmentUrl: entity.poCopyUrl,
      poAttachmentUploadedAt: entity.poCopyUploadedAt,
      trackingNumber: entity.trackingNumber,
      deliveryOtp: entity.deliveryOtp,
      distributorNotes: entity.distributorNotes,
      deliveryAddress: entity.deliveryAddress,
      invoiceNumber: entity.invoiceNumber,
      driverName: entity.driverName,
      deliveryStatus: entity.deliveryStatus,
      driverLatitude: entity.driverLatitude,
      driverLongitude: entity.driverLongitude,
      deliveryLatitude: entity.deliveryLatitude,
      deliveryLongitude: entity.deliveryLongitude,
      processedAt: entity.processedAt,
      shippedAt: entity.shippedAt,
      deliveredAt: entity.deliveredAt,
      timelineStep: timelineStepFor(entity.status),
    );
  }
}

const orderPrimaryGreen = Color(0xFF1B6E4B);
const orderPendingColor = Color(0xFFE07B22);
const orderBlueAccent = Color(0xFF2979D4);
const orderBgColor = Color(0xFFF2F2F7);
const orderBorderColor = Color(0xFFE4E4E4);

String formatOrderDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final ampm = dt.hour >= 12 ? 'pm' : 'am';
  final min = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm';
}

String formatOrderInr(double val) {
  final parts = val.toStringAsFixed(2).split('.');
  final intStr = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{2})+\d$)'),
    (m) => '${m[1]},',
  );
  return '₹$intStr.${parts[1]}';
}

String statusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Pending';
    case OrderStatus.processing:
      return 'Processing';
    case OrderStatus.shipped:
      return 'Shipped';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

int timelineStepFor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 1;
    case OrderStatus.processing:
      return 3;
    case OrderStatus.shipped:
      return 4;
    case OrderStatus.delivered:
      return 5;
    case OrderStatus.cancelled:
      return 1;
  }
}
