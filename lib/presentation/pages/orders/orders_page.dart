import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/order_entity.dart';
import '../../controllers/order_controller.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../widgets/app_states.dart';
import '../../widgets/simple_back_app_bar.dart';
import 'order_delivery_live_section.dart';
import 'order_track_otp_dialog.dart';
import 'order_ui_model.dart';

const _kPrimaryGreen = orderPrimaryGreen;
const _kPendingColor = orderPendingColor;
const _kBlueAccent = orderBlueAccent;
const _kBgColor = orderBgColor;
const _kBorderColor = orderBorderColor;

String _formatDateTime(DateTime dt) => formatOrderDateTime(dt);
String _formatINR(double val) => formatOrderInr(val);

// ─────────────────────────────────────────────
// MY ORDERS SCREEN
// ─────────────────────────────────────────────
class MyOrdersScreen extends StatefulWidget {
  final OrderStatus? initialStatusFilter;

  const MyOrdersScreen({super.key, this.initialStatusFilter});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late final OrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OrderController>();
    _controller.setStatusFilter(widget.initialStatusFilter);
  }

  List<OrderModel> get _orders =>
      _controller.filteredOrders.map((o) => OrderModel.fromEntity(o)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      appBar: SimpleBackAppBar.build(
        context,
        title: 'My Orders',
        fallbackRoute: AppRoutes.dashboard,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: InkWell(
                onTap: _controller.refresh,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCCDDEE), width: 1.2),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 16, color: _kBlueAccent),
                      SizedBox(width: 6),
                      Text(
                        'REFRESH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kBlueAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (_controller.isLoading.value && _orders.isEmpty) {
            return const AppLoadingView();
          }
          if (_controller.errorMessage.value != null && _orders.isEmpty) {
            return AppErrorView(
              message: _controller.errorMessage.value!,
              onRetry: _controller.refresh,
            );
          }
          final filter = _controller.selectedStatus.value;
          if (_orders.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (filter != null)
                  _StatusFilterBar(
                    label: statusLabel(filter),
                    onClear: () => _controller.setStatusFilter(null),
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      filter == null
                          ? 'No orders found yet'
                          : 'No ${statusLabel(filter).toLowerCase()} orders found',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (filter != null)
                _StatusFilterBar(
                  label: statusLabel(filter),
                  onClear: () => _controller.setStatusFilter(null),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _orders.length,
                  itemBuilder: (ctx, i) => _OrderCard(
                    order: _orders[i],
                    onViewDetails: () => _showOrderDetails(_orders[i]),
                    onTrackOtp: () => _showTrackOtp(_orders[i]),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _OrderDetailsDialog(order: order),
    );
  }

  void _showTrackOtp(OrderModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => OrderTrackOtpDialog(order: order),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS FILTER BAR
// ─────────────────────────────────────────────
class _StatusFilterBar extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _StatusFilterBar({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 18, color: _kPendingColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing: $label',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kBlueAccent,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.close_rounded, size: 16, color: _kBlueAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onViewDetails;
  final VoidCallback onTrackOtp;

  const _OrderCard({
    required this.order,
    required this.onViewDetails,
    required this.onTrackOtp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${order.orderId}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusBadge(status: order.status),
              if (order.canTrackOtp) _TrackOtpButton(onTap: onTrackOtp),
              _ViewDetailsButton(onTap: onViewDetails),
            ],
          ),
          const SizedBox(height: 12),
          Text('PO Number: ${order.poNumber}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777))),
          const SizedBox(height: 2),
          Text('Placed on ${_formatDateTime(order.placedOn)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777))),
          const SizedBox(height: 12),
          Text(
            'Items: ${order.items.length} product${order.items.length > 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
              children: [
                const TextSpan(text: 'Total Amount: ', style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: _formatINR(order.totalAmount)),
              ],
            ),
          ),
          if (order.trackingNumber != null && order.trackingNumber!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Tracking: ${order.trackingNumber}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            ),
          ],
          if (order.showOnTheWayBanner) ...[
            const SizedBox(height: 12),
            _OnTheWayBanner(onTap: onTrackOtp),
          ],
          const SizedBox(height: 16),
          _OrderStatusTimeline(currentStep: order.timelineStep, isMini: true),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ON THE WAY BANNER
// ─────────────────────────────────────────────
class _OnTheWayBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _OnTheWayBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF6FC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFB8D4F0), width: 1.1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_shipping_outlined, size: 20, color: _kBlueAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Order is on the way — open Track & OTP to see the live map and delivery code for the driver.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.blue.shade900.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: Colors.blue.shade700),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final (icon, bg) = switch (s) {
      'delivered' => ('✓', _kPrimaryGreen),
      'shipped' => ('🚚', const Color(0xFF6B7280)),
      'processing' || 'approved' => ('⚙️', _kBlueAccent),
      'cancelled' => ('❌', const Color(0xFFE53935)),
      _ => ('⏳', _kPendingColor),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 5),
          Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRACK OTP BUTTON
// ─────────────────────────────────────────────
class _TrackOtpButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TrackOtpButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kPrimaryGreen, width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined, size: 14, color: _kPrimaryGreen),
            SizedBox(width: 5),
            Text(
              'TRACK OTP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kPrimaryGreen,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VIEW DETAILS BUTTON
// ─────────────────────────────────────────────
class _ViewDetailsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewDetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBlueAccent, width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye_outlined, size: 14, color: _kBlueAccent),
            SizedBox(width: 5),
            Text(
              'VIEW DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kBlueAccent,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VERTICAL TIMELINE
// ─────────────────────────────────────────────
class _OrderStatusTimeline extends StatelessWidget {
  final int currentStep;
  final bool isMini;

  const _OrderStatusTimeline({required this.currentStep, this.isMini = false});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(label: 'Order Placed', sub: '26 Apr 2026, 10:06 am'),
      _Step(label: 'Approved'),
      _Step(label: 'Processing'),
      _Step(label: 'Shipped'),
      _Step(label: 'Delivered'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final done = (i + 1) <= currentStep;
        final isLast = i == steps.length - 1;
        final showSub = step.sub != null && step.sub!.isNotEmpty;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isMini ? 26 : 34,
                child: Column(
                  children: [
                    _stepCircle(i + 1, done, isMini),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: const Color(0xFFE0E0E0),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: isMini ? 4 : 6, bottom: isLast ? 0 : (isMini ? 12 : 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: TextStyle(
                          fontSize: isMini ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: done ? const Color(0xFF111111) : const Color(0xFF555555),
                        ),
                      ),
                      if (showSub && done) ...[
                        const SizedBox(height: 2),
                        Text(
                          step.sub!,
                          style: TextStyle(
                            fontSize: isMini ? 11 : 12,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _stepCircle(int number, bool done, bool isMini) {
    final size = isMini ? 26.0 : 34.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: done ? _kPrimaryGreen : const Color(0xFFCCCCCC),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? Icon(Icons.check, size: isMini ? 13 : 16, color: Colors.white)
            : Text(
          '$number',
          style: TextStyle(
            fontSize: isMini ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String label;
  final String? sub;
  _Step({required this.label, this.sub});
}

// ─────────────────────────────────────────────
// ORDER DETAILS DIALOG
// ─────────────────────────────────────────────
class _OrderDetailsDialog extends StatefulWidget {
  final OrderModel order;

  const _OrderDetailsDialog({required this.order});

  @override
  State<_OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<_OrderDetailsDialog> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final repo = Get.find<OrderRepository>();
    final result = await repo.getOrderById(_order.id);
    if (!mounted) return;
    result.fold((_) {}, (entity) {
      setState(() => _order = OrderModel.fromEntity(entity));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final order = _order;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.85,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Order Details - ${order.orderId}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        _StatusBadge(status: order.status),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 22, color: Color(0xFF555555)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.isDeliveryTrackable) ...[
                      OrderDeliveryLiveSection(orderId: order.id),
                      const SizedBox(height: 12),
                    ],
                    _SectionCard(
                      title: 'Order Status',
                      child: _OrderStatusTimeline(currentStep: order.timelineStep),
                    ),
                    if (order.trackingNumber != null && order.trackingNumber!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Tracking Number',
                        child: Text(
                          order.trackingNumber!,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Order Items',
                      child: _OrderItemsList(order: order),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Purchase Order (PO)',
                      child: _POSection(order: order),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.canTrackOtp)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierColor: Colors.black54,
                          builder: (_) => OrderTrackOtpDialog(order: _order),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: const Text(
                          'TRACK OTP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kPrimaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kBlueAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CARD WRAPPER
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORDER ITEMS LIST
// ─────────────────────────────────────────────
class _OrderItemsList extends StatelessWidget {
  final OrderModel order;

  const _OrderItemsList({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...order.items.map((item) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.product,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  Text(
                    _formatINR(item.total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kBlueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _kvRow('Code', '${item.sku}'),
              const SizedBox(height: 4),
              _kvRow('Quantity', '${item.quantity}'),
              const SizedBox(height: 4),
              _kvRow('Unit Price', _formatINR(item.unitPrice)),
            ],
          ),
        )),
        const Divider(color: Color(0xFFEEEEEE), height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
            ),
            Text(
              _formatINR(order.totalAmount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kBlueAccent),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kvRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
        Text(value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PO SECTION
// ─────────────────────────────────────────────
class _POSection extends StatelessWidget {
  final OrderModel order;

  const _POSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            children: [
              const TextSpan(text: 'PO Number: ', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: order.poNumber),
            ],
          ),
        ),
        if (order.poAttachmentName != null) ...[
          const SizedBox(height: 10),
          const Text(
            'PO Attachment:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Text(
              order.poAttachmentName!,
              style: const TextStyle(
                fontSize: 13,
                color: _kBlueAccent,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.poAttachmentSize ?? '',
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ],
    );
  }
}
