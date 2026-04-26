import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ph_virchowrx/presentation/pages/cart/place_order_screen.dart';

import '../../../core/constants/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _qty = 10;
  static const double _unitPrice = 110.0;
  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color bgColor = Color(0xFFF4FAF7);

  double get _subtotal => _qty * _unitPrice;
  double get _gst => 0.0;
  double get _total => _subtotal + _gst;

  String _formatINR(double val) {
    final intPart = val.toInt();
    final decPart = ((val - intPart) * 100).round();
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+\d$)'),
          (m) => '${m[1]},',
    );
    if (decPart == 0) return '₹$formatted';
    return '₹$formatted.${decPart.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // Removed bottomNavigationBar from here
      body: SafeArea(
        child: Stack(
          children: [
            // 1. THE SCROLLABLE LAYER
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTopNav(context),
                  const SizedBox(height: 20),
                  _buildDistributorHeader(),
                  const SizedBox(height: 12),
                  _buildCartItem(),
                  const SizedBox(height: 20),
                  _buildOrderSummary(),
                  const SizedBox(height: 14),
                  _buildDiscountBanner(),
                  // IMPORTANT: Extra height so the checkout bar doesn't cover the bottom content
                  const SizedBox(height: 140),
                ],
              ),
            ),

            // 2. THE FIXED FOOTER LAYER
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCheckoutBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.chevron_left, onTap: () => Navigator.pop(context)),
        Row(
          children: [
            const Text(
              'Cart',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_qty items',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F6E56)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _iconBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: primaryGreen),
      ),
    );
  }

  Widget _buildDistributorHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('CM', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CityMed Wholesale',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Text(
                'DIST002 · BANER, PUNE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Edit',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75)),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_outlined, color: Color(0xFFF5A623), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jusgo',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diclofenac · 75mg/mL · INJ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFBBBBBB)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildQtyControl(),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatINR(_total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F2D22),
                    ),
                  ),
                  Text(
                    '${_formatINR(_unitPrice)} × $_qty',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() { if (_qty > 1) _qty--; }),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              child: const Text('−', style: TextStyle(fontSize: 20, color: Color(0xFF555555))),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$_qty',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _qty++),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              child: const Text('+', style: TextStyle(fontSize: 20, color: Color(0xFF555555))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
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
              _summaryRow('Total items', '$_qty', isNormal: true),
              const SizedBox(height: 12),
              _summaryRow('Subtotal', _formatINR(_subtotal), isNormal: true),
              const SizedBox(height: 12),
              _summaryRow('GST (incl.)', _formatINR(_gst), isNormal: true),
              const SizedBox(height: 12),
              _summaryRow('Delivery', 'Free', isFree: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
              ),
              _buildTotalRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isNormal = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isFree ? const Color(0xFF1D9E75) : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL AMOUNT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF888888), letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            Text(
              'All taxes included',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF0F2D22), fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: _formatINR(_total),
                style: const TextStyle(fontSize: 26),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE8A0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.sell_outlined, size: 20, color: Color(0xFFF5A623)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply discount code',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Save up to 5% on bulk orders',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF888888), size: 22),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () {
         // Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceOrderScreen()));
          context.push(AppRoutes.placeOrderScreen);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: const Color(0xFF0F6E56),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Checkout · $_qty items · ${_formatINR(_total)}  →',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}