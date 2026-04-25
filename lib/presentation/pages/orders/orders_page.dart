import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/order_entity.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    return AppScaffold(
      title: AppStrings.myOrders,
      currentRoute: AppRoutes.orders,
      body: Column(
        children: [
          _buildStatusFilter(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const AppLoadingView();
              }
              if (controller.errorMessage.value != null && controller.orders.isEmpty) {
                return AppErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refresh,
                );
              }
              final filtered = controller.filteredOrders;
              if (filtered.isEmpty) {
                return const AppEmptyView(
                  title: AppStrings.noOrdersFound,
                  icon: Icons.receipt_long_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  padding: Responsive.pagePadding(context),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OrderCard(order: filtered[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(OrderController controller) {
    final statuses = [null, ...OrderStatus.values];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = statuses[i];
          return Obx(() {
            final selected = controller.selectedStatus.value == s;
            return ChoiceChip(
              label: Text(_label(s)),
              selected: selected,
              onSelected: (_) => controller.setStatusFilter(s),
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
          });
        },
      ),
    );
  }

  String _label(OrderStatus? s) {
    if (s == null) return 'All';
    switch (s) {
      case OrderStatus.pending: return AppStrings.pending;
      case OrderStatus.processing: return AppStrings.processing;
      case OrderStatus.shipped: return AppStrings.shipped;
      case OrderStatus.delivered: return AppStrings.delivered;
      case OrderStatus.cancelled: return AppStrings.cancelled;
    }
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

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
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNumber, style: AppTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
                      style: AppTypography.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_statusLabel(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...order.items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text('${item.productName}  ×${item.quantity}',
                    style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
                ),
                Text(currency.format(item.total), style: AppTypography.bodySmall),
              ],
            ),
          )),
          if (order.items.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('+${order.items.length - 2} more items',
                style: AppTypography.caption.copyWith(color: AppColors.primary)),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.total, style: AppTypography.caption),
                    Text(currency.format(order.total),
                      style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              if (order.status == OrderStatus.shipped && order.trackingNumber != null)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_shipping, size: 16),
                  label: const Text(AppStrings.trackOrder, style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
