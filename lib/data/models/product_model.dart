import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.code,
    required super.category,
    required super.price,
    required super.stock,
    super.imageUrl,
    super.description,
    super.isActive,
    super.composition,
    super.dosage,
    super.minOrderQty,
    super.maxOrderQty,
    super.catalogId,
  });

  // ── Parses the nested { "product": {}, "distributors": [] } structure ──
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final p = json['product'] as Map<String, dynamic>;
    final distributors = json['distributors'] as List<dynamic>;
    final dist = distributors.isNotEmpty
        ? distributors[0] as Map<String, dynamic>
        : <String, dynamic>{};

    final distributor = dist['distributor'] as Map<String, dynamic>? ?? {};

    return ProductModel(
      id: p['id'].toString(),
      name: p['name'] as String? ?? '',
      code: p['sku'] as String? ?? '',                          // sku → code
      category: p['dosage_type']?['name'] as String? ?? '',    // dosage_type → category
      price: (dist['pharmacy_price'] as num?)?.toDouble()
          ?? (p['unit_price'] as num?)?.toDouble()
          ?? 0.0,
      stock: (dist['current_stock'] as int?) ?? 0,
      description: p['description'] as String?,
      isActive: distributor['is_active'] as bool? ?? true,
      composition: p['composition'] as String? ?? '',
      dosage: p['dosage'] as String? ?? '',
      minOrderQty: (dist['minimum_order_quantity'] as int?) ?? 1,
      maxOrderQty: (dist['maximum_order_quantity'] as int?) ?? 9999,
      catalogId: (dist['catalog_id'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'category': category,
    'price': price,
    'stock': stock,
    'description': description,
    'is_active': isActive,
  };

  factory ProductModel.fromEntity(ProductEntity entity) => ProductModel(
    id: entity.id,
    name: entity.name,
    code: entity.code,
    category: entity.category,
    price: entity.price,
    stock: entity.stock,
    imageUrl: entity.imageUrl,
    description: entity.description,
    isActive: entity.isActive,
    composition: entity.composition,
    dosage: entity.dosage,
    minOrderQty: entity.minOrderQty,
    maxOrderQty: entity.maxOrderQty,
    catalogId: entity.catalogId,
  );
}