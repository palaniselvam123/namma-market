import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../catalog.dart';
import '../models.dart';
import '../address_store.dart';
import '../models/order.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/category_tile.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Header(),
          const _DeliveryBar(),
          const _BannerCarousel(),
          const _Ticker(),
          const _SectionHeader('Shop by category'),
          const _CategoryGrid(),
          const _SectionHeader("Today's offers"),
          const _PosterRow(),
          const _FlashDeals(),
          Container(height: 8, color: c.surfaceAlt),
          const _SectionHeader('Shop by brand'),
          const _BrandChips(),
          for (final s in kSections) ...[
            Container(
              height: 8,
              color: c.surfaceAlt,
              margin: const EdgeInsets.only(top: 8),
            ),
            _SectionHeader(
              s.title,
              action: 'See all',
              onAction: () => appState.showCategory(s.category),
            ),
            _ProductRow(products: productsIn(s.category).take(8).toList()),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kNavyDeep, kNavy, kNavyLight],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const BrandLockup(color: kCream, subColor: kGoldLeaf),
              const Spacer(),
              const _HeaderButton(Icons.notifications_none),
              const SizedBox(width: 6),
              const _HeaderButton(Icons.favorite_border),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.location_on, size: 15, color: kGoldLeaf),
              const SizedBox(width: 5),
              Text(
                'Deliver to ',
                style: TextStyle(
                  fontSize: 12,
                  color: kCream.withValues(alpha: .65),
                ),
              ),
              Flexible(
                child: ListenableBuilder(
                  listenable: addressStore,
                  builder: (context, _) {
                    final address = addressStore.selected;
                    return Text(
                      address == null
                          ? '$kStoreArea, Chennai $kStorePincode'
                          : '${address.label} · ${address.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: kCream,
                      ),
                    );
                  },
                ),
              ),
              Text(
                ' ▾',
                style: TextStyle(
                  fontSize: 12,
                  color: kCream.withValues(alpha: .65),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) appState.search(v.trim());
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A0F08),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
                icon: Icon(Icons.search, color: Color(0xFF9A8272), size: 20),
                hintText: "Search 'Aashirvaad Atta' or 'Amul'",
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9A8272)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;

  const _HeaderButton(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _DeliveryBar extends StatelessWidget {
  const _DeliveryBar();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      color: c.greenBg,
      child: Text(
        '⚡  Free delivery on orders above ₹299',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.green,
        ),
      ),
    );
  }
}

class _Banner {
  final String tag, title, sub, category;
  final int productId;
  final List<Color> colors;
  final Color ctaColor;

  const _Banner(this.tag, this.title, this.sub, this.productId, this.category,
      this.colors, this.ctaColor);
}

const _banners = [
  _Banner('Royal pick', 'Aashirvaad Atta\n₹275 / 5 kg',
      "India's No. 1 whole wheat atta", 1, 'grains',
      [Color(0xFF0A1626), Color(0xFF1D3A5F), Color(0xFF2E5C8A)],
      Color(0xFF12304F)),
  _Banner('Daily fresh', 'Aavin & Amul\nDairy Essentials',
      'Farm-fresh milk, curd & paneer', 25, 'dairy',
      [Color(0xFF7A0F2B), Color(0xFFC42348), Color(0xFFE8546F)],
      Color(0xFF8A1030)),
  _Banner('Weekend treat', "Cadbury & Lay's\nSnack Combos",
      'Flat 15% off on party packs', 44, 'snacks',
      [Color(0xFF2E0B52), Color(0xFF6B25B0), Color(0xFF9B4DE0)],
      Color(0xFF43148A)),
  _Banner('Spice box', 'Aachi & Sakthi\nChennai Masalas',
      'Ground fresh for every kitchen', 17, 'spices',
      [Color(0xFF7A2A05), Color(0xFFC85410), Color(0xFFED8A2B)],
      Color(0xFF8A3208)),
];

/// A poster card — vivid gradient, an offer line, and the hero pack.
class _Poster {
  final String kicker, headline, cta, category;
  final int productId;
  final List<Color> colors;

  const _Poster(this.kicker, this.headline, this.cta, this.productId,
      this.category, this.colors);
}

const _posters = [
  _Poster('ICE CREAM CARNIVAL', '20% OFF', 'Grab now', 29, 'dairy',
      [Color(0xFF0E5A6B), Color(0xFF17A2B8), Color(0xFF4FD3C4)]),
  _Poster('SNACK FIESTA', 'Buy 2\nGet 1', 'Shop snacks', 40, 'snacks',
      [Color(0xFFB8320A), Color(0xFFEF6C12), Color(0xFFFFB03A)]),
  _Poster('POOJA CORNER', 'Festive\nEssentials', 'Explore', 81, 'pooja',
      [Color(0xFF8A5A00), Color(0xFFCB8F12), Color(0xFFF2C75C)]),
  _Poster('HOME CARE', 'Upto\n30% OFF', 'Stock up', 75, 'household',
      [Color(0xFF123C7A), Color(0xFF2563C9), Color(0xFF5D9BEE)]),
];

class _PosterRow extends StatelessWidget {
  const _PosterRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _posters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = _posters[i];
          final hero = productById(p.productId);
          return GestureDetector(
            onTap: () => appState.showCategory(p.category),
            child: Container(
              width: 232,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: p.colors,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: p.colors[1].withValues(alpha: .32),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    right: -26,
                    top: -26,
                    child: _Bubble(size: 104, color: Colors.white.withValues(alpha: .13)),
                  ),
                  Positioned(
                    left: -18,
                    bottom: -34,
                    child: _Bubble(size: 82, color: Colors.white.withValues(alpha: .09)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 14, 8, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.kicker,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                  color: Colors.white.withValues(alpha: .82),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.headline,
                                style: const TextStyle(
                                  fontSize: 23,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.6,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.cta,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: p.colors.first,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 78,
                          height: 104,
                          child: hero.imageUrl(240) == null
                              ? const SizedBox.shrink()
                              : Image.network(
                                  hero.imageUrl(240)!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The pack on a banner, lifted off the gradient by a soft halo.
class _BannerArt extends StatelessWidget {
  final Product product;

  const _BannerArt({required this.product});

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl(320);
    return SizedBox(
      width: 112,
      height: 122,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: .28),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          if (url != null)
            Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  Text(product.emoji, style: const TextStyle(fontSize: 60)),
            )
          else
            Text(product.emoji, style: const TextStyle(fontSize: 60)),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;

  const _Bubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % _banners.length,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: b.colors,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              b.tag.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b.title,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            b.sub,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: .85),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => appState.showCategory(b.category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 9),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Shop Now →',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: b.ctaColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _BannerArt(product: productById(b.productId)),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: i == _index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? Colors.white
                          : Colors.white.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _tickerItems = [
  '🌾 Aashirvaad 5kg ₹275',
  '🧈 Amul Butter ₹58',
  '☕ Nescafe ₹320',
  '🌻 Gold Winner ₹140',
  '🍜 Maggi 4-Pack ₹56',
  '🍫 Cadbury ₹85',
  '🍵 Tata Tea ₹275',
  '🥛 Aavin Milk ₹27',
  '🧼 Dove Soap ₹55',
  '🍪 Parle-G ₹30',
];
const double _tickerItemWidth = 168;

class _Ticker extends StatefulWidget {
  const _Ticker();

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runWidth = _tickerItems.length * _tickerItemWidth;
    return Container(
      height: 34,
      color: context.c.green,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: context.c.green),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(-_controller.value * runWidth, 0),
          child: child,
        ),
        child: Row(
          children: [
            for (var pass = 0; pass < 2; pass++)
              for (final item in _tickerItems)
                SizedBox(
                  width: _tickerItemWidth,
                  child: Center(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -.3,
              color: c.t0,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final cats = kCategories.skip(1).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: cats.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 96,
          mainAxisSpacing: 12,
          crossAxisSpacing: 9,
          childAspectRatio: .80,
        ),
        itemBuilder: (_, i) => CategoryTile(category: cats[i]),
      ),
    );
  }
}

class _FlashDeals extends StatefulWidget {
  const _FlashDeals();

  @override
  State<_FlashDeals> createState() => _FlashDealsState();
}

class _FlashDealsState extends State<_FlashDeals> {
  static const _start = 9930;
  int _seconds = _start;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds = _seconds <= 0 ? _start : _seconds - 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _hh => (_seconds ~/ 3600).toString().padLeft(2, '0');
  String get _mm => ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  String get _ss => (_seconds % 60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final deals =
        kProducts.where((p) => p.flag != Flag.none && p.flag != Flag.isNew).take(8).toList();
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFC8390A), Color(0xFFE04A18)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡  Flash Deals',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _TimeBox(_hh),
                  const _Colon(),
                  _TimeBox(_mm),
                  const _Colon(),
                  _TimeBox(_ss),
                ],
              ),
            ],
          ),
        ),
        _ProductRow(products: deals),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;

  const _TimeBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          ':',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      );
}

class _BrandChips extends StatelessWidget {
  const _BrandChips();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kBrands.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => appState.showBrand(kBrands[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border, width: 1.5),
            ),
            child: Text(
              kBrands[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.t1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final List<Product> products;

  const _ProductRow({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: kCardWidth,
          child: ProductCard(product: products[i]),
        ),
      ),
    );
  }
}
