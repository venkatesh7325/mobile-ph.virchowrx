/// Result of `GET /product-images/product/:id` — gallery URLs plus optional list thumbnail.
class ProductImageUrlsResult {
  final List<String> urls;
  /// Prefer for catalog / list rows when the API provides `thumbUrl`.
  final String? thumbnailUrl;

  const ProductImageUrlsResult({
    required this.urls,
    this.thumbnailUrl,
  });
}
