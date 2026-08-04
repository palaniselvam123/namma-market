import 'package:flutter/foundation.dart';
import 'catalog.dart';

const int kFreeDeliveryThreshold = 299;
const int kDeliveryFee = 39;

class CartModel extends ChangeNotifier {
  final Map<int, int> _items = {};

  Map<int, int> get items => Map.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int qty(int id) => _items[id] ?? 0;

  int get count => _items.values.fold(0, (a, b) => a + b);

  int get subtotal => _items.entries
      .fold(0, (sum, e) => sum + productById(e.key).price * e.value);

  int get savings => _items.entries.fold(0, (sum, e) {
        final p = productById(e.key);
        return sum + (p.mrp == null ? 0 : (p.mrp! - p.price) * e.value);
      });

  int get deliveryFee => subtotal >= kFreeDeliveryThreshold ? 0 : kDeliveryFee;
  int get total => subtotal + deliveryFee;
  int get toFreeDelivery => (kFreeDeliveryThreshold - subtotal).clamp(0, kFreeDeliveryThreshold);

  void add(int id) {
    _items[id] = (_items[id] ?? 0) + 1;
    notifyListeners();
  }

  void remove(int id) {
    final next = (_items[id] ?? 0) - 1;
    if (next <= 0) {
      _items.remove(id);
    } else {
      _items[id] = next;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// Single shared cart for the POC — swap for an injected store when a
/// real backend lands.
final cart = CartModel();
