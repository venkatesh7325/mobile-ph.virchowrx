import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/order_entity.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final LoginController? loginController =
        Get.isRegistered<LoginController>() ? Get.find<LoginController>() : null;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return AppScaffold(
      title: AppStrings.dashboard,
      currentRoute: AppRoutes.dashboard,
      body: Obx(() {
        if (controller.isLoading.value && controller.recentOrders.isEmpty) {
          return const AppLoadingView();
        }
        if (controller.errorMessage.value != null && controller.recentOrders.isEmpty) {
          return AppErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildHeader(),
                // const SizedBox(height: 24),
                _buildWelcomeSection(loginController),
                const SizedBox(height: 18),
                _buildStatusGrid(context, controller, currency),
                const SizedBox(height: 22),
                _buildQuickActions(context),
                const SizedBox(height: 18),
                _buildRecentOrders(controller, currency),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection(LoginController? loginController) {
    final user = loginController?.currentUser.value;
    final name = (user?.username ?? 'City Pharmacy').trim();
    final code = (user?.pharmacyCode ?? 'PH001').trim();
    final initials = name.isNotEmpty ? name.trim().split(RegExp(r'\s+')).take(2).map((s) => s.isNotEmpty ? s[0] : '').join() : 'SP';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $name ($code)',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 26,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        // --- The Fixed Circle ---
        Positioned(
          top: 0,
          right: -150,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gridIconBlue,
                  AppColors.primaryTeal,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            // Adding the SP Text in the center
            child: Center(
              child: Text(
                initials.toUpperCase(),
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Actions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Browse\nProducts',
                onTap: () => context.push(AppRoutes.products),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                context,
                icon: Icons.shopping_cart_outlined,
                label: 'View\nCart',
                onTap: () => context.push(AppRoutes.cart),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                context,
                icon: Icons.receipt_long_outlined,
                label: 'View\nOrders',
                onTap: () => context.push(AppRoutes.orders),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders(DashboardController controller, NumberFormat currency) {
    final orders = controller.recentOrders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Recent Orders'),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.08)),
            ),
            child: Text(
              'No recent orders yet',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
            ),
          )
        else
          Column(
            children: [
              for (final o in orders) ...[
                _orderTile(o, currency),
                const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }

  Widget _orderTile(OrderEntity order, NumberFormat currency) {
    final date = DateFormat('dd/MM/yyyy').format(order.createdAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currency.format(order.total)} · $date',
                  style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _statusPill(order.status),
        ],
      ),
    );
  }

  Widget _statusPill(OrderStatus status) {
    final label = status.name[0].toUpperCase() + status.name.substring(1);
    final bool isPending = status == OrderStatus.pending;
    final bg = isPending ? AppColors.badgeUrgentBg : AppColors.primaryTeal.withOpacity(0.10);
    final fg = isPending ? AppColors.badgeUrgent : AppColors.primaryTeal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              letterSpacing: 1.2,
              color: AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.16),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid(
    BuildContext context,
    DashboardController controller,
    NumberFormat currency,
  ) {
    return GridView.count(
      // Keep these two properties to avoid "infinite height" errors
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildGridCard(
          AppColors.gridIconBlue,
          Icons.shopping_bag_outlined,
          controller.totalOrders.value.toString(),
          'Total Orders',
          null,
          AppColors.primaryTeal,
        ),
        _buildGridCard(
          AppColors.gridIconGold,
          Icons.access_time_outlined,
          controller.pendingOrders.value.toString(),
          'Pending Orders',
          null,
          AppColors.accentGold,
        ),
        _buildGridCard(
          AppColors.gridIconBlue,
          Icons.inventory_2_outlined,
          controller.activeProducts.value.toString(),
          'Available Products',
          null,
          AppColors.primaryTeal,
        ),
        _buildGridCard(
          AppColors.gridIconPurple,
          Icons.currency_rupee_outlined,
          currency.format(controller.totalRevenue.value),
          'Total Value',
          null,
          const Color(0xFF6B7280),
        ),
      ],
    );
  }

  Widget _buildGridCard(Color iconBg, IconData icon, String value, String title,
      String? badgeText, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.05))),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTypography.productPrice(
                    fontSize: 32, color: AppColors.textDark),
              ),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                    fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
          if (badgeText != null)
            Positioned(
              top: 0,
              right: 0,
              child: _buildBadge(badgeText, accentColor),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    bool isUrgent = text == 'Urgent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: isUrgent ? AppColors.badgeUrgentBg : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: AppTypography.labelSmall.copyWith(
              color: isUrgent ? AppColors.badgeUrgent : color,
              fontSize: 9,
              fontWeight: FontWeight.w700)),
    );
  }
}
