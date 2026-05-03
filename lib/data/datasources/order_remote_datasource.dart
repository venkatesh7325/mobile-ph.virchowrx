import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int page = 1, int limit = 20});
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> placeOrder(Map<String, dynamic> orderData);
  Future<bool> cancelOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;
  const OrderRemoteDataSourceImpl({required this.apiClient});

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
    final order = response['order'] as Map<String, dynamic>?;
    if (order == null) {
      throw const NotFoundException(message: 'Order not found');
    }
    return OrderModel.fromPharmacyOrder(order);
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
