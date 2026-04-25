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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'category': category,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
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
      );

  // Sample data for development/testing
  static List<ProductModel> get sampleList => [
        const ProductModel(
          id: '1', name: 'Premium Widget A', code: 'PWA-001', category: 'Electronics',
          price: 1299.00, stock: 50, description: 'High quality premium widget for professionals',
        ),
        const ProductModel(
          id: '2', name: 'Industrial Bolt Set', code: 'IBS-002', category: 'Hardware',
          price: 450.00, stock: 200, description: 'Durable industrial grade bolt set',
        ),
        const ProductModel(
          id: '3', name: 'Safety Gloves Pro', code: 'SGP-003', category: 'Safety',
          price: 350.00, stock: 0, description: 'Professional safety gloves',
        ),
        const ProductModel(
          id: '4', name: 'Digital Multimeter', code: 'DM-004', category: 'Electronics',
          price: 2100.00, stock: 30, description: 'Advanced digital multimeter',
        ),
        const ProductModel(
          id: '5', name: 'Steel Pipe 2 inch', code: 'SP2-005', category: 'Pipes',
          price: 850.00, stock: 100, description: 'Heavy-duty steel pipe 2 inch diameter',
        ),
        const ProductModel(
          id: '6', name: 'Power Drill 18V', code: 'PD-006', category: 'Tools',
          price: 3500.00, stock: 25, description: 'Cordless power drill 18V battery',
        ),
      ];
}
