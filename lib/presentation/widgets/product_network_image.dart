import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Loads a product image from the network with loading and error fallbacks.
///
/// When [fallbackImageUrl] is set and differs from [imageUrl], a failed load on
/// the primary URL triggers one retry with the fallback URL. If both fail, or
/// there is no URL, [fallback] is shown.
class ProductNetworkImage extends StatefulWidget {
  final String? imageUrl;
  /// Tried once after primary fails (e.g. full-size vs missing thumb blob).
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
  /// Current network URL, or null to show [widget.fallback] after load failure.
  String? _networkUrl;
  bool _triedAlternateNetworkUrl = false;

  @override
  void initState() {
    super.initState();
    _networkUrl = _initialNetworkUrl();
    _triedAlternateNetworkUrl = false;
  }

  @override
  void didUpdateWidget(ProductNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackImageUrl != widget.fallbackImageUrl) {
      _networkUrl = _initialNetworkUrl();
      _triedAlternateNetworkUrl = false;
    }
  }

  String? _initialNetworkUrl() {
    final primary = widget.imageUrl?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final fb = widget.fallbackImageUrl?.trim();
    if (fb != null && fb.isNotEmpty) return fb;
    return null;
  }

  String? _distinctFallbackUrl() {
    final primary = widget.imageUrl?.trim();
    final fb = widget.fallbackImageUrl?.trim();
    if (fb == null || fb.isEmpty || fb == primary) return null;
    return fb;
  }

  void _onImageLoadFailed() {
    final primary = widget.imageUrl?.trim();
    final fb = _distinctFallbackUrl();
    if (!_triedAlternateNetworkUrl &&
        fb != null &&
        primary != null &&
        primary.isNotEmpty &&
        _networkUrl == primary) {
      _triedAlternateNetworkUrl = true;
      setState(() => _networkUrl = fb);
      return;
    }
    setState(() => _networkUrl = null);
  }

  @override
  Widget build(BuildContext context) {
    final url = _networkUrl?.trim();
    if (url == null || url.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.fallback,
      );
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _onImageLoadFailed();
        });
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
