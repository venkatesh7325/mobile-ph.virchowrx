import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../widgets/product_network_image.dart';

class ProductGalleryScreen extends StatefulWidget {
  final dynamic product;
  const ProductGalleryScreen({super.key, this.product});

  static const Color primaryTeal = Color(0xFF168A7F);
  static const Color darkText = Color(0xFF111827);
  static const Color bgLight = Color(0xFFF6FBF9);

  @override
  State<ProductGalleryScreen> createState() => _ProductGalleryScreenState();
}

class _ProductGalleryScreenState extends State<ProductGalleryScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  /// From catalog first; replaced by `GET /product-images/product/:id` when non-empty.
  List<String> _displayUrls = [];

  @override
  void initState() {
    super.initState();
    _displayUrls = List<String>.from(_urlsFromEntity());
    _pageController = PageController();
    _loadProductImagesFromApi();
  }

  List<String> _urlsFromEntity() {
    final p = widget.product;
    if (p is ProductEntity) {
      if (p.galleryUrls.isNotEmpty) return p.galleryUrls;
      if (p.imageUrl != null && p.imageUrl!.isNotEmpty) return [p.imageUrl!];
    }
    return [];
  }

  Future<void> _loadProductImagesFromApi() async {
    final p = _productEntity;
    if (p == null || p.id.isEmpty) return;
    final result = await Get.find<ProductRepository>().getProductImageUrls(p.id);
    if (!mounted) return;
    result.fold((_) {}, (r) {
      if (r.urls.isEmpty) return;
      _pageController.dispose();
      _pageController = PageController();
      setState(() {
        _displayUrls = r.urls;
        _pageIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _pageCount => _displayUrls.isEmpty ? 1 : _displayUrls.length;

  ProductEntity? get _productEntity => widget.product is ProductEntity ? widget.product as ProductEntity : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProductGalleryScreen.bgLight,
      appBar: _buildAppBar(context),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildSquareButton(Icons.chevron_left, () => context.pop()),
      centerTitle: true,
      title: Text('Gallery',
          style: AppTypography.titleLarge.copyWith(color: ProductGalleryScreen.darkText)),
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
              child: Icon(icon, color: ProductGalleryScreen.primaryTeal, size: 20),
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
    final p = _productEntity;
    final title = p?.name ?? 'Product';
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PRODUCT IMAGES', style: TextStyle(color: ProductGalleryScreen.primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text(title, style: AppTypography.headlineMedium.copyWith(color: ProductGalleryScreen.darkText)),
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
      decoration: BoxDecoration(color: ProductGalleryScreen.darkText, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Auto', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: ProductGalleryScreen.primaryTeal, shape: BoxShape.circle),
            child: const Icon(Icons.pause, color: Colors.white, size: 14),
          )
        ],
      ),
    );
  }

  Widget _carouselPlaceholder() {
    return const Center(
      child: Icon(Icons.medication, size: 100, color: Color(0xFF8B4513)),
    );
  }

  Widget _buildMainCarousel() {
    final urls = _displayUrls;
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
            key: ValueKey(urls.join('|')),
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _pageIndex = idx),
            itemCount: _pageCount,
            itemBuilder: (context, index) {
              if (urls.isEmpty) return _carouselPlaceholder();
              return Center(
                child: ProductNetworkImage(
                  imageUrl: urls[index],
                  height: 220,
                  width: MediaQuery.sizeOf(context).width - 80,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(16),
                  fallback: _carouselPlaceholder(),
                ),
              );
            },
          ),
        ),
        if (_pageCount > 1) ...[
          _buildNavArrow(
            Icons.chevron_left,
            left: 30,
            onTap: () {
              if (_pageIndex > 0) {
                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              }
            },
          ),
          _buildNavArrow(
            Icons.chevron_right,
            right: 30,
            onTap: () {
              if (_pageIndex < _pageCount - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              }
            },
          ),
        ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pageCount, (index) {
        final isSelected = _pageIndex == index;
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
    );
  }

  Widget _buildIndexCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
      child: Text('${_pageIndex + 1} / $_pageCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _thumbFallback() {
    return const Center(child: Icon(Icons.image_outlined, color: Color(0xFF8B4513), size: 28));
  }

  Widget _buildThumbnailStrip() {
    final urls = _displayUrls;
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pageCount,
        itemBuilder: (context, index) {
          final isSelected = _pageIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _pageIndex = index);
              _pageController.jumpToPage(index);
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4BE).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: ProductGalleryScreen.primaryTeal, width: 2) : null,
              ),
              child: urls.isEmpty
                  ? _thumbFallback()
                  : ProductNetworkImage(
                      imageUrl: urls[index],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                      fallback: _thumbFallback(),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSummary() {
    final p = _productEntity;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final name = p?.name ?? 'Product';
    final priceLine = p != null ? currency.format(p.price) : '—';
    final desc = p?.description ??
        'Diclofenac Sodium I.P. 75mg/mL — Prefilled Syringe (PFS) for I.M/I.V/S.C injection use.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name, style: AppTypography.productTitle(fontSize: 20, color: ProductGalleryScreen.darkText)),
              ),
              Text(priceLine, style: AppTypography.productTitle(fontSize: 20, color: ProductGalleryScreen.darkText)),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
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
            gradient: const LinearGradient(colors: [ProductGalleryScreen.primaryTeal, Color(0xFF0F5A53)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _productEntity != null ? 'Add to cart · ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(_productEntity!.price)}' : 'Add to cart',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
