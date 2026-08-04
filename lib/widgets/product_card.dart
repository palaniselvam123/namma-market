import 'package:flutter/material.dart';
import '../cart.dart';
import '../models.dart';
import '../screens/product_detail.dart';
import '../theme.dart';
import 'product_image.dart';

const double kCardImageHeight = 140;
const double kCardHeight = 216;
const double kCardWidth = 152;

class ProductCard extends StatelessWidget {
  final Product product;

  /// Overridden by the detail sheet so "similar products" swap in place
  /// instead of stacking another sheet.
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap ?? () => openProductDetail(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kCardImageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product: product),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Text(
                      product.brand.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .6,
                        color: product.image != null
                            ? c.t2
                            : Colors.white.withValues(alpha: .8),
                      ),
                    ),
                  ),
                  if (product.flag != Flag.none)
                    Positioned(top: 6, right: 6, child: FlagBadge(product: product)),
                  Positioned(bottom: 8, left: 8, child: UnitChip(product: product)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 31,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: c.t0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: PriceLabel(product: product)),
                        AddControl(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceLabel extends StatelessWidget {
  final Product product;
  final double size;

  const PriceLabel({super.key, required this.product, this.size = 15});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '₹${product.price}',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: c.t0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (product.mrp != null) ...[
          const SizedBox(width: 4),
          Text(
            '₹${product.mrp}',
            style: TextStyle(
              fontSize: size * .67,
              color: c.t2,
              decoration: TextDecoration.lineThrough,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

class FlagBadge extends StatelessWidget {
  final Product product;

  const FlagBadge({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (label, color) = switch (product.flag) {
      Flag.bestseller => ('Bestseller', c.green),
      Flag.sale => ('${product.discountPct}% OFF', c.primary),
      Flag.isNew => ('New', c.gold),
      Flag.none => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class UnitChip extends StatelessWidget {
  final Product product;

  const UnitChip({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final onPhoto = product.image != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: onPhoto
            ? Colors.white.withValues(alpha: .88)
            : Colors.black.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        product.unit,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: onPhoto ? context.c.t1 : Colors.white.withValues(alpha: .9),
        ),
      ),
    );
  }
}

/// "+" until the item is in the cart, then a compact stepper.
class AddControl extends StatelessWidget {
  final Product product;

  const AddControl({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final q = cart.qty(product.id);
        if (q == 0) {
          return GestureDetector(
            onTap: () => cart.add(product.id),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4CC),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFFFB84D), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB84D).withValues(alpha: .2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 18, color: Color(0xFFF97316)),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: c.primaryBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(icon: Icons.remove, onTap: () => cart.remove(product.id)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '$q',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c.t0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _StepButton(icon: Icons.add, onTap: () => cart.add(product.id)),
            ],
          ),
        );
      },
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4CC),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFFFB84D), width: 1),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFFF97316)),
      ),
    );
  }
}
