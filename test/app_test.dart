import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_market/app_state.dart';
import 'package:namma_market/cart.dart';
import 'package:namma_market/catalog.dart';
import 'package:namma_market/screens/cart_screen.dart';
import 'package:namma_market/screens/product_detail.dart';
import 'package:namma_market/screens/shop.dart';
import 'package:namma_market/theme.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(body: child),
    );

void main() {
  setUp(() {
    cart.clear();
    appState.filter = 'all';
    appState.query = '';
    appState.tab = 0;
  });

  /// Lay tests out on an iPhone-sized surface rather than the 800x600 default.
  Future<void> phone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('CartModel', () {
    test('totals, delivery threshold and savings', () {
      cart.add(1); // Aashirvaad Atta ₹275
      expect(cart.count, 1);
      expect(cart.subtotal, 275);
      // Below ₹299 still pays delivery.
      expect(cart.deliveryFee, kDeliveryFee);
      expect(cart.total, 275 + kDeliveryFee);
      expect(cart.toFreeDelivery, 24);

      cart.add(43); // Parle-G ₹30 -> crosses the free-delivery threshold
      expect(cart.subtotal, 305);
      expect(cart.deliveryFee, 0);
      expect(cart.total, 305);
    });

    test('savings only count discounted items', () {
      cart.add(29); // Arun Vanilla Cone ₹60, MRP ₹75
      cart.add(29);
      expect(cart.savings, 30);
      cart.add(1); // no MRP
      expect(cart.savings, 30);
    });

    test('remove decrements then drops the line', () {
      cart.add(1);
      cart.add(1);
      cart.remove(1);
      expect(cart.qty(1), 1);
      cart.remove(1);
      expect(cart.qty(1), 0);
      expect(cart.isEmpty, isTrue);
    });
  });

  group('Catalog integrity', () {
    test('ids are unique and every product has a known category', () {
      final ids = kProducts.map((p) => p.id).toSet();
      expect(ids.length, kProducts.length);
      final keys = kCategories.map((c) => c.key).toSet();
      for (final p in kProducts) {
        expect(keys.contains(p.category), isTrue, reason: '${p.name} -> ${p.category}');
      }
    });

    test('every brand without a photo has a packaging style', () {
      for (final p in kProducts.where((p) => p.image == null)) {
        expect(kBrandStyles.containsKey(p.brand), isTrue,
            reason: 'missing BrandStyle for ${p.brand}');
      }
    });

    test('every shoppable category has a hero product with a photo', () {
      for (final cat in kCategories.where((c) => c.key != 'all')) {
        expect(cat.heroId, isNotNull, reason: 'no heroId for ${cat.key}');
        final hero = productById(cat.heroId!);
        expect(hero.category, cat.key, reason: '${cat.key} hero is off-category');
        expect(hero.image, isNotNull, reason: '${cat.key} hero has no photo');
      }
    });

    test('nothing still carries the retired store name', () {
      for (final p in kProducts) {
        expect(p.brand.contains('Grace'), isFalse, reason: p.name);
        expect(p.name.contains('Grace'), isFalse, reason: p.name);
      }
      expect(kBrandStyles.keys.any((k) => k.contains('Grace')), isFalse);
      expect(kBrands.any((b) => b.contains('Grace')), isFalse);
    });

    test('discounted products carry an MRP above price', () {
      for (final p in kProducts.where((p) => p.mrp != null)) {
        expect(p.mrp! > p.price, isTrue, reason: p.name);
        expect(p.discountPct, greaterThan(0));
      }
    });
  });

  group('ShopScreen', () {
    testWidgets('lists every product and filters by category', (tester) async {
      await phone(tester);
      await tester.pumpWidget(wrap(const ShopScreen()));
      expect(find.text('All Products'), findsOneWidget);
      expect(find.text('${kProducts.length} items'), findsOneWidget);

      appState.setFilter('oils');
      await tester.pumpAndSettle();

      final oils = productsIn('oils').length;
      expect(find.text('Oils'), findsWidgets);
      expect(find.text('$oils items'), findsOneWidget);
    });

    testWidgets('search matches brand names', (tester) async {
      await phone(tester);
      await tester.pumpWidget(wrap(const ShopScreen()));
      appState.search('amul');
      await tester.pumpAndSettle();

      final expected = kProducts.where((p) =>
          p.name.toLowerCase().contains('amul') ||
          p.brand.toLowerCase().contains('amul'));
      expect(find.text('${expected.length} items'), findsOneWidget);
      expect(find.text('Amul Butter'), findsOneWidget);
    });

    testWidgets('empty search shows the fallback state', (tester) async {
      await phone(tester);
      await tester.pumpWidget(wrap(const ShopScreen()));
      appState.search('zzzznothing');
      await tester.pumpAndSettle();
      expect(find.text('No products found'), findsOneWidget);
    });

    testWidgets('tapping a product card opens the detail sheet', (tester) async {
      await phone(tester);
      await tester.pumpWidget(wrap(const ShopScreen()));
      appState.setFilter('oils');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Idhayam Gingelly Oil').first);
      await tester.pumpAndSettle();

      expect(find.text('Product details'), findsOneWidget);
      expect(find.text('Country of origin'), findsOneWidget);
      expect(find.text('Namma MahaRaja Super Market'), findsOneWidget);
      expect(find.text('Add to cart'), findsOneWidget);
    });
  });

  group('ProductDetailSheet', () {
    testWidgets('shows pricing and adds to cart', (tester) async {
      await phone(tester);
      final p = productById(29); // Arun Vanilla Cone, ₹60 from ₹75
      await tester.pumpWidget(wrap(ProductDetailSheet(product: p)));
      await tester.pumpAndSettle();

      expect(find.text('Arun Vanilla Cone'), findsOneWidget);
      expect(find.text('₹60'), findsWidgets);
      expect(find.text('₹75'), findsOneWidget);
      expect(find.text('20% off'), findsOneWidget);

      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      expect(cart.qty(29), 1);
      // The bar swaps to a stepper showing the line total.
      expect(find.text('1 × ₹60'), findsOneWidget);
    });
  });

  group('CartScreen', () {
    testWidgets('empty state, then totals once items are added', (tester) async {
      await phone(tester);
      await tester.pumpWidget(wrap(const CartScreen()));
      expect(find.text('Your cart is empty'), findsOneWidget);

      cart.add(1); // ₹275
      await tester.pumpAndSettle();

      expect(find.text('Aashirvaad Atta'), findsOneWidget);
      expect(find.text('Subtotal (1 items)'), findsOneWidget);
      expect(find.text('Add ₹24 more for free delivery'), findsOneWidget);
      expect(find.text('Place Order · ₹${275 + kDeliveryFee}'), findsOneWidget);

      cart.add(43); // ₹30 -> free delivery
      await tester.pumpAndSettle();
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('Place Order · ₹305'), findsOneWidget);
    });

    testWidgets('placing an order clears the cart', (tester) async {
      await phone(tester);
      cart.add(1);
      cart.add(43);
      await tester.pumpWidget(wrap(const CartScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Place Order'));
      await tester.pumpAndSettle();
      expect(find.text('Order placed!'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(cart.isEmpty, isTrue);
    });
  });
}
