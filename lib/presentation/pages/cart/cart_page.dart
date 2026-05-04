import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../controllers/cart_controller.dart';
import '../../widgets/simple_back_app_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color bgColor = Color(0xFFF4FAF7);

  String _formatINR(double val) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(val);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: SimpleBackAppBar.build(
        context,
        title: 'Cart',
        fallbackRoute: AppRoutes.dashboard,
        actions: [
          Obx(() {
            if (cart.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cart.itemCount} items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SimpleBackAppBar.teal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              if (cart.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Browse catalog', style: TextStyle(color: primaryGreen)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CartLineCard(
                            primaryGreen: primaryGreen,
                            item: item,
                            cart: cart,
                            format: _formatINR,
                          ),
                        )),
                    const SizedBox(height: 20),
                    _OrderSummary(cart: cart, format: _formatINR),
                    const SizedBox(height: 14),
                    const SizedBox(height: 140),
                  ],
                ),
              );
            }),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(() {
                if (cart.isEmpty) return const SizedBox.shrink();
                return _CheckoutBar(
                  primaryGreen: primaryGreen,
                  cart: cart,
                  format: _formatINR,
                  onCheckout: () => context.push(AppRoutes.placeOrderScreen),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  final Color primaryGreen;
  final CartItem item;
  final CartController cart;
  final String Function(double) format;

  const _CartLineCard({
    required this.primaryGreen,
    required this.item,
    required this.cart,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(p.code, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => cart.removeItem(p.id),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFBBBBBB)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QtyControl(primaryGreen: primaryGreen, item: item, cart: cart),
              const Spacer(),
              Obx(() => Text(
                    format(item.total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final Color primaryGreen;
  final CartItem item;
  final CartController cart;

  const _QtyControl({required this.primaryGreen, required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cart.decrementQuantity(p.id),
            child: const SizedBox(
              width: 34,
              height: 34,
              child: Center(child: Text('−', style: TextStyle(fontSize: 20, color: Color(0xFF555555)))),
            ),
          ),
          Obx(() => SizedBox(
                width: 32,
                child: Text(
                  '${item.quantity.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              )),
          GestureDetector(
            onTap: () => cart.incrementQuantity(p.id),
            child: SizedBox(
              width: 34,
              height: 34,
              child: Center(child: Icon(Icons.add, size: 18, color: primaryGreen)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartController cart;
  final String Function(double) format;

  const _OrderSummary({required this.cart, required this.format});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('Subtotal', format(cart.subtotal)),
                const SizedBox(height: 8),
                _row('Delivery / fees', format(cart.shipping)),
                const SizedBox(height: 8),
                _row('Tax', format(cart.tax)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(format(cart.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _row(String a, String b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: TextStyle(color: Colors.grey.shade600)),
        Text(b),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final Color primaryGreen;
  final CartController cart;
  final String Function(double) format;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.primaryGreen,
    required this.cart,
    required this.format,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: onCheckout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() {
            return Text(
              'Checkout · ${cart.itemCount} items · ${format(cart.total)}  →',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            );
          }),
        ),
      ),
    );
  }
}
