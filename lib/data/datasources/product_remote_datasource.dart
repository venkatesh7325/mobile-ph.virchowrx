import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/product_image_response_parser.dart';
import '../../domain/entities/product_image_urls_result.dart';
import '../models/product_model.dart';

void _ignoreUnused(Object? _) {}

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<ProductModel> getProductById(String id);
  Future<List<String>> getCategories();

  /// `GET /product-images/product/:productId` — gallery URLs + list [thumbnailUrl] when present.
  Future<ProductImageUrlsResult> getProductImageUrls(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;
  const ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    _ignoreUnused(category);

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit > 0 ? limit : 100,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiClient.get(
      '/products/cataloged',
      queryParams: queryParams,
    ) as Map<String, dynamic>;

    final raw = response['products'];
    if (raw is! List) {
      throw const ParseException(message: 'Unexpected catalog response');
    }

    return raw.map((e) => ProductModel.fromCatalogEntry(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final pid = int.tryParse(id);
    if (pid == null) {
      throw const ValidationException(message: 'Invalid product id');
    }
    final response = await apiClient.get('/products/cataloged/by-product/$pid') as Map<String, dynamic>;
    final raw = response['products'];
    if (raw is! List || raw.isEmpty) {
      throw const NotFoundException(message: 'Product not found');
    }
    return ProductModel.fromCatalogEntry(raw.first as Map<String, dynamic>);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await apiClient.get('/products/cataloged/brands') as Map<String, dynamic>;
    final raw = response['manufacturers'];
    if (raw is! List) return ['All'];
    final names = raw
        .map((e) => (e as Map<String, dynamic>)['name']?.toString())
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .toList();
    return ['All', ...names];
  }

  @override
  Future<ProductImageUrlsResult> getProductImageUrls(String productId) async {
    final id = productId.trim();
    if (id.isEmpty) {
      throw const ValidationException(message: 'Invalid product id');
    }
    final path = '/product-images/product/${Uri.encodeComponent(id)}';
    final data = await apiClient.get(path);
    return parseProductImageUrlsResult(data);
  }
}
