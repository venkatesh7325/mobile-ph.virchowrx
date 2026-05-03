import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  // ── New fields from API ──
  final String composition;
  final String dosage;
  final int minOrderQty;
  final int maxOrderQty;
  final int catalogId;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    this.isActive = true,
    // ── New ──
    this.composition = '',
    this.dosage = '',
    this.minOrderQty = 1,
    this.maxOrderQty = 9999,
    this.catalogId = 0,
  });

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [
    id, name, code, category, price, stock,
    imageUrl, description, isActive,
    composition, dosage, minOrderQty, maxOrderQty, catalogId,
  ];
}