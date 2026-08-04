import 'package:flutter/material.dart';
import '../app_state.dart';
import '../catalog.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  List<Product> _visible() {
    if (appState.query.isNotEmpty) {
      final q = appState.query.toLowerCase();
      return kProducts
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.packLabel.toLowerCase().contains(q) ||
              p.category.contains(q))
          .toList();
    }
    return productsIn(appState.filter);
  }

  String _title() {
    if (appState.query.isNotEmpty) return appState.query;
    if (appState.filter == 'all') return 'All Products';
    return kCategories.firstWhere((c) => c.key == appState.filter).label;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final items = _visible();
        return Container(
          color: c.bg,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(bottom: BorderSide(color: c.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _title(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.5,
                              color: c.t0,
                            ),
                          ),
                        ),
                        Text(
                          '${items.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.t2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kCategories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 7),
                        itemBuilder: (_, i) {
                          final cat = kCategories[i];
                          final on = appState.query.isEmpty &&
                              appState.filter == cat.key;
                          return GestureDetector(
                            onTap: () => appState.setFilter(cat.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: on ? c.primary : c.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: on ? c.primary : c.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${cat.emoji} ${cat.label}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: on ? Colors.white : c.t1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? _EmptyResults(query: appState.query)
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        // Max-extent rather than a fixed 2 columns, so cards
                        // stay phone-sized on a tablet or a wide browser.
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: .78,
                        ),
                        itemBuilder: (_, i) => ProductCard(product: items[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;

  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: c.t0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing matches "$query"',
            style: TextStyle(fontSize: 12.5, color: c.t2),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => appState.setFilter('all'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Browse all products',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
