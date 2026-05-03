import 'package:get/get.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository repository;
  ProductController({required this.repository});

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final products = <ProductEntity>[].obs;
  final filteredProducts = <ProductEntity>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
  }

  // Change this method only:
  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.getProducts(
      search: searchQuery.value,   // ← pass current search to API
    );

    result.fold(
          (failure) {
        errorMessage.value = failure.message;
        products.clear();
        filteredProducts.clear();
      },
          (data) {
        products.value = data;
        _applyFilters();
      },
    );

    isLoading.value = false;
  }

// And update setSearchQuery to also reload from API:
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters(); // instant local filter while typing
  }

// refresh already calls loadProducts — no change needed
  Future<void> loadCategories() async {
    final result = await repository.getCategories();
    result.fold(
      (_) => null,
      (data) => categories.value = data,
    );
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }



  void _applyFilters() {
    var list = products.toList();
    if (selectedCategory.value != 'All') {
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
