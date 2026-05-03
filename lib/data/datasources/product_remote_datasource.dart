import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<ProductModel> getProductById(String id);
  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;
  const ProductRemoteDataSourceImpl({required this.apiClient});

  Future<String> _getAuthHeader() async {
    final token = await AuthStorage.instance.readToken();
    if (token == null) throw UnauthorizedException(message: 'No token found');
    return 'Bearer $token';
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    print('getProducts--> called');
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'search': search ?? '',
    };
    final authHeader = await _getAuthHeader(); // ← get token

    // Calls: GET /pharmacy/products/cataloged?search=&page=1&limit=20
    final response = await apiClient.get(
        '/api/pharmacy/products/cataloged',
        queryParams: params,
      token: authHeader
    );

    print('response--> $response');

    // API returns { "products": [...], "total": 8, "page": 1, "pages": 1 }
    final List<dynamic> list = response['products'] as List<dynamic>;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await apiClient.get('/pharmacy/products/$id');
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<String>> getCategories() async {
    // You can wire this to a real endpoint later
    return ['All', 'Injection', 'Tablet', 'Syrup'];
  }
}