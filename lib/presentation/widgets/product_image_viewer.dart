import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'product_network_image.dart';

/// Full-screen product image gallery with pinch-to-zoom and swipe between images.
class ProductImageViewer {
  ProductImageViewer._();

  static Future<void> open(
    BuildContext context, {
    required List<String> urls,
    int initialIndex = 0,
    String? Function(int index)? fallbackForIndex,
  }) {
    if (urls.isEmpty) return Future.value();
    final start = initialIndex.clamp(0, urls.length - 1);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _ProductImageViewerPage(
              urls: urls,
              initialIndex: start,
              fallbackForIndex: fallbackForIndex,
            ),
          );
        },
      ),
    );
  }
}

class _ProductImageViewerPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final String? Function(int index)? fallbackForIndex;

  const _ProductImageViewerPage({
    required this.urls,
    required this.initialIndex,
    this.fallbackForIndex,
  });

  @override
  State<_ProductImageViewerPage> createState() => _ProductImageViewerPageState();
}

class _ProductImageViewerPageState extends State<_ProductImageViewerPage> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hasMultiple = widget.urls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final primary = widget.urls[i];
              final fb = widget.fallbackForIndex?.call(i);
              return Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  panEnabled: true,
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(48),
                  child: ProductNetworkImage(
                    imageUrl: primary,
                    fallbackImageUrl: fb,
                    width: size.width,
                    height: size.height,
                    fit: BoxFit.contain,
                    fallback: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _close,
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                  ),
                  const Spacer(),
                  if (hasMultiple)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_index + 1} / ${widget.urls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (hasMultiple)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom + 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) {
                  final active = _index == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
