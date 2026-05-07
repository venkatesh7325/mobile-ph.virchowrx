import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Loads a product image from the network with loading and error fallbacks.
///
/// When [fallbackImageUrl] is set and the primary URL fails with **404** (common
/// when a `-thumbs/` blob is missing but the full image exists), one retry uses
/// the fallback URL.
class ProductNetworkImage extends StatefulWidget {
  final String? imageUrl;
  /// Tried after primary when primary returns 404 (e.g. full-size blob vs missing thumb).
  final String? fallbackImageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget fallback;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.fallbackImageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    required this.fallback,
  });

  @override
  State<ProductNetworkImage> createState() => _ProductNetworkImageState();
}

class _ProductNetworkImageState extends State<ProductNetworkImage> {
  late String? _activeUrl;

  @override
  void initState() {
    super.initState();
    _activeUrl = _pickInitialUrl();
  }

  @override
  void didUpdateWidget(ProductNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackImageUrl != widget.fallbackImageUrl) {
      _activeUrl = _pickInitialUrl();
    }
  }

  String? _pickInitialUrl() {
    final primary = widget.imageUrl?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final fb = widget.fallbackImageUrl?.trim();
    if (fb != null && fb.isNotEmpty) return fb;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _activeUrl;
    if (url == null || url.isEmpty) {
      // If no URL is available at all, render nothing (no placeholder).
      return SizedBox(width: widget.width, height: widget.height);
    }

    Widget image = Image.network(
      url,
      key: ValueKey(url),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      headers: const {
        'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        final value = (total != null && total > 0)
            ? progress.cumulativeBytesLoaded / total
            : null;
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: value,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          debugPrint(
              '[ProductNetworkImage] failed to load: ${url.length > 120 ? '${url.substring(0, 120)}…' : url}');
          debugPrint('[ProductNetworkImage] error: $error');
        }
        // If the request fails (commonly 404 on missing blobs), render nothing
        // and do not attempt fallback URLs or placeholders.
        return SizedBox(width: widget.width, height: widget.height);
      },
    );

    return _clip(image);
  }

  Widget _clip(Widget child) {
    final r = widget.borderRadius;
    if (r != null) {
      return ClipRRect(borderRadius: r, child: child);
    }
    return child;
  }
}
