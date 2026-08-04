import 'package:flutter/foundation.dart';
import 'models/order.dart';
import 'catalog.dart';

/// Manages orders for the application
class OrderManager extends ChangeNotifier {
  final List<Order> _orders = [];
  DeliveryLocation _selectedLocation = kDeliveryLocations[0];

  List<Order> get orders => List.unmodifiable(_orders);
  DeliveryLocation get selectedLocation => _selectedLocation;

  /// Set the delivery location
  void setDeliveryLocation(DeliveryLocation location) {
    _selectedLocation = location;
    notifyListeners();
  }

  /// Create an order from cart items
  Order createOrder({
    required Map<int, int> cartItems,
    required int subtotal,
    required int deliveryFee,
    required int total,
  }) {
    final items = cartItems.entries.map((e) {
      final product = kProducts.firstWhere((p) => p.id == e.key);
      return OrderItem(
        productId: e.key,
        quantity: e.value,
        pricePerUnit: product.price,
      );
    }).toList();

    final now = DateTime.now();
    final order = Order(
      id: generateOrderId(),
      createdAt: now,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      deliveryLocation: _selectedLocation,
      estimatedDelivery: now.add(
        Duration(minutes: _selectedLocation.deliveryTimeMinutes),
      ),
      status: 'confirmed',
    );

    _orders.add(order);
    notifyListeners();
    return order;
  }

  /// Get order by ID
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update order status
  void updateOrderStatus(String orderId, String status) {
    try {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = Order(
          id: _orders[index].id,
          createdAt: _orders[index].createdAt,
          items: _orders[index].items,
          subtotal: _orders[index].subtotal,
          deliveryFee: _orders[index].deliveryFee,
          total: _orders[index].total,
          deliveryLocation: _orders[index].deliveryLocation,
          estimatedDelivery: _orders[index].estimatedDelivery,
          status: status,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }
}

/// Global order manager instance
final orderManager = OrderManager();
