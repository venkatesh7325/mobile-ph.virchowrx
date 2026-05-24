import '../../domain/entities/order_entity.dart';

double _jsonDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

int _jsonInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

int? _jsonIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

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
        quantity: _jsonInt(json['quantity'], 1),
        price: _jsonDouble(json['price']),
      );

  factory OrderItemModel.fromPharmacyLine(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return OrderItemModel(
      productId: json['product_id']?.toString() ?? '',
      productName: product?['name']?.toString() ?? '',
      quantity: _jsonInt(json['quantity']),
      price: _jsonDouble(json['unit_price']),
    );
  }

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
    super.deliveryOtp,
    super.poNumber,
    super.distributorNotes,
    super.deliveryAddress,
    super.invoiceNumber,
    super.driverName,
    super.deliveryStatus,
    super.driverLatitude,
    super.driverLongitude,
    super.deliveryLatitude,
    super.deliveryLongitude,
    super.processedAt,
    super.shippedAt,
    super.deliveredAt,
    super.poCopyUrl,
    super.poCopyOriginalName,
    super.poCopySizeBytes,
    super.poCopyUploadedAt,
  });

  static Map<String, dynamic>? _asJsonMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static double? _parseCoord(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static String? _parseDeliveryOtp(
    Map<String, dynamic> json,
    Map<String, dynamic>? assignment,
  ) {
    final delivery = json['delivery'];
    final deliveryMap = delivery is Map<String, dynamic> ? delivery : null;
    final deliveryAssignment =
        assignment ?? _asJsonMap(json['delivery_assignment']);

    final candidates = [
      json['delivery_otp'],
      json['delivery_otp_code'],
      json['deliveryOtp'],
      json['otp'],
      json['otp_code'],
      json['pharmacy_otp'],
      json['pharmacy_delivery_otp'],
      json['verification_otp'],
      json['receive_otp'],
      json['receiver_otp'],
      json['delivery_code'],
      json['delivery_partner_otp'],
      deliveryAssignment?['delivery_otp'],
      deliveryAssignment?['delivery_otp_code'],
      deliveryAssignment?['otp'],
      deliveryAssignment?['otp_code'],
      deliveryAssignment?['pharmacy_otp'],
      deliveryAssignment?['pharmacy_delivery_otp'],
      deliveryAssignment?['delivery_code'],
      assignment?['delivery_otp'],
      assignment?['delivery_otp_code'],
      assignment?['otp'],
      assignment?['otp_code'],
      assignment?['pharmacy_delivery_otp'],
      deliveryMap?['otp'],
      deliveryMap?['delivery_otp'],
      deliveryMap?['otp_code'],
      deliveryMap?['delivery_code'],
    ];

    for (final v in candidates) {
      final normalized = _normalizeOtp(v);
      if (normalized != null) return normalized;
    }
    return null;
  }

  /// Parse OTP from any order/tracking JSON payload.
  static String? parseDeliveryOtp(Map<String, dynamic> json) {
    final assignment = _asJsonMap(json['assignment']) ??
        _asJsonMap(json['delivery_assignment']) ??
        _asJsonMap(json['active_delivery_assignment']) ??
        _asJsonMap(json['latest_delivery_assignment']);

    final direct = _parseDeliveryOtp(json, assignment);
    if (direct != null) return direct;

    final assignments = json['delivery_assignments'];
    if (assignments is List) {
      for (final item in assignments) {
        final map = _asJsonMap(item);
        if (map == null) continue;
        final otp = _parseDeliveryOtp(map, map);
        if (otp != null) return otp;
      }
    }

    final nestedOrder = _asJsonMap(json['pharmacy_order']) ?? _asJsonMap(json['order']);
    if (nestedOrder != null) {
      final otp = parseDeliveryOtp(nestedOrder);
      if (otp != null) return otp;
    }

    return _scanForOtpValue(json);
  }

  static String? _scanForOtpValue(dynamic node, [int depth = 0]) {
    if (depth > 6 || node == null) return null;

    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key == 'otp' ||
            key.endsWith('_otp') ||
            key.contains('otp_code') ||
            key == 'verification_code' ||
            key == 'delivery_code' ||
            (key.contains('delivery') && key.contains('code'))) {
          final normalized = _normalizeOtp(entry.value);
          if (normalized != null) return normalized;
        }
      }
      for (final value in node.values) {
        final found = _scanForOtpValue(value, depth + 1);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final item in node) {
        final found = _scanForOtpValue(item, depth + 1);
        if (found != null) return found;
      }
    }
    return null;
  }

  static String? _normalizeOtp(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim().replaceAll(' ', '');
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    if (RegExp(r'^\d{4,8}$').hasMatch(s)) return s;
    return null;
  }

  static String? _parsePartnerName(Map<String, dynamic>? assignment) {
    if (assignment == null) return null;
    for (final key in ['delivery_partner', 'partner', 'driver', 'delivery_agent']) {
      final partner = _asJsonMap(assignment[key]);
      if (partner == null) continue;
      final name = partner['username']?.toString().trim() ??
          partner['name']?.toString().trim() ??
          partner['display_name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return assignment['driver_name']?.toString().trim();
  }

  static OrderModel _fromPharmacyFields(Map<String, dynamic> json, {
    required String id,
    required String orderNumber,
    required DateTime createdAt,
    required OrderStatus status,
    required List<OrderItemModel> items,
    required double total,
  }) {
    var assignment = _asJsonMap(json['assignment']) ??
        _asJsonMap(json['delivery_assignment']) ??
        _asJsonMap(json['active_delivery_assignment']) ??
        _asJsonMap(json['latest_delivery_assignment']);
    if (assignment == null) {
      final assignments = json['delivery_assignments'];
      if (assignments is List && assignments.isNotEmpty) {
        assignment = _asJsonMap(assignments.first);
      }
    }
    final driver = _asJsonMap(json['driver']) ?? _asJsonMap(assignment?['driver']);

    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      status: status,
      items: items,
      subtotal: total,
      shipping: 0,
      tax: 0,
      total: total,
      trackingNumber: json['tracking_number']?.toString(),
      deliveryOtp: parseDeliveryOtp(json),
      poNumber: json['po_number']?.toString(),
      distributorNotes: json['distributor_notes']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      driverName: json['driver_name']?.toString() ??
          _parsePartnerName(assignment) ??
          driver?['name']?.toString() ??
          driver?['username']?.toString() ??
          assignment?['driver_name']?.toString(),
      deliveryStatus: json['delivery_status']?.toString() ??
          assignment?['status']?.toString(),
      driverLatitude: _parseCoord(json['driver_latitude'] ??
          json['current_latitude'] ??
          assignment?['latitude'] ??
          assignment?['current_latitude']),
      driverLongitude: _parseCoord(json['driver_longitude'] ??
          json['current_longitude'] ??
          assignment?['longitude'] ??
          assignment?['current_longitude']),
      deliveryLatitude: _parseCoord(json['delivery_latitude'] ??
          json['pharmacy_latitude'] ??
          json['latitude']),
      deliveryLongitude: _parseCoord(json['delivery_longitude'] ??
          json['pharmacy_longitude'] ??
          json['longitude']),
      processedAt: _parseDate(json['processed_at']),
      shippedAt: _parseDate(json['shipped_at']),
      deliveredAt: _parseDate(json['delivered_at']),
      poCopyUrl: json['po_copy_url']?.toString(),
      poCopyOriginalName: json['po_copy_original_name']?.toString(),
      poCopySizeBytes: _jsonIntOrNull(json['po_copy_size_bytes']),
      poCopyUploadedAt: _parseDate(json['po_copy_uploaded_at']),
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?)
            ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final id = json['id']?.toString() ?? '';
    final orderNumber = json['order_number'] ?? '';
    final createdAt = DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();
    final status = _parseStatus(json['status']);
    final total = _jsonDouble(json['total']);

    return _fromPharmacyFields(
      json,
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      status: status,
      items: itemsJson,
      total: total,
    );
  }

  factory OrderModel.fromPharmacyOrder(Map<String, dynamic> json) {
    final rawItems = json['order_items'] ?? json['items'];
    final items = (rawItems as List?)
            ?.map((e) => OrderItemModel.fromPharmacyLine(e as Map<String, dynamic>))
            .toList() ??
        <OrderItemModel>[];

    final total = _jsonDouble(json['total_amount']);
    final id = json['id']?.toString() ?? '';
    final orderNumber = json['order_number']?.toString() ?? '';
    final createdAt =
        DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now();
    final status = _parseStatus(json['status']);

    return _fromPharmacyFields(
      json,
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      status: status,
      items: items,
      total: total,
    );
  }

  static OrderStatus _parseStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
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
      case 'pending':
        return OrderStatus.pending;
      default:
        return OrderStatus.pending;
    }
  }

  static List<OrderModel> get sampleList => [
        OrderModel(
          id: '1',
          orderNumber: 'ORD-2024-001',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          status: OrderStatus.delivered,
          items: const [
            OrderItemModel(productId: '1', productName: 'Premium Widget A', quantity: 2, price: 1299),
          ],
          subtotal: 2598,
          shipping: 100,
          tax: 259.8,
          total: 2957.8,
        ),
        OrderModel(
          id: '2',
          orderNumber: 'ORD-2024-002',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: OrderStatus.shipped,
          items: const [
            OrderItemModel(productId: '4', productName: 'Digital Multimeter', quantity: 1, price: 2100),
          ],
          subtotal: 2100,
          shipping: 100,
          tax: 210,
          total: 2410,
          trackingNumber: 'TRK789012',
        ),
        OrderModel(
          id: '3',
          orderNumber: 'ORD-2024-003',
          createdAt: DateTime.now(),
          status: OrderStatus.pending,
          items: const [
            OrderItemModel(productId: '6', productName: 'Power Drill 18V', quantity: 1, price: 3500),
          ],
          subtotal: 3500,
          shipping: 150,
          tax: 350,
          total: 4000,
        ),
      ];
}
