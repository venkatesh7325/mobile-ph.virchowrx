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
    await Future.delayed(const Duration(milliseconds: 800));
    return OrderModel.sampleList;
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return OrderModel.sampleList.firstWhere((o) => o.id == id);
  }

  @override
  Future<OrderModel> placeOrder(Map<String, dynamic> orderData) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return OrderModel.sampleList.first;
  }

  @override
  Future<bool> cancelOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
