import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../controllers/cart_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return AppScaffold(
      title: AppStrings.myCart,
      currentRoute: AppRoutes.cart,
      showCartIcon: false,
      actions: [
        Obx(() => controller.items.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmClear(context, controller),
              )
            : const SizedBox.shrink()),
      ],
      body: Obx(() {
        if (controller.isEmpty) {
          return AppEmptyView(
            title: AppStrings.cartEmpty,
            message: AppStrings.cartEmptyMessage,
            icon: Icons.shopping_cart_outlined,
            action: SizedBox(
              width: 220,
              child: AppButton(
                label: AppStrings.continueShopping,
                onPressed: () => context.go(AppRoutes.products),
                icon: Icons.arrow_forward,
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: Responsive.pagePadding(context),
                itemCount: controller.items.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CartItemCard(item: controller.items[i], controller: controller, currency: currency),
                ),
              ),
            ),
            _buildSummary(context, controller, currency),
          ],
        );
      }),
    );
  }

  void _confirmClear(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.clearCart),
        content: const Text('Are you sure you want to remove all items from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              controller.clearCart();
              Navigator.pop(context);
              AppSnackBar.showInfo(context, 'Cart cleared');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.clearCart),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartController controller, NumberFormat currency) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow(AppStrings.subtotal, currency.format(controller.subtotal)),
            const SizedBox(height: 6),
            _summaryRow(AppStrings.shipping,
              controller.shipping == 0 ? 'FREE' : currency.format(controller.shipping),
              valueColor: controller.shipping == 0 ? AppColors.success : null),
            const SizedBox(height: 6),
            _summaryRow(AppStrings.tax, currency.format(controller.tax)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
            _summaryRow(AppStrings.total, currency.format(controller.total), isTotal: true),
            const SizedBox(height: 12),
            AppButton(
              label: AppStrings.proceedToCheckout,
              icon: Icons.arrow_forward,
              onPressed: () {
                AppSnackBar.showInfo(context, 'Checkout flow not implemented in this demo');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
            style: isTotal
                ? AppTypography.titleMedium
                : AppTypography.bodyMedium),
        ),
        Text(value,
          style: isTotal
              ? AppTypography.titleLarge.copyWith(color: AppColors.primary)
              : AppTypography.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                )),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController controller;
  final NumberFormat currency;
  const _CartItemCard({required this.item, required this.controller, required this.currency});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                  style: AppTypography.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.product.code, style: AppTypography.caption),
                const SizedBox(height: 6),
                Obx(() => Text(currency.format(item.total),
                  style: AppTypography.titleSmall.copyWith(color: AppColors.primary))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _qtyButton(Icons.remove,
                      onTap: () => controller.decrementQuantity(item.product.id)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Obx(() => Text('${item.quantity.value}',
                        style: AppTypography.titleSmall)),
                    ),
                    _qtyButton(Icons.add,
                      onTap: () => controller.incrementQuantity(item.product.id)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      onPressed: () => controller.removeItem(item.product.id),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }
}
