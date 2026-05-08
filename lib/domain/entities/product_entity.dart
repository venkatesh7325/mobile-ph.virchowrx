import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String category;
  /// Pharmacy/dealer price (used for checkout).
  final double price;
  /// Optional MRP (if API provides it).
  final double? mrp;
  /// Unit label shown in UI (e.g. piece, strip, bottle).
  final String unitLabel;
  /// How many distributors currently list this product in the catalog row.
  final int availableDistributorCount;
  final int stock;
  final String? imageUrl;
  /// Resolved image URLs from API (e.g. `images[]`); first matches [imageUrl] when present.
  final List<String> galleryUrls;
  final String? description;
  final bool isActive;
  /// Pharmacy catalog line (for checkout); from `/products/cataloged`.
  final int? catalogId;
  final int? distributorId;
  /// From catalog distributor row when present (cart / checkout display).
  final String? distributorName;
  /// Minimum order quantity from distributor offer (cart qty validation).
  final int? minOrderQty;
  /// Maximum order quantity from distributor offer (cart qty validation).
  final int? maxOrderQty;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.price,
    this.mrp,
    this.unitLabel = 'piece',
    this.availableDistributorCount = 0,
    required this.stock,
    this.imageUrl,
    this.galleryUrls = const [],
    this.description,
    this.isActive = true,
    this.catalogId,
    this.distributorId,
    this.distributorName,
    this.minOrderQty,
    this.maxOrderQty,
  });

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props =>
      [
        id,
        name,
        code,
        category,
        price,
        mrp,
        unitLabel,
        availableDistributorCount,
        stock,
        imageUrl,
        galleryUrls,
        description,
        isActive,
        catalogId,
        distributorId,
        distributorName,
        minOrderQty,
        maxOrderQty,
      ];
}
