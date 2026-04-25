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
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
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
                _buildWelcome(),
                const SizedBox(height: 20),
                _buildStatGrid(context, controller, currency),
                const SizedBox(height: 24),
                _buildRecentOrdersHeader(context),
                const SizedBox(height: 12),
                _buildRecentOrders(context, controller, currency),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.welcomeBack, style: AppTypography.bodyMedium),
        const SizedBox(height: 4),
        Text(AppStrings.quickStats,
          style: AppTypography.headlineMedium.copyWith(fontSize: 22)),
      ],
    );
  }

  Widget _buildStatGrid(
    BuildContext context, DashboardController controller, NumberFormat currency,
  ) {
    final crossAxisCount = Responsive.value(
      context, mobile: 2, tablet: 4, desktop: 4,
    );
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        Obx(() => StatCard(
          title: AppStrings.totalOrders,
          value: '${controller.totalOrders.value}',
          icon: Icons.receipt_long, color: AppColors.primary,
          onTap: () => context.go(AppRoutes.orders),
        )),
        Obx(() => StatCard(
          title: AppStrings.totalRevenue,
          value: currency.format(controller.totalRevenue.value),
          icon: Icons.trending_up, color: AppColors.success, trend: '+12%',
        )),
        Obx(() => StatCard(
          title: AppStrings.activeProducts,
          value: '${controller.activeProducts.value}',
          icon: Icons.inventory_2, color: AppColors.accent,
          onTap: () => context.go(AppRoutes.products),
        )),
        Obx(() => StatCard(
          title: AppStrings.pendingEnquiries,
          value: '${controller.pendingEnquiries.value}',
          icon: Icons.help, color: AppColors.warning,
          onTap: () => context.go(AppRoutes.enquiry),
        )),
      ],
    );
  }

  Widget _buildRecentOrdersHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(AppStrings.recentOrders, style: AppTypography.titleLarge)),
        TextButton(
          onPressed: () => context.go(AppRoutes.orders),
          child: const Text(AppStrings.viewAll),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(
    BuildContext context, DashboardController controller, NumberFormat currency,
  ) {
    if (controller.recentOrders.isEmpty) {
      return const AppEmptyView(
        title: AppStrings.noOrdersFound,
        icon: Icons.receipt_long_outlined,
      );
    }
    return Column(
      children: controller.recentOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _OrderListTile(order: order, currency: currency),
        );
      }).toList(),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final OrderEntity order;
  final NumberFormat currency;
  const _OrderListTile({required this.order, required this.currency});

  Color _statusColor() {
    switch (order.status) {
      case OrderStatus.pending: return AppColors.warning;
      case OrderStatus.processing: return AppColors.primary;
      case OrderStatus.shipped: return AppColors.accent;
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  String _statusLabel() {
    switch (order.status) {
      case OrderStatus.pending: return AppStrings.pending;
      case OrderStatus.processing: return AppStrings.processing;
      case OrderStatus.shipped: return AppStrings.shipped;
      case OrderStatus.delivered: return AppStrings.delivered;
      case OrderStatus.cancelled: return AppStrings.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go('${AppRoutes.orders}/${order.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt, color: _statusColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderNumber,
                  style: AppTypography.titleSmall, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy').format(order.createdAt),
                  style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(order.total),
                style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_statusLabel(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
