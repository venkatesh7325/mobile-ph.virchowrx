import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../controllers/cart_controller.dart';
import '../../widgets/product_network_image.dart';
import '../../controllers/product_controller.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  // Theme Colors from Image
  static const Color primaryTeal = Color(0xFF168A7F);
  static const Color darkGrey = Color(0xFF111827);
  static const Color mutedText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF9),
      appBar: _buildAppBar(context, cartController),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(controller),
          _buildSearchBar(controller),
          _buildCategoryFilter(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: primaryTeal));
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (context, i) {
                    final list = controller.filteredProducts;
                    if (i < 0 || i >= list.length) {
                      return const SizedBox.shrink();
                    }
                    final p = list[i];
                    return Obx(() {
                      final thumb = controller.thumbnailUrlFor(p);
                      final thumbFallback = controller.thumbnailFallbackFor(p);
                      return _ProductCard(
                        product: p,
                        accentColor: _getCardColor(i),
                        catalogImageUrl: thumb,
                        catalogImageFallbackUrl: thumbFallback,
                      );
                    });
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryTeal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFF0F5A53), width: 3),
        ),
        child: const Icon(Icons.headset_mic_outlined, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartController cartController) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: const Icon(Icons.chevron_left, color: primaryTeal),
          ),
        ),
      ),
      centerTitle: true,
      title: const Text('Catalog',
          style: TextStyle(color: darkGrey, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        Obx(() => _buildCartAction(cartController.itemCount)),
      ],
    );
  }

  Widget _buildCartAction(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: primaryTeal),
          ),
          if (count > 0)
            Positioned(
              top: 5, right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFF27B7B), shape: BoxShape.circle),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ProductController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 16, height: 1, color: primaryTeal),
              const SizedBox(width: 8),
              const Text('CITYMED WHOLESALE',
                  style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available', style: TextStyle(fontFamily: 'serif', fontSize: 32, color: darkGrey)),
                  Text('medicines', style: TextStyle(fontFamily: 'serif', fontSize: 32, color: primaryTeal, fontStyle: FontStyle.italic, height: 0.8)),
                ],
              ),
              Obx(() => Column(
                children: [
                  Text('${controller.filteredProducts.length}',
                      style: const TextStyle(fontFamily: 'serif', fontSize: 32, color: darkGrey)),
                  const Text('PRODUCTS',
                      style: TextStyle(color: mutedText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search products or SKU...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            suffixIcon: const Icon(Icons.search, color: primaryTeal),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ProductController controller) {
    return SizedBox(
      height: 40,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.categories.length,
        itemBuilder: (context, i) {
          final cat = controller.categories[i];
          final isSelected = controller.selectedCategory.value == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => controller.setCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? darkGrey : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                ),
                child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : mutedText, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      )),
    );
  }

  Color _getCardColor(int index) {
    List<Color> colors = [const Color(0xFFFDF4BE), const Color(0xFFF9D1D1), const Color(0xFFD6E4FF)];
    return colors[index % colors.length];
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final Color accentColor;
  /// Prefer first URL from product-images API (via [ProductController.thumbnailUrlFor]).
  final String? catalogImageUrl;
  final String? catalogImageFallbackUrl;

  const _ProductCard({
    required this.product,
    required this.accentColor,
    this.catalogImageUrl,
    this.catalogImageFallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    final unit = product.unitLabel.isNotEmpty ? product.unitLabel : 'piece';
    final distCount = product.availableDistributorCount > 0 ? product.availableDistributorCount : 1;
    final mrp = product.mrp ?? product.price;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.productDetail, extra: product);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => context.push(AppRoutes.productGallery, extra: product),
              child: ProductNetworkImage(
                imageUrl: catalogImageUrl ?? product.imageUrl,
                fallbackImageUrl: catalogImageFallbackUrl,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(20),
                fallback: Container(
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.medication_liquid_sharp, color: Colors.brown.withOpacity(0.4), size: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ProductsPage.primaryTeal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'serif'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _kv('Unit', unit)),
                const SizedBox(width: 12),
                Expanded(child: _kv('MRP', _formatInr(mrp))),
              ],
            ),
            const SizedBox(height: 6),
            _kv('Available from', '$distCount Distributor${distCount == 1 ? '' : 's'}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, fontFamily: 'serif'),
                      children: [
                        const TextSpan(
                          text: 'Dealer Price: ',
                          style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: _formatInr(product.price),
                          style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if ((product.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: ProductsPage.primaryTeal,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ProductsPage.primaryTeal.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  product.description!.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatInr(double price) {
    try {
      return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(price);
    } catch (_) {
      return '₹${price.toStringAsFixed(2)}';
    }
  }

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Text('$k: ', style: const TextStyle(color: ProductsPage.mutedText, fontSize: 16, height: 1.25)),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(color: ProductsPage.darkGrey, fontSize: 16, height: 1.25),
          ),
        ),
      ],
    );
  }
}