import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/repositories/order_repository.dart';
import 'order_delivery_live_section.dart';
import 'order_ui_model.dart';

/// Full-screen-style order tracking dialog with live map, OTP, and order details.
class OrderTrackOtpDialog extends StatefulWidget {
  final OrderModel order;

  const OrderTrackOtpDialog({super.key, required this.order});

  @override
  State<OrderTrackOtpDialog> createState() => _OrderTrackOtpDialogState();
}

class _OrderTrackOtpDialogState extends State<OrderTrackOtpDialog> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final result = await Get.find<OrderRepository>().getOrderById(_order.id);
    if (!mounted) return;
    result.fold((_) {}, (entity) {
      setState(() => _order = OrderModel.fromEntity(entity));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.92,
          maxWidth: 520,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_order.isDeliveryTrackable) ...[
                      OrderDeliveryLiveSection(orderId: _order.id),
                      const SizedBox(height: 12),
                    ],
                    _TrackSectionCard(
                      title: 'Order Status',
                      child: _TrackTimeline(order: _order),
                    ),
                    const SizedBox(height: 12),
                    _TrackSectionCard(
                      title: 'Order Items',
                      child: _TrackOrderItemsTable(order: _order),
                    ),
                    if (_order.poNumber != '—' ||
                        _order.poAttachmentName != null ||
                        _order.poAttachmentUrl != null) ...[
                      const SizedBox(height: 12),
                      _TrackSectionCard(
                        title: 'Purchase Order (PO)',
                        child: _TrackPoSection(order: _order),
                      ),
                    ],
                    if (_order.distributorNotes != null &&
                        _order.distributorNotes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TrackSectionCard(
                        title: 'Distributor Notes',
                        child: Text(
                          _order.distributorNotes!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.45),
                        ),
                      ),
                    ],
                    if (_order.deliveryAddress != null &&
                        _order.deliveryAddress!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TrackSectionCard(
                        title: 'Delivery Address',
                        child: Text(
                          _order.deliveryAddress!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333333),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                    if (_order.invoiceNumber != null &&
                        _order.invoiceNumber!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TrackSectionCard(
                        title: 'Invoice Number',
                        child: Text(
                          _order.invoiceNumber!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: orderBlueAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
                  'Order Details - ${_order.orderId}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                _TrackStatusBadge(status: _order.status),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 22, color: Color(0xFF555555)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _TrackStatusBadge extends StatelessWidget {
  final String status;
  const _TrackStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final (icon, bg) = switch (s) {
      'delivered' => ('✓', orderPrimaryGreen),
      'shipped' => ('🚚', const Color(0xFF7C3AED)),
      'processing' || 'approved' => ('⚙️', orderBlueAccent),
      'cancelled' => ('❌', const Color(0xFFE53935)),
      _ => ('⏳', orderPendingColor),
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

class _TrackSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _TrackSectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orderBorderColor),
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

class _TrackTimeline extends StatelessWidget {
  final OrderModel order;
  const _TrackTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep('Order Placed', order.placedOn, 1),
      _TimelineStep('Approved', order.processedAt, 2),
      _TimelineStep('Processing', order.processedAt, 3),
      _TimelineStep('Shipped', order.shippedAt, 4),
      _TimelineStep('Delivered', order.deliveredAt, 5),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final done = order.timelineStep >= step.index;
        final isLast = i == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 34,
                child: Column(
                  children: [
                    _circle(step.index, done),
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
                  padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      if (done && step.date != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          formatOrderDateTime(step.date!),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
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

  Widget _circle(int number, bool done) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: done ? orderPrimaryGreen : const Color(0xFFBDBDBD),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final DateTime? date;
  final int index;
  const _TimelineStep(this.label, this.date, this.index);
}

class _TrackOrderItemsTable extends StatelessWidget {
  final OrderModel order;
  const _TrackOrderItemsTable({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(flex: 3, child: _TableHeader('Product')),
            Expanded(child: _TableHeader('SKU')),
            Expanded(child: _TableHeader('Qty')),
            Expanded(flex: 2, child: _TableHeader('Unit Price', alignRight: true)),
            Expanded(flex: 2, child: _TableHeader('Total', alignRight: true)),
          ],
        ),
        const Divider(height: 20, color: Color(0xFFEEEEEE)),
        ...order.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.product,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.sku}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatOrderInr(item.unitPrice),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatOrderInr(item.total),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 16, color: Color(0xFFEEEEEE)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
            ),
            Text(
              formatOrderInr(order.totalAmount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: orderBlueAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final bool alignRight;
  const _TableHeader(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888888),
      ),
    );
  }
}

class _TrackPoSection extends StatelessWidget {
  final OrderModel order;
  const _TrackPoSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.poNumber != '—')
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
          Text(
            order.poAttachmentName!,
            style: const TextStyle(
              fontSize: 13,
              color: orderBlueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
          if (order.poAttachmentSize != null) ...[
            const SizedBox(height: 4),
            Text(
              order.poAttachmentSize!,
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
            ),
          ],
        ],
      ],
    );
  }
}
