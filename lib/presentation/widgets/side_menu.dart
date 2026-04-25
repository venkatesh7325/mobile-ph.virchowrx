import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../controllers/cart_controller.dart';

class SideMenu extends StatelessWidget {
  final String currentRoute;
  const SideMenu({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(color: AppColors.sidebarDivider, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _MenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: AppStrings.dashboard,
                    route: AppRoutes.dashboard,
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, AppRoutes.dashboard),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2,
                    label: AppStrings.products,
                    route: AppRoutes.products,
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, AppRoutes.products),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    activeIcon: Icons.location_on,
                    label: AppStrings.findDistributor,
                    route: AppRoutes.findDistributor,
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, AppRoutes.findDistributor),
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: AppStrings.orders,
                    route: AppRoutes.orders,
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, AppRoutes.orders),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    activeIcon: Icons.help,
                    label: AppStrings.enquiry,
                    route: AppRoutes.enquiry,
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, AppRoutes.enquiry),
                  ),
                  _CartMenuItem(
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, AppRoutes.cart),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.sidebarDivider, height: 1),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    if (currentRoute != route) {
      context.go(route);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.business, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(AppStrings.appName,
            style: AppTypography.titleLarge.copyWith(color: AppColors.white)),
          const SizedBox(height: 2),
          Text(AppStrings.appTagline,
            style: AppTypography.bodySmall.copyWith(color: AppColors.sidebarText.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.sidebarIcon),
            title: Text(AppStrings.settings,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.sidebarText)),
            dense: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.sidebarIcon),
            title: Text(AppStrings.logout,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.sidebarText)),
            dense: true,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          Text(AppStrings.version,
            style: AppTypography.caption.copyWith(color: AppColors.sidebarText.withOpacity(0.5))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute.startsWith(route);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? AppColors.white : AppColors.sidebarIcon,
          size: 22,
        ),
        title: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isActive ? AppColors.white : AppColors.sidebarText,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
      ),
    );
  }
}

class _CartMenuItem extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onTap;
  const _CartMenuItem({required this.currentRoute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      init: Get.isRegistered<CartController>() ? null : CartController(),
      builder: (controller) => Obx(() {
        final count = controller.itemCount;
        return _MenuItem(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: AppStrings.cart,
          route: AppRoutes.cart,
          currentRoute: currentRoute,
          onTap: onTap,
          trailing: count > 0
              ? badges.Badge(
                  badgeContent: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.badgeBackground),
                )
              : null,
        );
      }),
    );
  }
}
