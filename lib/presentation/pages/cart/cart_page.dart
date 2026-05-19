import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color subtitleGray = Color(0xFF6B7280);
  static const Color deleteRed = Color(0xFFE53935);

  String _formatINR(double val) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(val);
  }

  int _minQty(ProductEntity p) {
    final m = p.minOrderQty;
    if (m != null && m > 0) return m;
    return 1;
  }

  int _maxQty(ProductEntity p) {
    final m = p.maxOrderQty;
    if (m != null && m > 0) return m;
    if (p.stock > 0) return p.stock;
    return 999999;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (cart.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _BackChip(fallbackRoute: AppRoutes.dashboard),
                        SizedBox(width: 8),
                        Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFD1D5DB)),
                          SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.products);
                      }
                    },
                    child: const Text('Browse catalog', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 420;
                    final titleStyle = TextStyle(
                      fontSize: narrow ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    );
                    final checkout = FilledButton.icon(
                      onPressed: () => context.push(AppRoutes.placeOrderScreen),
                      icon: const Icon(Icons.credit_card, size: 18, color: Colors.white),
                      label: Text(
                        'CHECKOUT (${cart.itemCount} ITEMS)',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.2),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                    final totalText = Text(
                      'Total: ${_formatINR(cart.total)}',
                      style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                    if (narrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              _BackChip(fallbackRoute: AppRoutes.dashboard),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Cart', style: titleStyle)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: totalText),
                              const SizedBox(width: 8),
                              Flexible(child: checkout),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        _BackChip(fallbackRoute: AppRoutes.dashboard),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Cart', style: titleStyle)),
                        Flexible(
                          child: totalText,
                        ),
                        const SizedBox(width: 8),
                        checkout,
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: borderGray),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HorizontalCartCards(
                        cart: cart,
                        format: _formatINR,
                        minQty: _minQty,
                        maxQty: _maxQty,
                        primaryBlue: primaryBlue,
                        borderGray: borderGray,
                        subtitleGray: subtitleGray,
                        deleteRed: deleteRed,
                      ),
                      const SizedBox(height: 20),
                      _OrderSummary(
                        cart: cart,
                        format: _formatINR,
                        primaryBlue: primaryBlue,
                        borderGray: borderGray,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  final String fallbackRoute;

  const _BackChip({required this.fallbackRoute});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(fallbackRoute);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Icon(Icons.chevron_left, color: CartScreen.primaryBlue.withOpacity(0.9)),
        ),
      ),
    );
  }
}

class _HorizontalCartCards extends StatelessWidget {
  final CartController cart;
  final String Function(double) format;
  final int Function(ProductEntity) minQty;
  final int Function(ProductEntity) maxQty;
  final Color primaryBlue;
  final Color borderGray;
  final Color subtitleGray;
  final Color deleteRed;

  const _HorizontalCartCards({
    required this.cart,
    required this.format,
    required this.minQty,
    required this.maxQty,
    required this.primaryBlue,
    required this.borderGray,
    required this.subtitleGray,
    required this.deleteRed,
  });

  static const double _cardWidth = 288;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cart.items.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                SizedBox(
                  width: _cardWidth,
                  child: _CartItemCard(
                    item: cart.items[i],
                    cart: cart,
                    format: format,
                    minQ: minQty(cart.items[i].product),
                    maxQ: maxQty(cart.items[i].product),
                    primaryBlue: primaryBlue,
                    borderGray: borderGray,
                    subtitleGray: subtitleGray,
                    deleteRed: deleteRed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController cart;
  final String Function(double) format;
  final int minQ;
  final int maxQ;
  final Color primaryBlue;
  final Color borderGray;
  final Color subtitleGray;
  final Color deleteRed;

  const _CartItemCard({
    required this.item,
    required this.cart,
    required this.format,
    required this.minQ,
    required this.maxQ,
    required this.primaryBlue,
    required this.borderGray,
    required this.subtitleGray,
    required this.deleteRed,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final distributorLabel =
        (p.distributorName != null && p.distributorName!.trim().isNotEmpty) ? p.distributorName!.trim() : '—';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGray),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF111827),
                    height: 1.25,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () => cart.removeItem(item.key),
                icon: Icon(Icons.delete_outline, color: deleteRed, size: 22),
                tooltip: 'Remove',
              ),
            ],
          ),
          Text(
            'Min: $minQ | Max: $maxQ',
            style: TextStyle(fontSize: 11, color: subtitleGray),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryBlue.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.storefront_outlined, size: 20, color: primaryBlue.withOpacity(0.9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distributor',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: subtitleGray, letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        distributorLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A5F),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit price',
                      style: TextStyle(fontSize: 11, color: subtitleGray, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      format(p.price),
                      style: TextStyle(fontWeight: FontWeight.w700, color: primaryBlue, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Quantity',
                    style: TextStyle(fontSize: 11, color: subtitleGray, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _QtyField(
                      item: item,
                      cart: cart,
                      minQ: minQ,
                      maxQ: maxQ,
                      borderGray: borderGray,
                      subtitleGray: subtitleGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Divider(height: 1, color: borderGray.withOpacity(0.85)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Line total',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              Obx(() => Text(
                    format(item.total),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827)),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyField extends StatefulWidget {
  final CartItem item;
  final CartController cart;
  final int minQ;
  final int maxQ;
  final Color borderGray;
  final Color subtitleGray;

  const _QtyField({
    required this.item,
    required this.cart,
    required this.minQ,
    required this.maxQ,
    required this.borderGray,
    required this.subtitleGray,
  });

  @override
  State<_QtyField> createState() => _QtyFieldState();
}

class _QtyFieldState extends State<_QtyField> {
  late TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.item.quantity.value}');
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasPrimaryFocus) {
      _commit();
    }
  }

  void _commit() {
    final raw = int.tryParse(_controller.text.trim());
    if (raw == null) {
      _controller.text = '${widget.item.quantity.value}';
      return;
    }
    var q = raw;
    if (q < widget.minQ) q = widget.minQ;
    if (q > widget.maxQ) q = widget.maxQ;
    if (q <= 0) {
      widget.cart.removeItem(widget.item.key);
      return;
    }
    widget.cart.updateQuantity(widget.item.key, q);
    if (_controller.text != '$q') {
      _controller.text = '$q';
    }
  }

  @override
  void didUpdateWidget(covariant _QtyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity.value != widget.item.quantity.value && !_focus.hasFocus) {
      _controller.text = '${widget.item.quantity.value}';
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 36,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: widget.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: widget.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: CartScreen.primaryBlue, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _commit(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Min: ${widget.minQ}, Max: ${widget.maxQ}',
          style: TextStyle(fontSize: 10, color: widget.subtitleGray),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartController cart;
  final String Function(double) format;
  final Color primaryBlue;
  final Color borderGray;

  const _OrderSummary({
    required this.cart,
    required this.format,
    required this.primaryBlue,
    required this.borderGray,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGray),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _summaryRow('Total Items', '${cart.itemCount}'),
                Divider(height: 1, color: borderGray.withOpacity(0.9)),
                _summaryRow('Subtotal', format(cart.subtotal)),
                Divider(height: 1, color: borderGray.withOpacity(0.9)),
                _summaryRow('GST', format(cart.tax)),
                if (cart.shipping > 0) ...[
                  Divider(height: 1, color: borderGray.withOpacity(0.9)),
                  _summaryRow('Delivery / fees', format(cart.shipping)),
                ],
                Divider(height: 1, color: borderGray.withOpacity(0.9)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF374151)),
                      ),
                      Text(
                        format(cart.total),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: primaryBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
