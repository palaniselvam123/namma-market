import 'package:flutter/material.dart';
import '../catalog.dart';
import '../models.dart';
import '../theme.dart';

/// Renders the real product photograph when one exists, and degrades to a
/// brand-styled packaging card if the product has no photo or the CDN fails.
class ProductImage extends StatelessWidget {
  final Product product;
  final bool large;

  /// Pass a transparent colour to let a decorative backdrop show through.
  final Color? backdrop;

  const ProductImage({
    super.key,
    required this.product,
    this.large = false,
    this.backdrop,
  });

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl(large ? 600 : 400);
    if (url == null) return _Packaging(product: product, large: large);

    // The photo frame is applied inside loadingBuilder so that errorBuilder
    // inherits the full parent constraints — otherwise the fallback card
    // collapses to the failed image's intrinsic size.
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, _, _) =>
          _Packaging(product: product, large: large),
      loadingBuilder: (context, child, progress) => Container(
        color: backdrop ?? const Color(0xFFF8F6F2),
        padding: EdgeInsets.all(large ? 22 : 14),
        alignment: Alignment.center,
        child: progress == null
            ? child
            : SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.c.t3,
                ),
              ),
      ),
    );
  }
}

class _Packaging extends StatelessWidget {
  final Product product;
  final bool large;

  const _Packaging({required this.product, required this.large});

  @override
  Widget build(BuildContext context) {
    final s = styleFor(product.brand);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: s.gradient,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Sheen, so the flat gradient reads as a printed pack.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: .18),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .08),
                ],
                stops: const [0, .38, 1],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Cart thumbnails are far too small for the full lockup, so
              // they show the product mark alone.
              if (constraints.maxHeight < 100) {
                return Center(
                  child: Text(
                    product.emoji,
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * .42).clamp(14, 30),
                    ),
                  ),
                );
              }
              final brandSize =
                  large ? 22.0 : (product.brand.length > 11 ? 11.0 : 13.5);
              return Padding(
                padding: EdgeInsets.all(large ? 20 : 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: brandSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        height: 1.1,
                        color: s.brandColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        width: large ? 62 : 44,
                        height: 2,
                        decoration: BoxDecoration(
                          color: s.brandColor.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        product.packLabel,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: large ? 14 : 10,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: s.labelColor,
                        ),
                      ),
                    ),
                    SizedBox(height: large ? 12 : 6),
                    Text(
                      product.emoji,
                      style: TextStyle(fontSize: large ? 54 : 30),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
