import '../../domain/entities/product_image_urls_result.dart';
import 'resolve_image_url.dart';

/// Parses `GET /product-images/product/:id` (and similar) JSON into absolute image URLs.
List<String> parseProductImageUrlsFromJson(dynamic data) {
  final out = <String>[];
  void add(String? raw) {
    final u = resolveImageUrl(raw);
    if (u != null && u.isNotEmpty && !out.contains(u)) out.add(u);
  }

  /// Prefer larger assets for swipe galleries; thumbnails are exposed via [parseProductImageUrlsResult].
  void addFromMap(Map<String, dynamic> m) {
    add(m['fullUrl']?.toString());
    add(m['full_url']?.toString());
    add(m['image_info']?.toString());
    add(m['url']?.toString());
    add(m['imageUrl']?.toString());
    add(m['image_url']?.toString());
    add(m['path']?.toString());
    add(m['file_url']?.toString());
    add(m['src']?.toString());
    add(m['thumbUrl']?.toString());
    add(m['thumb_url']?.toString());
  }

  void walkList(List<dynamic> list) {
    for (final e in list) {
      if (e is String) {
        add(e);
      } else if (e is Map) {
        addFromMap(Map<String, dynamic>.from(e));
      }
    }
  }

  if (data is List) {
    walkList(data);
    return out;
  }

  if (data is Map<String, dynamic>) {
    for (final key in ['images', 'data', 'urls', 'items', 'product_images', 'results', 'files']) {
      final v = data[key];
      if (v is List) walkList(v);
    }
    final nested = data['product'];
    if (nested is Map<String, dynamic>) {
      for (final u in parseProductImageUrlsFromJson(nested)) {
        add(u);
      }
    }
    addFromMap(data);
    return out;
  }

  return out;
}

/// First resolved `thumbUrl` / `thumb_url` anywhere in the JSON tree (for catalog list cells).
String? firstResolvedThumbUrl(dynamic data) {
  if (data == null) return null;
  if (data is Map<String, dynamic>) {
    for (final k in ['thumbUrl', 'thumb_url']) {
      final u = resolveImageUrl(data[k]?.toString().trim());
      if (u != null && u.isNotEmpty) return u;
    }
    for (final v in data.values) {
      final nested = firstResolvedThumbUrl(v);
      if (nested != null) return nested;
    }
  } else if (data is List) {
    for (final e in data) {
      final nested = firstResolvedThumbUrl(e);
      if (nested != null) return nested;
    }
  }
  return null;
}

/// Full gallery list plus [ProductImageUrlsResult.thumbnailUrl] for product list rows.
ProductImageUrlsResult parseProductImageUrlsResult(dynamic data) {
  final urls = parseProductImageUrlsFromJson(data);
  final thumb = firstResolvedThumbUrl(data);
  return ProductImageUrlsResult(
    urls: urls,
    thumbnailUrl: thumb ?? (urls.isNotEmpty ? urls.first : null),
  );
}
