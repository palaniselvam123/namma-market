import 'package:flutter/material.dart';
import '../cart.dart';
import '../catalog.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/image_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import '../widgets/variant_selector.dart';

void openProductDetail(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .55),
    builder: (_) => ProductDetailSheet(product: product),
  );
}

class ProductDetailSheet extends StatefulWidget {
  final Product product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet>
    with SingleTickerProviderStateMixin {
  late Product _product = widget.product;
  Variant? _selectedVariant;
  final _scroll = ScrollController();

  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void initState() {
    super.initState();
    _selectedVariant = (_product.variants?.isNotEmpty ?? false)
        ? _product.variants!.first
        : null;
  }

  @override
  void dispose() {
    _entry.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Tapping a "similar product" swaps this sheet's contents rather than
  /// stacking another sheet on top — and replays the entrance so the new
  /// pack animates in too.
  void _swap(Product p) {
    setState(() {
      _product = p;
      _selectedVariant = p.variants != null && p.variants!.isNotEmpty
          ? p.variants!.first
          : null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _entry.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = _product;
    final similar = kProducts
        .where((x) => x.category == p.category && x.id != p.id)
        .take(6)
        .toList();
    final category = kCategories.firstWhere(
      (x) => x.key == p.category,
      orElse: () => kCategories.first,
    );

    return FractionallySizedBox(
      heightFactor: .93,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 9),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: c.t3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    controller: _scroll,
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _HeroArt(
                          product: p,
                          accent: category.gradient.last,
                          entry: _entry,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Rise(
                              entry: _entry,
                              start: .30,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: c.primaryBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.brand.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: c.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            _Rise(
                              entry: _entry,
                              start: .38,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                      letterSpacing: -.4,
                                      color: c.t0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.packLabel} · ${p.unit}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: c.t2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Rise(
                              entry: _entry,
                              start: .46,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '₹${p.price}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      color: c.t0,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                  if (p.mrp != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${p.mrp}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: c.t2,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: c.greenBg,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        '${p.discountPct}% off',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: c.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Inclusive of all taxes',
                              style: TextStyle(fontSize: 11, color: c.t2),
                            ),
                          ],
                        ),
                      ),
                      if (widget.product.variants != null &&
                          widget.product.variants!.isNotEmpty)
                        _Rise(
                          entry: _entry,
                          start: .50,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pack Size',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: c.t0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                VariantSelector(
                                  variants: widget.product.variants!,
                                  initialVariant: _selectedVariant,
                                  onVariantSelected: (variant) {
                                    setState(() => _selectedVariant = variant);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      _Rise(
                        entry: _entry,
                        start: .54,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 11),
                          decoration: BoxDecoration(
                            color: c.greenBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('🛵', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delivered in 10 minutes',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: c.green,
                                      ),
                                    ),
                                    Text(
                                      'Free delivery on orders above ₹$kFreeDeliveryThreshold',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: c.green.withValues(alpha: .75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: c.t0,
                              ),
                            ),
                            const SizedBox(height: 9),
                            _DetailRow('Brand', p.brand),
                            _DetailRow('Pack size', p.unit),
                            _DetailRow('Variant', p.packLabel),
                            _DetailRow('Category', category.label),
                            _DetailRow('Country of origin', 'India'),
                            _DetailRow('Seller', 'Namma MahaRaja Super Market',
                                last: true),
                          ],
                        ),
                      ),
                      if (similar.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 9),
                          child: Text(
                            'Similar products',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: c.t0,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: kCardHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: similar.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 10),
                            itemBuilder: (_, i) => SizedBox(
                              width: kCardWidth,
                              child: ProductCard(
                                product: similar[i],
                                onTap: () => _swap(similar[i]),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                  Positioned(
                    top: 6,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.surface.withValues(alpha: .85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .10),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(Icons.close, size: 17, color: c.t1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(product: p, selectedVariant: _selectedVariant),
          ],
        ),
      ),
    );
  }
}

/// Colourful, category-tinted stage for the pack shot: a diagonal wash, a
/// spotlight behind the product, drifting accent bubbles, and the pack
/// itself easing up into place.
class _HeroArt extends StatelessWidget {
  final Product product;
  final Color accent;
  final Animation<double> entry;

  const _HeroArt({
    required this.product,
    required this.accent,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dark = Theme.of(context).brightness == Brightness.dark;
    Color wash(double a) => Color.alphaBlend(accent.withValues(alpha: a), c.surface);

    final lift = CurvedAnimation(parent: entry, curve: Curves.easeOutCubic);
    final float = CurvedAnimation(
      parent: entry,
      curve: const Interval(0, .75, curve: Curves.easeOutBack),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 258,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [wash(.08), wash(.24), wash(.40)],
                ),
              ),
            ),
            // Bubbles drift in from the corners as the sheet opens.
            _DriftBubble(
              animation: lift,
              alignment: const Alignment(1.25, -1.15),
              travel: const Offset(-14, 12),
              size: 132,
              color: accent.withValues(alpha: dark ? .22 : .16),
            ),
            _DriftBubble(
              animation: lift,
              alignment: const Alignment(-1.2, 1.25),
              travel: const Offset(12, -14),
              size: 96,
              color: accent.withValues(alpha: dark ? .18 : .13),
            ),
            // Spotlight pool behind the pack.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, .05),
                  radius: .78,
                  colors: [
                    Colors.white.withValues(alpha: dark ? .12 : .62),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: lift,
              child: AnimatedBuilder(
                animation: float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, 22 * (1 - float.value)),
                  child: Transform.scale(
                    scale: .90 + .10 * float.value,
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ImageCarousel(
                    product: product,
                  ),
                ),
              ),
            ),
            if (product.flag != Flag.none)
              Positioned(
                top: 12,
                left: 12,
                child: FadeTransition(
                  opacity: lift,
                  child: FlagBadge(product: product),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DriftBubble extends StatelessWidget {
  final Animation<double> animation;
  final Alignment alignment;
  final Offset travel;
  final double size;
  final Color color;

  const _DriftBubble({
    required this.animation,
    required this.alignment,
    required this.travel,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Align(
        alignment: alignment,
        child: Transform.translate(
          offset: travel * animation.value,
          child: child,
        ),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Fades and lifts its child on a slice of the entrance timeline, so the
/// copy arrives in sequence rather than all at once.
class _Rise extends StatelessWidget {
  final Animation<double> entry;
  final double start;
  final Widget child;

  const _Rise({required this.entry, required this.start, required this.child});

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(
      parent: entry,
      curve: Interval(start, (start + .38).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (context, child) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - a.value)),
          child: child,
        ),
      ),
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _DetailRow(this.label, this.value, {this.last = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12.5, color: c.t1)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: c.t0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Product product;
  final Variant? selectedVariant;

  const _BottomBar({required this.product, this.selectedVariant});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final displayPrice = selectedVariant?.price ?? product.price;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final q = cart.qty(product.id);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    q == 0 ? 'PRICE' : '$q × ₹$displayPrice',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                      color: c.t2,
                    ),
                  ),
                  Text(
                    '₹${q == 0 ? displayPrice : displayPrice * q}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: c.t0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: q == 0
                    ? GestureDetector(
                        onTap: () => cart.add(product.id),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA500),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFA500).withValues(alpha: .22),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Add to cart',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: c.primaryBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BigStep(
                              icon: Icons.remove,
                              onTap: () => cart.remove(product.id),
                            ),
                            Text(
                              '$q',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: c.t0,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                            _BigStep(
                              icon: Icons.add,
                              onTap: () => cart.add(product.id),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BigStep extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BigStep({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.t3.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.borderLight),
        ),
        child: Icon(icon, size: 18, color: c.t1),
      ),
    );
  }
}
