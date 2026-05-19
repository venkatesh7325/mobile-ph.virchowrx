import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/simple_back_app_bar.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class OrderItem {
  final String product;
  final int sku;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.product,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class OrderModel {
  final String orderId;
  final String poNumber;
  final DateTime placedOn;
  final String status;
  final List<OrderItem> items;
  final String? poAttachmentName;
  final String? poAttachmentSize;

  const OrderModel({
    required this.orderId,
    required this.poNumber,
    required this.placedOn,
    required this.status,
    required this.items,
    this.poAttachmentName,
    this.poAttachmentSize,
  });

  double get totalAmount => items.fold(0, (s, i) => s + i.total);
}

// ─────────────────────────────────────────────
// CONSTANTS / HELPERS
// ─────────────────────────────────────────────
const _kPrimaryGreen = Color(0xFF1B6E4B);
const _kPendingColor = Color(0xFFE07B22);
const _kBlueAccent = Color(0xFF2979D4);
const _kBgColor = Color(0xFFF2F2F7);
const _kBorderColor = Color(0xFFE4E4E4);

String _formatDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final ampm = dt.hour >= 12 ? 'pm' : 'am';
  final min = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm';
}

String _formatINR(double val) {
  final parts = val.toStringAsFixed(2).split('.');
  final intStr = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{2})+\d$)'),
        (m) => '${m[1]},',
  );
  return '₹$intStr.${parts[1]}';
}

// ─────────────────────────────────────────────
// MY ORDERS SCREEN
// ─────────────────────────────────────────────
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final List<OrderModel> _orders = [
    OrderModel(
      orderId: 'ORD-20260426-286',
      poNumber: 'test',
      placedOn: DateTime(2026, 4, 26, 10, 6),
      status: 'Pending',
      items: const [
        OrderItem(product: 'Jusgo', sku: 52, quantity: 10, unitPrice: 110.0),
      ],
      poAttachmentName: 'Kamayani_Mishra_TS03_React_Native_dev.pdf',
      poAttachmentSize: '117.8 KB · Uploaded on 26 Apr 2026, 10:06 am',
    ),
  ];

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
                onTap: () => setState(() {}),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _orders.length,
          itemBuilder: (ctx, i) => _OrderCard(
            order: _orders[i],
            onViewDetails: () => _showOrderDetails(_orders[i]),
          ),
        ),
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
}

// ─────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onViewDetails;

  const _OrderCard({required this.order, required this.onViewDetails});

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
              const _StatusBadge(),
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
          const SizedBox(height: 16),
          const _OrderStatusTimeline(currentStep: 1, isMini: true),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kPendingColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⏳', style: TextStyle(fontSize: 11)),
          SizedBox(width: 5),
          Text('Pending',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
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
class _OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
                        const _StatusBadge(),
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
                    _SectionCard(
                      title: 'Order Status',
                      child: const _OrderStatusTimeline(currentStep: 1),
                    ),
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
            // ⚠️ Plain GestureDetector instead of TextButton — same reason:
            //    avoid any TextButtonTheme that might force min size.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              alignment: Alignment.centerRight,
              child: GestureDetector(
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