import 'package:flutter/material.dart';

import '../../widgets/top_nav_cart_button.dart';

class DistributorDetailScreen extends StatefulWidget {
  const DistributorDetailScreen({super.key});

  @override
  State<DistributorDetailScreen> createState() => _DistributorDetailScreenState();
}

class _DistributorDetailScreenState extends State<DistributorDetailScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Antibiotics', 'Pain mgmt', 'Surgical'];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Jusgo',
      'subtitle': 'Diclofenac · INJ',
      'price': 110.0,
      'qty': 10,
      'hasQty': true,
      'iconBg': Color(0xFFFFF8E1),
      'iconColor': Color(0xFFF5A623),
      'icon': Icons.medication_outlined,
    },
    {
      'name': 'Ranivox',
      'subtitle': 'Ranitidine · INJ',
      'price': 153.75,
      'qty': 0,
      'hasQty': false,
      'iconBg': Color(0xFFE8F4FD),
      'iconColor': Color(0xFF378ADD),
      'icon': Icons.add_circle_outline,
    },
    {
      'name': 'Cefovix',
      'subtitle': 'Cefuroxime · INJ',
      'price': 220.0,
      'qty': 0,
      'hasQty': false,
      'iconBg': Color(0xFFE8F8F2),
      'iconColor': Color(0xFF1D9E75),
      'icon': Icons.add_box_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildTopNav(context),
                    const SizedBox(height: 16),
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildProductsHeader(),
                    const SizedBox(height: 12),
                    _buildCategoryTabs(),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductItem(index),
                  childCount: _products.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left, size: 22, color: Color(0xFF1D9E75)),
          ),
        ),
        const Text(
          'Distributor',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        const TopNavCartButton(),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F6E56), Color(0xFF085041)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderTop(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 14),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTop() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: const Center(
            child: Text(
              'CM',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'CityMed Wholesale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 11, color: Colors.white.withOpacity(0.6)),
                  const SizedBox(width: 3),
                  Text(
                    'Baner, Pune, Maharashtra',
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _statItem('324', 'PRODUCTS'),
            _statDivider(),
            _statItem('1.2K', 'ORDERS'),
            _statDivider(),
            _statItem('4.9', 'RATING', suffix: '/5'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, {String? suffix}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1,
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _actionBtn(Icons.phone_outlined, 'Call')),
        const SizedBox(width: 10),
        Expanded(child: _actionBtn(Icons.mail_outline, 'Enquiry')),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Available products',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            '324 products →',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final selected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0F2D22) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: selected ? null : Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final product = _products[index];
    final bool hasQty = product['hasQty'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: product['iconBg'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(product['icon'] as IconData, color: product['iconColor'] as Color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  product['subtitle'] as String,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
          ),
          Text(
            '₹${_formatPrice(product['price'] as double)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 8),
          if (hasQty)
            _buildQtyControl(index)
          else
            _buildAddButton(index),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.truncateToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  Widget _buildQtyControl(int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_products[index]['qty'] > 0) {
                  _products[index]['qty'] = (_products[index]['qty'] as int) - 1;
                  if (_products[index]['qty'] == 0) {
                    _products[index]['hasQty'] = false;
                  }
                }
              });
            },
            child: Container(
              width: 30,
              height: 30,
              child: const Center(
                child: Text('−', style: TextStyle(fontSize: 18, color: Color(0xFF555555))),
              ),
            ),
          ),
          Text(
            '${_products[index]['qty']}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _products[index]['qty'] = (_products[index]['qty'] as int) + 1;
              });
            },
            child: Container(
              width: 30,
              height: 30,
              child: const Center(
                child: Text('+', style: TextStyle(fontSize: 18, color: Color(0xFF555555))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _products[index]['hasQty'] = true;
          _products[index]['qty'] = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0F6E56),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Text(
          '+ Add',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}