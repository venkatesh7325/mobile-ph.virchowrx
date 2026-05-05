import '../../core/utils/resolve_image_url.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.code,
    required super.category,
    required super.price,
    super.mrp,
    super.unitLabel,
    super.availableDistributorCount,
    required super.stock,
    super.imageUrl,
    super.galleryUrls,
    super.description,
    super.isActive,
    super.catalogId,
    super.distributorId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final urls = _galleryUrlsFromProductMap(json);
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? json['sku'] ?? '',
      category: () {
        final c = json['category'];
        if (c is String) return c;
        if (c is Map<String, dynamic>) return c['name']?.toString() ?? '';
        return '';
      }(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ??
          (json['mrp_price'] as num?)?.toDouble() ??
          (json['mrp_amount'] as num?)?.toDouble(),
      unitLabel: json['unit']?.toString() ??
          json['unit_label']?.toString() ??
          json['unit_type']?.toString() ??
          'piece',
      availableDistributorCount: (json['available_distributors'] as num?)?.toInt() ??
          (json['distributor_count'] as num?)?.toInt() ??
          0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: urls.isNotEmpty ? urls.first : null,
      galleryUrls: urls,
      description: json['description'],
      isActive: json['is_active'] ?? true,
      catalogId: (json['catalog_id'] as num?)?.toInt(),
      distributorId: (json['distributor_id'] as num?)?.toInt(),
    );
  }

  /// One row from `GET /products/cataloged` (`product` + `distributors[]`).
  factory ProductModel.fromCatalogEntry(Map<String, dynamic> row) {
    final product = row['product'] as Map<String, dynamic>? ?? {};
    final distributors = (row['distributors'] as List?) ?? const [];
    final chosen = _pickDistributor(distributors);

    final catalogId = (chosen?['catalog_id'] as num?)?.toInt();
    final dist = chosen?['distributor'] as Map<String, dynamic>?;
    final distributorId = (dist?['id'] as num?)?.toInt();

    final price = (chosen?['pharmacy_price'] as num?)?.toDouble() ??
        (product['unit_price'] as num?)?.toDouble() ??
        0.0;
    final stock = (chosen?['current_stock'] as num?)?.toInt() ?? 0;
    final mrp = (product['mrp'] as num?)?.toDouble() ??
        (product['mrp_price'] as num?)?.toDouble() ??
        (product['mrp_amount'] as num?)?.toDouble() ??
        (product['unit_price'] as num?)?.toDouble();
    final unitLabel = product['unit']?.toString() ??
        product['unit_label']?.toString() ??
        product['unit_type']?.toString() ??
        'piece';

    final categoryName = (product['category'] as Map<String, dynamic>?)?['name']?.toString();
    final manufacturerName = (product['manufacturer'] as Map<String, dynamic>?)?['name']?.toString();
    final category = categoryName ?? manufacturerName ?? 'General';

    final urls = _galleryUrlsFromCatalogRow(row);
    return ProductModel(
      id: product['id']?.toString() ?? '',
      name: product['name']?.toString() ?? '',
      code: product['sku']?.toString() ?? '',
      category: category,
      price: price,
      mrp: mrp,
      unitLabel: unitLabel,
      availableDistributorCount: distributors.length,
      stock: stock,
      imageUrl: urls.isNotEmpty ? urls.first : null,
      galleryUrls: urls,
      description: product['description']?.toString() ?? product['composition']?.toString(),
      isActive: product['is_active'] ?? true,
      catalogId: catalogId,
      distributorId: distributorId,
    );
  }

  /// All image URLs embedded in `GET /products/cataloged` one row (`product` + siblings).
  static List<String> _galleryUrlsFromCatalogRow(Map<String, dynamic> row) {
    final out = <String>[];
    final product = row['product'] as Map<String, dynamic>? ?? {};

    for (final u in _galleryUrlsFromProductMap(product)) {
      _appendResolvedUrl(out, u);
    }
    for (final key in ['images', 'product_images', 'media', 'photos', 'thumbnails', 'gallery']) {
      _appendUrlsFromImageList(out, row[key]);
    }
    final distributors = row['distributors'];
    if (distributors is List) {
      for (final d in distributors) {
        if (d is Map) {
          final m = Map<String, dynamic>.from(d);
          for (final k in ['image_url', 'thumbnail_url', 'photo_url', 'image']) {
            _appendResolvedUrl(out, m[k]?.toString());
          }
          _appendUrlsFromImageList(out, m['images']);
        }
      }
    }
    return out;
  }

  static void _appendResolvedUrl(List<String> out, String? raw) {
    final r = resolveImageUrl(raw?.trim());
    if (r == null || r.isEmpty) return;
    if (!out.contains(r)) out.add(r);
  }

  static void _appendUrlsFromImageList(List<String> out, dynamic list) {
    if (list is! List) return;
    for (final item in list) {
      if (item is String) {
        _appendResolvedUrl(out, item);
      } else if (item is Map) {
        _appendUrlsFromImageLikeMap(out, Map<String, dynamic>.from(item));
      }
    }
  }

  /// Maps `product` JSON inside a catalog row to URLs (strings + ProductImage-like objects).
  static List<String> _galleryUrlsFromProductMap(Map<String, dynamic> product) {
    final out = <String>[];
    for (final key in [
      'image_url',
      'imageUrl',
      'thumbnail_url',
      'thumbnail',
      'primary_image',
      'main_image',
      'cover_image',
      'photo_url',
      'photo',
      'image',
      'image_path',
      'image_info',
      'main_image_url',
    ]) {
      _appendResolvedUrl(out, product[key]?.toString());
    }
    for (final listKey in ['images', 'product_images', 'media', 'photos', 'gallery']) {
      _appendUrlsFromImageList(out, product[listKey]);
    }
    return out;
  }

  static void _appendUrlsFromImageLikeMap(List<String> out, Map<String, dynamic> m) {
    _appendResolvedUrl(out, m['thumbUrl']?.toString());
    _appendResolvedUrl(out, m['thumb_url']?.toString());
    _appendResolvedUrl(out, m['fullUrl']?.toString());
    _appendResolvedUrl(out, m['full_url']?.toString());
    _appendResolvedUrl(out, m['image_info']?.toString());
    _appendResolvedUrl(out, m['url']?.toString());
    _appendResolvedUrl(out, m['image_url']?.toString());
    _appendResolvedUrl(out, m['imageUrl']?.toString());
    _appendResolvedUrl(out, m['src']?.toString());
  }

  static Map<String, dynamic>? _pickDistributor(List<dynamic> distributors) {
    if (distributors.isEmpty) return null;
    final parsed = distributors.whereType<Map<String, dynamic>>().toList();
    parsed.sort((a, b) {
      final pa = (a['pharmacy_price'] as num?) ?? 0;
      final pb = (b['pharmacy_price'] as num?) ?? 0;
      return pa.compareTo(pb);
    });
    for (final d in parsed) {
      final stock = (d['current_stock'] as num?)?.toInt() ?? 0;
      if (stock > 0) return d;
    }
    return parsed.first;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'category': category,
        'price': price,
        'mrp': mrp,
        'unit_label': unitLabel,
        'available_distributor_count': availableDistributorCount,
        'stock': stock,
        'image_url': imageUrl,
        'description': description,
        'is_active': isActive,
        'catalog_id': catalogId,
        'distributor_id': distributorId,
      };

  factory ProductModel.fromEntity(ProductEntity entity) => ProductModel(
        id: entity.id,
        name: entity.name,
        code: entity.code,
        category: entity.category,
        price: entity.price,
        mrp: entity.mrp,
        unitLabel: entity.unitLabel,
        availableDistributorCount: entity.availableDistributorCount,
        stock: entity.stock,
        imageUrl: entity.imageUrl,
        galleryUrls: entity.galleryUrls,
        description: entity.description,
        isActive: entity.isActive,
        catalogId: entity.catalogId,
        distributorId: entity.distributorId,
      );

  static List<ProductModel> get sampleList => [
        const ProductModel(
          id: '1',
          name: 'Premium Widget A',
          code: 'PWA-001',
          category: 'Electronics',
          price: 1299.00,
          stock: 50,
          description: 'High quality premium widget for professionals',
        ),
        const ProductModel(
          id: '2',
          name: 'Industrial Bolt Set',
          code: 'IBS-002',
          category: 'Hardware',
          price: 450.00,
          stock: 200,
          description: 'Durable industrial grade bolt set',
        ),
        const ProductModel(
          id: '3',
          name: 'Safety Gloves Pro',
          code: 'SGP-003',
          category: 'Safety',
          price: 350.00,
          stock: 0,
          description: 'Professional safety gloves',
        ),
        const ProductModel(
          id: '4',
          name: 'Digital Multimeter',
          code: 'DM-004',
          category: 'Electronics',
          price: 2100.00,
          stock: 30,
          description: 'Advanced digital multimeter',
        ),
        const ProductModel(
          id: '5',
          name: 'Steel Pipe 2 inch',
          code: 'SP2-005',
          category: 'Pipes',
          price: 850.00,
          stock: 100,
          description: 'Heavy-duty steel pipe 2 inch diameter',
        ),
        const ProductModel(
          id: '6',
          name: 'Power Drill 18V',
          code: 'PD-006',
          category: 'Tools',
          price: 3500.00,
          stock: 25,
          description: 'Cordless power drill 18V battery',
        ),
      ];
}
