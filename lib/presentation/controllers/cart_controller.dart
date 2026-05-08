import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/product_entity.dart';

class CartItem {
  final String key;
  final ProductEntity product;
  final RxInt quantity;
  CartItem({required this.key, required this.product, int qty = 1}) : quantity = qty.obs;
  double get total => product.price * quantity.value;
}

class CartController extends GetxController {
  static const _storageKey = 'pharmacy_cart_v1';
  final items = <CartItem>[].obs;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity.value);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  double get shipping => items.isEmpty ? 0 : (subtotal > 5000 ? 0 : 100);

  double get tax => subtotal * 0.10;

  double get total => subtotal + shipping + tax;

  bool get isEmpty => items.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Map<String, dynamic> _productToJson(ProductEntity p) {
    return {
      'id': p.id,
      'name': p.name,
      'code': p.code,
      'category': p.category,
      'price': p.price,
      'mrp': p.mrp,
      'unitLabel': p.unitLabel,
      'availableDistributorCount': p.availableDistributorCount,
      'stock': p.stock,
      'imageUrl': p.imageUrl,
      'galleryUrls': p.galleryUrls,
      'description': p.description,
      'isActive': p.isActive,
      'catalogId': p.catalogId,
      'distributorId': p.distributorId,
      'distributorName': p.distributorName,
      'minOrderQty': p.minOrderQty,
      'maxOrderQty': p.maxOrderQty,
    };
  }

  ProductEntity _productFromJson(Map<String, dynamic> m) {
    return ProductEntity(
      id: (m['id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      code: (m['code'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      price: (m['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (m['mrp'] as num?)?.toDouble(),
      unitLabel: (m['unitLabel'] ?? 'piece').toString(),
      availableDistributorCount: (m['availableDistributorCount'] as num?)?.toInt() ?? 0,
      stock: (m['stock'] as num?)?.toInt() ?? 0,
      imageUrl: m['imageUrl']?.toString(),
      galleryUrls: (m['galleryUrls'] is List)
          ? (m['galleryUrls'] as List).map((e) => e.toString()).toList()
          : const [],
      description: m['description']?.toString(),
      isActive: (m['isActive'] as bool?) ?? true,
      catalogId: (m['catalogId'] as num?)?.toInt(),
      distributorId: (m['distributorId'] as num?)?.toInt(),
      distributorName: m['distributorName']?.toString(),
      minOrderQty: (m['minOrderQty'] as num?)?.toInt(),
      maxOrderQty: (m['maxOrderQty'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> _itemToJson(CartItem i) {
    return {
      'key': i.key,
      'quantity': i.quantity.value,
      'product': _productToJson(i.product),
    };
  }

  CartItem? _itemFromJson(Map<String, dynamic> m) {
    try {
      final productRaw = m['product'];
      if (productRaw is! Map) return null;
      final p = _productFromJson(Map<String, dynamic>.from(productRaw));
      final qty = (m['quantity'] as num?)?.toInt() ?? 1;
      final key = (m['key']?.toString() ?? '').trim();
      final resolvedKey = key.isNotEmpty ? key : itemKeyFor(p);
      return CartItem(key: resolvedKey, product: p, qty: qty);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.map(_itemToJson).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Non-blocking: persistence failure shouldn't break cart UX.
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = <CartItem>[];
      for (final e in decoded) {
        if (e is! Map) continue;
        final item = _itemFromJson(Map<String, dynamic>.from(e));
        if (item != null) loaded.add(item);
      }
      if (loaded.isEmpty) return;
      items.assignAll(loaded);
      items.refresh();

      // Best-effort: keep backend snapshot up-to-date after restoring locally.
      try {
        await syncCartToBackend(snapshot: List<CartItem>.from(items));
      } catch (_) {}
    } catch (_) {
      // ignore corrupted storage
    }
  }

  Map<String, dynamic> _buildSyncPayloadFrom(List<CartItem> snapshot) {
    final mapped = snapshot.map((i) {
      final p = i.product;
      final productId = int.tryParse(p.id) ?? 0;
      final qty = i.quantity.value;
      final unitPrice = p.price;
      return {
        'catalog_id': p.catalogId,
        'product_id': productId,
        'distributor_id': p.distributorId,
        'product_name': p.name,
        'distributor_name': p.distributorName,
        'quantity': qty,
        'unit_price': unitPrice,
        'total_price': unitPrice * qty,
        'minimum_order_quantity': p.minOrderQty ?? 1,
        'maximum_order_quantity': p.maxOrderQty,
      };
    }).toList();

    final totalAmount = mapped.fold<double>(
      0.0,
      (sum, it) => sum + ((it['total_price'] as num?)?.toDouble() ?? 0.0),
    );

    return {
      'items': mapped,
      'total_amount': totalAmount,
    };
  }

  Future<void> syncCartToBackend({List<CartItem>? snapshot}) async {
    final api = Get.find<ApiClient>();
    final snap = snapshot ?? List<CartItem>.from(items);
    final payload = _buildSyncPayloadFrom(snap);
    await api.post('/cart/sync', body: payload);
  }

  String itemKeyFor(ProductEntity product) =>
      (product.catalogId != null && product.catalogId! > 0)
          ? product.catalogId!.toString()
          : product.id;

  int getItemCount(String key) {
    final item = items.firstWhereOrNull((i) => i.key == key);
    return item?.quantity.value ?? 0;
  }

  Future<void> addItemWithApi(ProductEntity product, {int quantity = 1}) async {
    final key = itemKeyFor(product);

    // Build a prospective snapshot without mutating local state first.
    final snap = List<CartItem>.from(items);
    final idx = snap.indexWhere((i) => i.key == key);
    if (idx >= 0) {
      final existing = snap[idx];
      final nextQty = existing.quantity.value + quantity;
      snap[idx] = CartItem(key: existing.key, product: existing.product, qty: nextQty);
    } else {
      snap.add(CartItem(key: key, product: product, qty: quantity));
    }

    await syncCartToBackend(snapshot: snap);

    // Apply local update only after backend accepts the snapshot.
    addItem(product, quantity: quantity);
  }

  void addItem(ProductEntity product, {int quantity = 1}) {
    final key = itemKeyFor(product);
    final existing = items.firstWhereOrNull((i) => i.key == key);
    if (existing != null) {
      existing.quantity.value += quantity;
    } else {
      items.add(CartItem(key: key, product: product, qty: quantity));
    }
    items.refresh();
    _saveToPrefs();
  }

  void removeItem(String key) {
    items.removeWhere((i) => i.key == key);
    _saveToPrefs();
  }

  void updateQuantity(String key, int quantity) {
    if (quantity <= 0) {
      removeItem(key);
      return;
    }
    final item = items.firstWhereOrNull((i) => i.key == key);
    if (item != null) {
      item.quantity.value = quantity;
      items.refresh();
      _saveToPrefs();
    }
  }

  void incrementQuantity(String key) {
    final item = items.firstWhereOrNull((i) => i.key == key);
    if (item != null) {
      item.quantity.value++;
      items.refresh();
      _saveToPrefs();
    }
  }

  void decrementQuantity(String key) {
    final item = items.firstWhereOrNull((i) => i.key == key);
    if (item != null) {
      if (item.quantity.value > 1) {
        item.quantity.value--;
        items.refresh();
        _saveToPrefs();
      } else {
        removeItem(key);
      }
    }
  }

  void clearCart() {
    items.clear();
    _saveToPrefs();
  }

  bool isInCart(String key) => items.any((i) => i.key == key);
}
