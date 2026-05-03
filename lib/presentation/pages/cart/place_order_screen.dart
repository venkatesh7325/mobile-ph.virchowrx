import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/repositories/order_repository.dart';
import '../../controllers/cart_controller.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _selectedPayment = 0;
  final TextEditingController _poController = TextEditingController();
  bool _submitting = false;

  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color accentGreen = Color(0xFF1D9E75);
  static const Color bgColor = Color(0xFFF4FAF7);

  final List<Map<String, dynamic>> _paymentTypes = [
    {'label': 'Pay Later', 'icon': Icons.access_time_outlined},
    {'label': 'Pay Now', 'icon': Icons.credit_card_outlined},
    {'label': 'Manual', 'icon': Icons.account_balance_wallet_outlined},
  ];

  String _paymentMethod() {
    switch (_selectedPayment) {
      case 0:
        return 'credit';
      case 1:
        return 'card';
      default:
        return 'cash';
    }
  }

  String _formatINR(double val) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(val);
  }

  Future<void> _submit() async {
    final cart = Get.find<CartController>();
    final orders = Get.find<OrderRepository>();

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    for (final line in cart.items) {
      final p = line.product;
      if (p.catalogId == null || p.distributorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart contains items without catalog data. Re-add products from the catalog.'),
          ),
        );
        return;
      }
    }

    setState(() => _submitting = true);

    final items = cart.items.map((ci) {
      final p = ci.product;
      final qty = ci.quantity.value;
      final unit = p.price;
      return {
        'catalog_id': p.catalogId,
        'product_id': int.parse(p.id),
        'distributor_id': p.distributorId,
        'quantity': qty,
        'unit_price': unit,
        'total_price': unit * qty,
      };
    }).toList();

    final body = <String, dynamic>{
      'items': items,
      'total_amount': cart.total,
      'payment_method': _paymentMethod(),
    };
    final po = _poController.text.trim();
    if (po.isNotEmpty) {
      body['po_number'] = po;
    }

    final result = await orders.placeOrder(body);

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        cart.clearCart();
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Order placed', style: TextStyle(fontWeight: FontWeight.w700)),
            content: const Text('Your order was sent to the pharmacy backend.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('OK', style: TextStyle(color: primaryGreen)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _poController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNav(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildConfirmTag(),
                    const SizedBox(height: 10),
                    _buildHeadingRow(cart),
                    const SizedBox(height: 20),
                    _buildPharmacyCard(),
                    const SizedBox(height: 22),
                    _buildPONumberField(),
                    const SizedBox(height: 20),
                    _buildUploadPOCopy(),
                    const SizedBox(height: 22),
                    _buildPaymentTypeSection(),
                    const SizedBox(height: 14),
                    _buildPaymentNote(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, cart),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(
            onTap: () => context.pop(),
            child: const Icon(Icons.chevron_left, size: 22, color: primaryGreen),
          ),
          const Text(
            'Place order',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          _navBtn(
            child: const Icon(Icons.info_outline, size: 18, color: primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _navBtn({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0EB),
          borderRadius: BorderRadius.circular(11),
        ),
        child: child,
      ),
    );
  }

  Widget _buildConfirmTag() {
    return Row(
      children: [
        Container(width: 20, height: 2, color: accentGreen),
        const SizedBox(width: 8),
        const Text(
          'CONFIRM YOUR ORDER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.3,
            color: accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadingRow(CartController cart) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 28, color: Color(0xFF0F2D22), height: 1.1),
                children: [
                  TextSpan(text: 'Place ', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                    text: 'order',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatINR(cart.total),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: primaryGreen,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                '${cart.itemCount} ITEMS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPharmacyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'CP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'City Pharmacy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'PH001 · MUMBAI · MAHARASHTRA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPONumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('PO Number', optional: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E8E4), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _poController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: 'e.g. PO-2024-1234',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPOCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Upload PO Copy', optional: true),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.upload_outlined, size: 22, color: accentGreen),
              ),
              const SizedBox(height: 10),
              const Text(
                'Drop file or browse',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF · IMAGE · 5MB MAX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Payment type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 13,
                color: accentGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_paymentTypes.length, (index) {
              final selected = _selectedPayment == index;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPayment = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 110,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: selected ? primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? primaryGreen : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _paymentTypes[index]['icon'] as IconData,
                          size: 24,
                          color: selected ? Colors.white : const Color(0xFF666666),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _paymentTypes[index]['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: selected ? Colors.white : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: accentGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payment will be collected later. You can choose the payment method at the time of delivery.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartController cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _submitting ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Obx(() {
                          return Text(
                            'Place order · ${_formatINR(cart.total)}  →',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool optional = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 4),
          Text(
            '(optional)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
