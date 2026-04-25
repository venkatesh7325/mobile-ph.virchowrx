import '../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category, String? search, int page = 1, int limit = 20});
  Future<ProductModel> getProductById(String id);
  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;
  const ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts({
    String? category, String? search, int page = 1, int limit = 20,
  }) async {
    // For development, return sample data
    await Future.delayed(const Duration(milliseconds: 800));
    return ProductModel.sampleList;

    // Production code:
    // final params = {'page': page, 'limit': limit};
    // if (category != null) params['category'] = category;
    // if (search != null) params['search'] = search;
    // final response = await apiClient.get('/products', queryParams: params);
    // return (response['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ProductModel.sampleList.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['All', 'Electronics', 'Hardware', 'Safety', 'Pipes', 'Tools'];
  }
}
