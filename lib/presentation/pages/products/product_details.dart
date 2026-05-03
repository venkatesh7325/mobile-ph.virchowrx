import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../widgets/product_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  const ProductDetailScreen({super.key, this.product});

  static const Color primaryTeal = Color(0xFF168A7F);
  static const Color darkText = Color(0xFF111827);
  static const Color bgLight = Color(0xFFF6FBF9);
  static const Color cardYellow = Color(0xFFFDF4BE);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  /// Shown in the hero carousel; starts from catalog entity, then replaced by
  /// [ProductRepository.getProductImageUrls] when the product-images API returns URLs.
  List<String> _heroUrls = [];

  @override
  void initState() {
    super.initState();
    _heroUrls = _heroImageUrlsFromEntity(_productEntity());
    _loadProductImagesFromApi();
  }

  Future<void> _loadProductImagesFromApi() async {
    final p = _productEntity();
    if (p == null || p.id.isEmpty) return;
    final result = await Get.find<ProductRepository>().getProductImageUrls(p.id);
    if (!mounted) return;
    result.fold((_) {}, (r) {
      if (r.urls.isNotEmpty) {
        setState(() => _heroUrls = r.urls);
      }
    });
  }

  ProductEntity? _productEntity() =>
      widget.product is ProductEntity ? widget.product as ProductEntity : null;

  /// Fallback URLs from catalog payload before product-images API responds.
  List<String> _heroImageUrlsFromEntity(ProductEntity? p) {
    if (p == null) return [];
    if (p.galleryUrls.isNotEmpty) return List<String>.from(p.galleryUrls);
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) return [p.imageUrl!];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: ProductDetailScreen.bgLight,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildHeroImageCard(context),
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
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildSquareButton(Icons.chevron_left, () => context.pop()),
      centerTitle: true,
      title: const Text('Product',
          style: TextStyle(color: ProductDetailScreen.darkText, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif')),
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
          child: Icon(icon, color: ProductDetailScreen.primaryTeal, size: 20),
        ),
      ),
    );
  }

  Widget _buildHeroImageCard(BuildContext context) {
    final p = _productEntity();
    final urls = _heroUrls;
    final w = MediaQuery.sizeOf(context).width - 40;
    final mockName = p?.name ?? 'Jusgo';
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 380),
      decoration: BoxDecoration(
        color: ProductDetailScreen.cardYellow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40, right: -40,
            child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            top: 24, left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9E8B1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p != null && p.code.isNotEmpty ? 'SKU ${p.code}' : 'SKU',
                style: const TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
          Positioned(
            top: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border, color: Color(0xFF8B4513), size: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 48, left: 12, right: 12, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProductDetailImageCarousel(
                  key: ValueKey(urls.join('|')),
                  urls: urls,
                  width: w,
                  mockFallback: _mockHeroBox(mockName),
                ),
                const SizedBox(height: 16),
                Text(
                  p?.name ?? 'Product',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: urls.isEmpty ? 36 : 28,
                    color: const Color(0xFF432818),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('By Virchow Pharmaceuticals', style: TextStyle(color: Color(0xFF8B4513), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockHeroBox(String brandLine) {
    return Container(
      width: 220,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(width: 30, color: const Color(0xFFF9E8B1)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Diclofenac Sodium', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(brandLine, style: const TextStyle(fontFamily: 'serif', fontSize: 28, color: Color(0xFFB91C1C), fontWeight: FontWeight.bold)),
                const Text('PFS 75mg/mL', style: TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final p = _productEntity();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final whole = p != null ? currency.format(p.price) : '₹110.00';
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
                  Icon(Icons.business_center_outlined, size: 14, color: ProductDetailScreen.primaryTeal),
                  SizedBox(width: 4),
                  Text('1 distributor', style: TextStyle(color: ProductDetailScreen.primaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(whole, style: const TextStyle(fontFamily: 'serif', fontSize: 42, fontWeight: FontWeight.bold, color: ProductDetailScreen.darkText)),
            const Spacer(),
            const Text('CityMed', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Text('MRP $whole · per piece', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCompositionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF134E4A), ProductDetailScreen.primaryTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
          Text(value, style: const TextStyle(color: ProductDetailScreen.darkText, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
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
                    Icon(Icons.business_center_outlined, color: ProductDetailScreen.primaryTeal, size: 20),
                    SizedBox(width: 8),
                    Text('Distributors', style: TextStyle(color: ProductDetailScreen.primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [ProductDetailScreen.primaryTeal, Color(0xFF0F5A53)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    context.push(AppRoutes.productInfo, extra: widget.product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _productEntity() != null
                            ? 'Add to cart · ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(_productEntity()!.price)}'
                            : 'Add to cart · ₹110',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

/// Horizontally swipeable product images with dot indicators.
class _ProductDetailImageCarousel extends StatefulWidget {
  final List<String> urls;
  final double width;
  final Widget mockFallback;

  const _ProductDetailImageCarousel({
    super.key,
    required this.urls,
    required this.width,
    required this.mockFallback,
  });

  @override
  State<_ProductDetailImageCarousel> createState() => _ProductDetailImageCarouselState();
}

class _ProductDetailImageCarouselState extends State<_ProductDetailImageCarousel> {
  late final PageController _pageController;
  int _index = 0;

  static const double _imageHeight = 220;

  int get _pageCount => widget.urls.isEmpty ? 1 : widget.urls.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.urls.length > 1 ? 0.88 : 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _imageHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pageCount,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              if (widget.urls.isEmpty) {
                return Center(child: widget.mockFallback);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ProductNetworkImage(
                  imageUrl: widget.urls[i],
                  width: widget.width,
                  height: _imageHeight,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(12),
                  fallback: Center(
                    child: Icon(Icons.medication, size: 72, color: Colors.brown.withOpacity(0.35)),
                  ),
                ),
              );
            },
          ),
        ),
        if (_pageCount > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pageCount, (i) {
              final active = _index == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF8B4513) : Colors.grey.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}