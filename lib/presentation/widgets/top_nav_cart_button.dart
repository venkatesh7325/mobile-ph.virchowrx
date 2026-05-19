import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../controllers/cart_controller.dart';

/// Cart icon + badge for custom top bars (e.g. Find Distributors), matching app cart count.
class TopNavCartButton extends StatelessWidget {
  const TopNavCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CartController>()) {
      return _iconShell(onTap: () => context.go(AppRoutes.cart));
    }

    final cart = Get.find<CartController>();
    return Obx(() {
      final count = cart.items.fold<int>(0, (sum, item) => sum + item.quantity.value);
      return _iconShell(
        onTap: () => context.go(AppRoutes.cart),
        badgeCount: count,
      );
    });
  }

  Widget _iconShell({required VoidCallback onTap, int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 18, color: Color(0xFF1D9E75)),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF4FAF7), width: 2),
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
