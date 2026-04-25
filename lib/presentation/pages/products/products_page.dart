import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/product_entity.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final cartController = Get.find<CartController>();

    return AppScaffold(
      title: AppStrings.products,
      currentRoute: AppRoutes.products,
      body: Column(
        children: [
          _buildSearchBar(controller),
          _buildCategoryFilter(controller),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const AppLoadingView();
              }
              if (controller.errorMessage.value != null && controller.products.isEmpty) {
                return AppErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refresh,
                );
              }
              if (controller.filteredProducts.isEmpty) {
                return const AppEmptyView(
                  title: AppStrings.noProductsFound,
                  message: 'Try adjusting your filters or search query',
                  icon: Icons.search_off,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: GridView.builder(
                  padding: Responsive.pagePadding(context),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.gridCrossAxisCount(context),
                    childAspectRatio: 0.72,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (context, i) {
                    final p = controller.filteredProducts[i];
                    return _ProductCard(product: p, cartController: cartController);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AppSearchInput(
        hintText: AppStrings.searchProducts,
        onChanged: controller.setSearchQuery,
      ),
    );
  }

  Widget _buildCategoryFilter(ProductController controller) {
    return SizedBox(
      height: 48,
      child: Obx(() {
        if (controller.categories.isEmpty) return const SizedBox.shrink();
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = controller.categories[i];
            final selected = controller.selectedCategory.value == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: selected,
              onSelected: (_) => controller.setCategory(cat),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              backgroundColor: AppColors.inputFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
              ),
            );
          },
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final CartController cartController;
  const _ProductCard({required this.product, required this.cartController});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Icon(Icons.inventory_2, size: 48, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                  style: AppTypography.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.code, style: AppTypography.caption),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(currency.format(product.price),
                        style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isInStock ? AppColors.successLight : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isInStock ? AppStrings.inStock : AppStrings.outOfStock,
                        style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: product.isInStock ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity, height: 32,
                  child: ElevatedButton(
                    onPressed: product.isInStock ? () {
                      cartController.addItem(product);
                      AppSnackBar.showSuccess(context, AppStrings.itemAddedToCart);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(double.infinity, 32),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text(AppStrings.addToCart),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
