import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../core/constants/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../controllers/cart_controller.dart';
import '../../widgets/app_states.dart';
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

  List<_DistributorOffer> _offers = const [];
  bool _offersLoading = false;
  String? _offersError;
  final _distSearchCtrl = TextEditingController();
  String _distState = 'All';
  String _distCity = 'All';
  String _distPincode = 'All';
  final Map<String, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    _heroUrls = _sanitizeHeroUrls(_heroImageUrlsFromEntity(_productEntity()));
    _loadProductImagesFromApi();
    _loadDistributorOffers();
  }

  @override
  void dispose() {
    _distSearchCtrl.dispose();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProductImagesFromApi() async {
    final p = _productEntity();
    if (p == null || p.id.isEmpty) return;
    final result = await Get.find<ProductRepository>().getProductImageUrls(p.id);
    if (!mounted) return;
    result.fold((_) {}, (r) {
      final cleaned = _sanitizeHeroUrls(r.urls);
      if (cleaned.isNotEmpty) {
        setState(() => _heroUrls = cleaned);
      }
    });
  }

  ProductEntity? _productEntity() =>
      widget.product is ProductEntity ? widget.product as ProductEntity : null;

  Future<void> _loadDistributorOffers() async {
    final p = _productEntity();
    if (p == null || p.id.isEmpty) return;
    setState(() {
      _offersLoading = true;
      _offersError = null;
    });
    try {
      final pid = int.tryParse(p.id);
      if (pid == null) {
        setState(() {
          _offers = const [];
          _offersError = 'Invalid product id';
        });
        return;
      }
      final api = Get.find<ApiClient>();
      final res = await api.get('/products/cataloged/by-product/$pid') as Map<String, dynamic>;
      final raw = res['products'];
      if (raw is! List || raw.isEmpty) {
        setState(() {
          _offers = const [];
          _offersError = 'No distributors found';
        });
        return;
      }
      final row = raw.first;
      if (row is! Map) {
        setState(() {
          _offers = const [];
          _offersError = 'Unexpected distributor response';
        });
        return;
      }
      final offers = _DistributorOffer.parseList(Map<String, dynamic>.from(row));
      setState(() => _offers = offers);
    } catch (e) {
      setState(() => _offersError = 'Could not load distributors');
    } finally {
      if (mounted) {
        setState(() => _offersLoading = false);
      }
    }
  }

  /// Fallback URLs from catalog payload before product-images API responds.
  List<String> _heroImageUrlsFromEntity(ProductEntity? p) {
    if (p == null) return [];
    if (p.galleryUrls.isNotEmpty) return List<String>.from(p.galleryUrls);
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) return [p.imageUrl!];
    return [];
  }

  /// Product detail carousel should avoid broken/thumbnail URLs so the user
  /// doesn't see extra "placeholder" pages.
  static List<String> _sanitizeHeroUrls(List<String> raw) {
    final seen = <String>{};
    final out = <String>[];

    bool looksLikeThumb(String u) {
      final s = u.toLowerCase();
      return s.contains('thumb') || s.contains('-thumbs/') || s.contains('/thumbs/');
    }

    void add(String u) {
      final t = u.trim();
      if (t.isEmpty) return;
      if (seen.add(t)) out.add(t);
    }

    // Prefer non-thumbnail URLs first.
    for (final u in raw) {
      if (!looksLikeThumb(u)) add(u);
    }
    // If nothing else exists, allow thumb URLs as a fallback.
    if (out.isEmpty) {
      for (final u in raw) {
        add(u);
      }
    }

    // Keep the carousel reasonable; avoids showing a long list of near-duplicates.
    if (out.length > 8) return out.take(8).toList();
    return out;
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
                  _buildDistributorsSection(),
                  const SizedBox(height: 16),
                  _buildDetailGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
          padding: const EdgeInsets.only(right: 10),
          child: Obx(() {
            final cart = Get.find<CartController>();
            final hasItems = !cart.isEmpty;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _buildSquareButton(
                  Icons.shopping_cart_outlined,
                  () => context.push(AppRoutes.cart),
                ),
                if (hasItems)
                  Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
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

  void _showDistributorsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        minChildSize: 0.50,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: ProductDetailScreen.bgLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _buildDistributorsSection(inSheet: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDistributorsSection({bool inSheet = false}) {
    final p = _productEntity();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          inSheet ? 'Available Distributors' : 'AVAILABLE DISTRIBUTORS',
          style: TextStyle(
            color: inSheet ? ProductDetailScreen.darkText : Colors.grey,
            fontWeight: FontWeight.w800,
            fontSize: inSheet ? 16 : 11,
            letterSpacing: inSheet ? 0 : 1.2,
          ),
        ),
        if (inSheet)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: ProductDetailScreen.darkText),
            tooltip: 'Close',
          )
        else
          TextButton(
            onPressed: _showDistributorsSheet,
            child: const Text('View all', style: TextStyle(color: ProductDetailScreen.primaryTeal)),
          ),
      ],
    );

    if (_offersLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 10),
          const Center(child: Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator())),
        ],
      );
    }

    if (_offersError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(_offersError!, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      );
    }

    final list = _filteredOffers();
    if (list.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 10),
          _buildDistributorFilters(inSheet: inSheet),
          const SizedBox(height: 10),
          const Text('No distributors available', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 10),
        _buildDistributorFilters(inSheet: inSheet),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final o = list[i];
            final qtyCtrl = _qtyControllers.putIfAbsent(o.key, () => TextEditingController(text: '1'));
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE0F2F1),
                        child: Text(
                          o.distributorName.isNotEmpty ? o.distributorName[0].toUpperCase() : 'D',
                          style: const TextStyle(color: ProductDetailScreen.primaryTeal, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          o.distributorName,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: ProductDetailScreen.darkText),
                        ),
                      ),
                      Text(
                        currency.format(o.pharmacyPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ProductDetailScreen.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _miniInfo(Icons.call, o.phone.isNotEmpty ? o.phone : '—'),
                      _miniInfo(Icons.location_on_outlined, o.addressLine.isNotEmpty ? o.addressLine : '—'),
                      _miniInfo(Icons.local_shipping_outlined, 'Min/Max: ${o.minOrder ?? '—'} - ${o.maxOrder ?? '—'}'),
                      if (o.discount != null && o.discount!.trim().isNotEmpty)
                        _miniInfo(Icons.percent, o.discount!),
                      if (o.specialNotes != null && o.specialNotes!.trim().isNotEmpty)
                        _miniInfo(Icons.sticky_note_2_outlined, o.specialNotes!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Qty',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (p == null) ? null : () => _addOfferToCart(p, o, qtyCtrl.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProductDetailScreen.primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('ADD TO CART', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<_DistributorOffer> _filteredOffers() {
    final q = _distSearchCtrl.text.trim().toLowerCase();
    return _offers.where((o) {
      if (_distState != 'All' && o.state.toLowerCase() != _distState.toLowerCase()) return false;
      if (_distCity != 'All' && o.city.toLowerCase() != _distCity.toLowerCase()) return false;
      if (_distPincode != 'All' && o.pincode != _distPincode) return false;
      if (q.isEmpty) return true;
      return o.distributorName.toLowerCase().contains(q) ||
          o.phone.toLowerCase().contains(q) ||
          o.addressLine.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildDistributorFilters({required bool inSheet}) {
    final states = <String>{};
    final cities = <String>{};
    final pincodes = <String>{};
    for (final o in _offers) {
      if (o.state.trim().isNotEmpty) states.add(o.state.trim());
      if (o.city.trim().isNotEmpty) cities.add(o.city.trim());
      if (o.pincode.trim().isNotEmpty) pincodes.add(o.pincode.trim());
    }
    final stateList = ['All', ...states.toList()..sort()];
    final cityList = ['All', ...cities.toList()..sort()];
    final pinList = ['All', ...pincodes.toList()..sort()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_list, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Filter Distributors',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
                fontSize: inSheet ? 13 : 12,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _distSearchCtrl.clear();
                  _distState = 'All';
                  _distCity = 'All';
                  _distPincode = 'All';
                });
              },
              child: const Text('CLEAR FILTERS', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _distSearchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search by Distributor ...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _miniDropdown(
                value: _distState,
                items: stateList,
                hint: 'State',
                onChanged: (v) => setState(() => _distState = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _miniDropdown(
                value: _distCity,
                items: cityList,
                hint: 'City',
                onChanged: (v) => setState(() => _distCity = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _miniDropdown(
                value: _distPincode,
                items: pinList,
                hint: 'Pincode',
                onChanged: (v) => setState(() => _distPincode = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : 'All',
          items: items
              .map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }

  static Widget _miniInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 230),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _addOfferToCart(ProductEntity base, _DistributorOffer offer, String rawQty) {
    final qty = int.tryParse(rawQty.trim()) ?? 1;
    if (qty <= 0) {
      AppSnackBar.showError(context, 'Quantity must be at least 1');
      return;
    }

    final item = ProductEntity(
      id: base.id,
      name: base.name,
      code: base.code,
      category: base.category,
      price: offer.pharmacyPrice,
      mrp: base.mrp,
      unitLabel: base.unitLabel,
      availableDistributorCount: base.availableDistributorCount,
      stock: base.stock,
      imageUrl: base.imageUrl,
      galleryUrls: base.galleryUrls,
      description: base.description,
      isActive: base.isActive,
      catalogId: offer.catalogId,
      distributorId: offer.distributorId,
    );

    Get.find<CartController>().addItem(item, quantity: qty);
    AppSnackBar.showSuccess(context, 'Added to cart');
  }
}

class _DistributorOffer {
  final int? catalogId;
  final int? distributorId;
  final String distributorName;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final double pharmacyPrice;
  final int? minOrder;
  final int? maxOrder;
  final String? discount;
  final String? specialNotes;

  const _DistributorOffer({
    required this.catalogId,
    required this.distributorId,
    required this.distributorName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.pharmacyPrice,
    required this.minOrder,
    required this.maxOrder,
    required this.discount,
    required this.specialNotes,
  });

  String get key => '${catalogId ?? ''}_${distributorId ?? distributorName}';

  static List<_DistributorOffer> parseList(Map<String, dynamic> row) {
    final distributors = row['distributors'];
    if (distributors is! List) return const [];
    final out = <_DistributorOffer>[];

    for (final d in distributors) {
      if (d is! Map) continue;
      final m = Map<String, dynamic>.from(d);
      final dist = m['distributor'] is Map ? Map<String, dynamic>.from(m['distributor'] as Map) : const <String, dynamic>{};
      final name = dist['name']?.toString() ?? 'Distributor';
      final phone = dist['phone']?.toString() ?? '';
      final city = dist['city']?.toString() ?? '';
      final state = dist['state']?.toString() ?? '';
      final pincode = dist['pincode']?.toString() ?? '';
      final addressParts = <String>[
        dist['address']?.toString() ?? '',
        city,
        state,
      ].where((s) => s.trim().isNotEmpty).toList();
      final address = addressParts.join(', ');

      final price = (m['pharmacy_price'] as num?)?.toDouble() ??
          (m['price'] as num?)?.toDouble() ??
          0.0;

      out.add(
        _DistributorOffer(
          catalogId: (m['catalog_id'] as num?)?.toInt(),
          distributorId: (dist['id'] as num?)?.toInt(),
          distributorName: name,
          phone: phone,
          addressLine: address,
          city: city,
          state: state,
          pincode: pincode,
          pharmacyPrice: price,
          minOrder: (m['min_order'] as num?)?.toInt() ?? (m['min_qty'] as num?)?.toInt(),
          maxOrder: (m['max_order'] as num?)?.toInt() ?? (m['max_qty'] as num?)?.toInt(),
          discount: m['discount']?.toString(),
          specialNotes: m['special_notes']?.toString() ?? m['notes']?.toString(),
        ),
      );
    }

    out.sort((a, b) => a.pharmacyPrice.compareTo(b.pharmacyPrice));
    return out;
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
  Timer? _autoTimer;

  static const double _imageHeight = 220;

  int get _pageCount => widget.urls.isEmpty ? 1 : widget.urls.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.urls.length > 1 ? 0.88 : 1.0);
    _startAutoScrollIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _ProductDetailImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.urls.length != widget.urls.length) {
      _index = 0;
      _restartAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _restartAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = null;
    _startAutoScrollIfNeeded();
  }

  void _startAutoScrollIfNeeded() {
    if (widget.urls.length <= 1) return;
    _autoTimer ??= Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_pageController.hasClients) return;
      final next = (_index + 1) % widget.urls.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // If there are no real images, don't render any default/placeholder image.
    if (widget.urls.isEmpty) return const SizedBox.shrink();

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