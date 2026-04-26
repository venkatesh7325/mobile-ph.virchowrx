import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductInfoScreen extends StatelessWidget {
  final dynamic product;
  const ProductInfoScreen({super.key, this.product});

  // Theme Colors from design
  static const Color primaryTeal = Color(0xFF168A7F);
  static const Color darkText = Color(0xFF111827);
  static const Color bgLight = Color(0xFFF6FBF9);
  static const Color cardYellow = Color(0xFFFDF4BE);
  static const Color mutedText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      // Replace Stack with Column
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildProductHeader(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('COMPOSITION'),
                  const SizedBox(height: 8),
                  const Text(
                    'Each mL contains Diclofenac Sodium I.P. 75 mg, Water for Injections I.P. q.s.',
                    style: TextStyle(color: darkText, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('DESCRIPTION'),
                  const SizedBox(height: 8),
                  const Text(
                    'A clear, colorless to yellowish liquid for I.M / I.V / S.C injection use, indicated for acute pain & inflammation.',
                    style: TextStyle(color: mutedText, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildSpecificationGrid(),
                  const SizedBox(height: 24),
                  _buildAvailabilityCard(),
                  const SizedBox(height: 20), // Just a little breathing room
                ],
              ),
            ),
          ),
          // This stays outside the Expanded to remain "Sticky"
          _buildBottomAction(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildSquareButton(Icons.chevron_left, () => Get.back()),
      centerTitle: true,
      title: const Text('Product info',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif')),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: _buildSquareButton(Icons.shopping_cart_outlined, () {}, badge: '10'),
        ),
      ],
    );
  }

  Widget _buildSquareButton(IconData icon, VoidCallback onTap, {String? badge}) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(icon, color: primaryTeal, size: 20),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -5, right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFF27B7B), shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: cardYellow,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: const Icon(Icons.medication_liquid, color: Color(0xFF8B4513), size: 36),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 1, color: primaryTeal),
                  const SizedBox(width: 6),
                  const Text('DICLOFENAC SODIUM', style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              const Text('Jusgo', style: TextStyle(fontFamily: 'serif', fontSize: 32, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildBadge(Icons.circle, 'In stock', Colors.green, const Color(0xFFDCFCE7)),
                  const SizedBox(width: 8),
                  const Text('SKU 52', style: TextStyle(color: mutedText, fontSize: 12)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTabItem('Information', active: true),
        _buildTabItem('Availability', active: false),
        _buildTabItem('Reviews', active: false),
      ],
    );
  }

  Widget _buildTabItem(String label, {required bool active}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: active ? darkText : mutedText, fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        if (active) const SizedBox(height: 8),
        if (active) Container(width: 40, height: 2, color: primaryTeal),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1));
  }

  Widget _buildSpecificationGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSpecItem('BRAND', 'Virchow'),
              Container(width: 1, height: 60, color: Colors.grey.shade100),
              _buildSpecItem('DOSAGE FORM', 'Injection'),
            ],
          ),
          Container(height: 1, color: Colors.grey.shade100),
          Row(
            children: [
              _buildSpecItem('UNIT', 'Piece'),
              Container(width: 1, height: 60, color: Colors.grey.shade100),
              _buildSpecItem('PACK TYPE', 'Box · 1 unit'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: mutedText, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: darkText, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.business_center_outlined, color: primaryTeal),
          SizedBox(width: 16),
          Text('Availability', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
          Spacer(),
          Text('1', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryTeal, Color(0xFF0F5A53)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add to cart · ₹110', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}