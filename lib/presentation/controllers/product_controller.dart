import 'package:get/get.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_image_urls_result.dart';
import '../../domain/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository repository;
  ProductController({required this.repository});

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final products = <ProductEntity>[].obs;
  final filteredProducts = <ProductEntity>[].obs;
  final categories = <String>[].obs;
  /// Empty string means "no category filter".
  final selectedCategory = ''.obs;
  final searchQuery = ''.obs;

  /// List thumbnail: prefers API `thumbUrl` via [ProductImageUrlsResult.thumbnailUrl].
  final catalogThumbnails = RxMap<String, String>();

  /// When [catalogThumbnails] points at a missing `-thumbs/` blob (404), try this URL (e.g. full-size).
  final catalogThumbnailFallbacks = RxMap<String, String>();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.getProducts(
      search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
    );
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        products.clear();
        filteredProducts.clear();
        catalogThumbnails.clear();
        catalogThumbnailFallbacks.clear();
      },
      (data) {
        products.value = data;
        _applyFilters();
        _loadCatalogThumbnails(data);
      },
    );

    isLoading.value = false;
  }

  /// List cell image: API thumbnail when loaded, else catalog [ProductEntity.imageUrl].
  String? thumbnailUrlFor(ProductEntity p) {
    final fromApi = catalogThumbnails[p.id];
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    return p.imageUrl;
  }

  /// First gallery URL distinct from the list thumb (used after 404 on thumb).
  String? thumbnailFallbackFor(ProductEntity p) => catalogThumbnailFallbacks[p.id];

  /// Fetches one image per product only when the catalog row had no image URL.
  Future<void> _loadCatalogThumbnails(List<ProductEntity> list) async {
    catalogThumbnails.clear();
    catalogThumbnailFallbacks.clear();
    for (final p in list) {
      if (p.id.isEmpty) continue;
      final hasCatalogImage =
          (p.imageUrl?.isNotEmpty ?? false) || p.galleryUrls.isNotEmpty;
      if (hasCatalogImage) continue;
      final result = await repository.getProductImageUrls(p.id);
      result.fold((_) {}, (r) {
        final u = r.thumbnailUrl;
        if (u != null && u.isNotEmpty) {
          catalogThumbnails[p.id] = u;
        }
        final fb = _firstGalleryUrlDistinctFromThumb(r);
        if (fb != null && fb.isNotEmpty) {
          catalogThumbnailFallbacks[p.id] = fb;
        }
      });
    }
  }

  static String? _firstGalleryUrlDistinctFromThumb(ProductImageUrlsResult r) {
    final thumb = r.thumbnailUrl;
    for (final u in r.urls) {
      if (u.isEmpty) continue;
      if (thumb == null || thumb.isEmpty || u != thumb) return u;
    }
    return null;
  }

  Future<void> loadCategories() async {
    final result = await repository.getCategories();
    result.fold(
      (_) => null,
      (data) {
        final list = data
            .where((c) => c.trim().isNotEmpty)
            .where((c) => c.trim().toLowerCase() != 'all')
            .where((c) => c.trim().toLowerCase() != 'virchow')
            .toList();
        categories.value = list;
        if (selectedCategory.value.isNotEmpty &&
            !list.contains(selectedCategory.value)) {
          selectedCategory.value = '';
          _applyFilters();
        }
      },
    );
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    loadProducts();
  }

  void _applyFilters() {
    var list = products.toList();
    if (selectedCategory.value.trim().isNotEmpty) {
      list = list.where((p) => p.category == selectedCategory.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.code.toLowerCase().contains(q)).toList();
    }
    filteredProducts.value = list;
  }

  Future<void> refresh() async {
    await loadProducts();
    await loadCategories();
  }
}
