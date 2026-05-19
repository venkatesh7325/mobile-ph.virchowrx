import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../controllers/cart_controller.dart';
import 'side_menu.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String currentRoute;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showCartIcon;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.actions,
    this.floatingActionButton,
    this.showCartIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:  Center(
          child: Text(
            title,
            style: AppTypography.titleLarge.copyWith(color: AppColors.primaryTeal),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryTeal),
        actions: [
          if (showCartIcon) _buildCartAction(context),
          ...?actions,
          const SizedBox(width: 8),
        ],
      ),
      drawer: SideMenu(currentRoute: currentRoute),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildCartAction(BuildContext context) {
    return GetBuilder<CartController>(
      init: Get.isRegistered<CartController>() ? null : CartController(),
      builder: (controller) => Obx(() {
        final count = controller.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity.value,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            onPressed: () => context.go(AppRoutes.cart),
            icon: count > 0
                ? badges.Badge(
                    badgeContent: Text('$count',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.badgeBackground),
                    child: const Icon(Icons.shopping_cart_outlined),
                  )
                : const Icon(Icons.shopping_cart_outlined),
          ),
        );
      }),
    );
  }
}
