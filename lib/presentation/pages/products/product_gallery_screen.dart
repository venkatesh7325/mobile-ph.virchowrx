import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductGalleryScreen extends StatelessWidget {
  final dynamic product;
  ProductGalleryScreen({super.key, this.product});

  // State management for the current carousel index
  final RxInt _currentIndex = 1.obs;
  final PageController _pageController = PageController(initialPage: 1);

  static const Color primaryTeal = Color(0xFF168A7F);
  static const Color darkText = Color(0xFF111827);
  static const Color bgLight = Color(0xFFF6FBF9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  _buildMainCarousel(),
                  const SizedBox(height: 24),
                  _buildThumbnailStrip(),
                  const SizedBox(height: 32),
                  _buildProductSummary(),
                ],
              ),
            ),
          ),
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
      title: const Text('Gallery',
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

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PRODUCT IMAGES', style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text('Jusgo · 75mg/mL', style: TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
            ],
          ),
          _buildAutoToggle(),
        ],
      ),
    );
  }

  Widget _buildAutoToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(color: darkText, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Auto', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
            child: const Icon(Icons.pause, color: Colors.white, size: 14),
          )
        ],
      ),
    );
  }

  Widget _buildMainCarousel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 350,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF4BE).withOpacity(0.4),
            borderRadius: BorderRadius.circular(32),
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => _currentIndex.value = idx,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  'https://placeholder.com/medication_box', // Replace with product.imageUrl
                  height: 180,
                  errorBuilder: (_, __, ___) => const Icon(Icons.medication, size: 100, color: Color(0xFF8B4513)),
                ),
              );
            },
          ),
        ),
        // Navigation Arrows
        _buildNavArrow(Icons.chevron_left, left: 30, onTap: () => _pageController.previousPage(duration: 300.milliseconds, curve: Curves.ease)),
        _buildNavArrow(Icons.chevron_right, right: 30, onTap: () => _pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease)),
        // Page Indicator and Index
        Positioned(bottom: 20, child: _buildPageIndicator()),
        Positioned(bottom: 20, right: 40, child: _buildIndexCounter()),
      ],
    );
  }

  Widget _buildNavArrow(IconData icon, {double? left, double? right, required VoidCallback onTap}) {
    return Positioned(
      left: left, right: right,
      child: IconButton(
        onPressed: onTap,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 16),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        bool isSelected = _currentIndex.value == index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B4513) : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    ));
  }

  Widget _buildIndexCounter() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
      child: Text('${_currentIndex.value + 1} / 5', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    ));
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Obx(() {
            bool isSelected = _currentIndex.value == index;
            return GestureDetector(
              onTap: () => _pageController.jumpToPage(index),
              child: Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4BE).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: primaryTeal, width: 2) : null,
                ),
                child: const Icon(Icons.image, color: Colors.white, size: 24),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jusgo', style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
              Text('₹110', style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Diclofenac Sodium I.P. 75mg/mL — Prefilled Syringe (PFS) for I.M/I.V/S.C injection use.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      color: Colors.white,
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 18)),
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
    );
  }
}