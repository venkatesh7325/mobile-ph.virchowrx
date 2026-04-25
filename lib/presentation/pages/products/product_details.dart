import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic product; // Replace with your ProductEntity
  const ProductDetailScreen({super.key, this.product});

  // Theme Colors matching the image
  static const Color primaryTeal = Color(0xFF168A7F);
  static const Color darkText = Color(0xFF111827);
  static const Color bgLight = Color(0xFFF6FBF9);
  static const Color cardYellow = Color(0xFFFDF4BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeroImageCard(),
                const SizedBox(height: 24),
                _buildPriceSection(),
                const SizedBox(height: 20),
                _buildCompositionCard(),
                const SizedBox(height: 16),
                _buildDetailGrid(),
                const SizedBox(height: 120), // Space for bottom bar
              ],
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildSquareButton(Icons.chevron_left, () => Get.back()),
      centerTitle: true,
      title: const Text('Product',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif')),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: _buildSquareButton(Icons.more_horiz, () {}),
        ),
      ],
    );
  }

  Widget _buildSquareButton(IconData icon, VoidCallback onTap) {
    return Center(
      child: InkWell(
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
    );
  }

  Widget _buildHeroImageCard() {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: cardYellow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -40, right: -40,
            child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          // SKU Badge
          Positioned(
            top: 24, left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9E8B1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('SKU 52', style: TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
          // Heart Icon
          Positioned(
            top: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border, color: Color(0xFF8B4513), size: 18),
            ),
          ),
          // Medicine Box Image/Visual
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mock medicine box
                Container(
                  width: 220, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      Container(width: 30, color: const Color(0xFFF9E8B1)),
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Diclofenac Sodium', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('Jusgo', style: TextStyle(fontFamily: 'serif', fontSize: 28, color: Color(0xFFB91C1C), fontWeight: FontWeight.bold)),
                            Text('PFS 75mg/mL', style: TextStyle(fontSize: 8, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text('Jusgo', style: TextStyle(fontFamily: 'serif', fontSize: 36, color: Color(0xFF432818), fontWeight: FontWeight.bold)),
                const Text('By Virchow Pharmaceuticals', style: TextStyle(color: Color(0xFF8B4513), fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('DEALER PRICE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.business_center_outlined, size: 14, color: primaryTeal),
                  SizedBox(width: 4),
                  Text('1 distributor', style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('₹110', style: TextStyle(fontFamily: 'serif', fontSize: 42, fontWeight: FontWeight.bold, color: darkText)),
            const Text('.00', style: TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Spacer(),
            const Text('CityMed', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const Text('MRP ₹110.00 · per piece', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCompositionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF134E4A), primaryTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add_box_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COMPOSITION', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                SizedBox(height: 4),
                Text('Each mL contains Diclofenac Sodium I.P. 75 mg, Water for Injections I.P. q.s.',
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailGrid() {
    return Row(
      children: [
        Expanded(child: _buildInfoBox('DOSAGE FORM', 'Injection')),
        const SizedBox(width: 16),
        Expanded(child: _buildInfoBox('PACK', 'PFS')),
      ],
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_center_outlined, color: primaryTeal, size: 20),
                    SizedBox(width: 8),
                    Text('Distributors', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primaryTeal, Color(0xFF0F5A53)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add to cart · ₹110', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
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