import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'product_image.dart';

/// Swipeable image carousel showing multiple product views (front, back, side).
/// Displays dots indicator and view labels (Front, Back, Side).
class ImageCarousel extends StatefulWidget {
  final Product product;
  final int initialIndex;

  const ImageCarousel({
    super.key,
    required this.product,
    this.initialIndex = 0,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final viewCount = widget.product.images?.length ?? 1;
    final hasMultipleViews = viewCount > 1;

    return Column(
      children: [
        // Image carousel
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemCount: viewCount,
                itemBuilder: (context, idx) {
                  if (widget.product.images == null || idx >= widget.product.images!.length) {
                    return ProductImage(product: widget.product, large: true, backdrop: Colors.transparent);
                  }
                  return Image.network(
                    '${const String.fromEnvironment('CDN_URL', defaultValue: 'https://www.bbassets.com/media/uploads/p/l/')}${widget.product.images![idx]}?tr=w-600,q-80',
                    fit: BoxFit.contain,
                    errorBuilder: (context, _, _) => ProductImage(
                      product: widget.product,
                      large: true,
                      backdrop: Colors.transparent,
                    ),
                  );
                },
              ),
              // View label
              if (hasMultipleViews)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getViewLabel(_currentIndex),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Dots indicator
        if (hasMultipleViews) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < viewCount; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentIndex == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == i ? c.primary : c.t3.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _getViewLabel(int index) {
    const labels = ['Front', 'Back', 'Side', 'View 4', 'View 5'];
    return index < labels.length ? labels[index] : 'View ${index + 1}';
  }
}
