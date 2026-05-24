import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/delivery_tracking_model.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int page = 1, int limit = 20});
  Future<OrderModel> getOrderById(String id);
  Future<DeliveryTrackingModel> getDeliveryTracking(String id);
  Future<OrderModel> placeOrder(Map<String, dynamic> orderData);
  Future<bool> cancelOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;
  const OrderRemoteDataSourceImpl({required this.apiClient});

  /// Merges `GET /orders/:id` envelope into the nested `order` object.
  /// OTP and delivery assignment often live on the envelope or in empty
  /// placeholders on `order` — `putIfAbsent` alone misses those.
  Map<String, dynamic> _mergePharmacyOrderPayload(Map<String, dynamic> response) {
    final order = response['order'] as Map<String, dynamic>?;
    if (order == null) {
      throw const NotFoundException(message: 'Order not found');
    }

    final merged = Map<String, dynamic>.from(order);

    bool isEmptyValue(dynamic value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      if (value is List && value.isEmpty) return true;
      if (value is Map && value.isEmpty) return true;
      return false;
    }

    for (final entry in response.entries) {
      if (entry.key == 'order') continue;
      final existing = merged[entry.key];
      if (isEmptyValue(existing)) {
        merged[entry.key] = entry.value;
      }
    }

    final otp =
        OrderModel.parseDeliveryOtp(response) ?? OrderModel.parseDeliveryOtp(merged);
    if (otp != null) merged['delivery_otp'] = otp;

    return merged;
  }

  @override
  Future<List<OrderModel>> getOrders({int page = 1, int limit = 20}) async {
    final response = await apiClient.get(
      '/orders',
      queryParams: {'page': page, 'limit': limit},
    ) as Map<String, dynamic>;

    final raw = response['orders'];
    if (raw is! List) return [];
    return raw.map((e) => OrderModel.fromPharmacyOrder(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    final response = await apiClient.get('/orders/$id') as Map<String, dynamic>;
    return OrderModel.fromPharmacyOrder(_mergePharmacyOrderPayload(response));
  }

  @override
  Future<DeliveryTrackingModel> getDeliveryTracking(String id) async {
    final response =
        await apiClient.get('/orders/$id/delivery-tracking') as Map<String, dynamic>;
    return DeliveryTrackingModel.fromJson(response);
  }

  @override
  Future<OrderModel> placeOrder(Map<String, dynamic> orderData) async {
    final response = await apiClient.post('/orders', body: orderData) as Map<String, dynamic>;
    final order = response['order'] as Map<String, dynamic>?;
    if (order == null) {
      throw const ParseException(message: 'Missing order in response');
    }
    return OrderModel.fromPharmacyOrder(order);
  }

  @override
  Future<bool> cancelOrder(String id) async {
    await apiClient.delete('/orders/$id');
    return true;
  }
}
