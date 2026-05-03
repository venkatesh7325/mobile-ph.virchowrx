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
          const SizedBox(height: 16),
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
                        cartController: cartController,
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
          onTap: () => Navigator.maybePop(context),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            suffixIcon: const Icon(Icons.tune, color: primaryTeal),
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
  final CartController cartController;
  final Color accentColor;
  /// Prefer first URL from product-images API (via [ProductController.thumbnailUrlFor]).
  final String? catalogImageUrl;
  final String? catalogImageFallbackUrl;

  const _ProductCard({
    required this.product,
    required this.cartController,
    required this.accentColor,
    this.catalogImageUrl,
    this.catalogImageFallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = product.isInStock;
    // Logic to determine if we show the stepper (if already in cart) or Add Button
    final cartItemCount = cartController.getItemCount(product.id);

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.productDetail, extra: product);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: cartItemCount > 0 ? Border.all(color: ProductsPage.primaryTeal.withOpacity(0.5), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.productGallery, extra: product);
                  },
                  child: ProductNetworkImage(
                    imageUrl: catalogImageUrl ?? product.imageUrl,
                    fallbackImageUrl: catalogImageFallbackUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(16),
                    fallback: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.medication_liquid_sharp, color: Colors.brown.withOpacity(0.4), size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold, color: ProductsPage.darkGrey)),
                      const SizedBox(height: 4),
                      Text(product.code, style: const TextStyle(color: ProductsPage.mutedText, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatInr(product.price), style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('/ piece', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: inStock ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: inStock ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            inStock ? '${product.stock} in stock' : 'Out of stock',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: inStock ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (inStock && cartItemCount > 0)
                  _buildStepper(cartItemCount)
                else if (inStock)
                  ElevatedButton(
                    onPressed: () => cartController.addItem(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProductsPage.primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Add to cart'),
                  )
                else
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Notify me ', style: TextStyle(color: ProductsPage.primaryTeal)),
                        Icon(Icons.notifications_none, size: 16, color: ProductsPage.primaryTeal),
                      ],
                    ),
                  ),
              ],
            )
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

  Widget _buildStepper(int count) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(onPressed: () => cartController.removeItem(product.id), icon: const Icon(Icons.remove, size: 16)),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => cartController.addItem(product), icon: const Icon(Icons.add, size: 16, color: ProductsPage.primaryTeal)),
        ],
      ),
    );
  }
}