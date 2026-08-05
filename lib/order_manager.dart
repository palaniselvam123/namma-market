import 'package:flutter/foundation.dart';
import 'models/order.dart';
import 'catalog.dart';
import 'supabase_config.dart';

/// Manages orders for the customer app: keeps the orders placed in this
/// session for "My Orders", and writes every order through to Supabase so
/// the store dashboard can see it.
class OrderManager extends ChangeNotifier {
  final List<Order> _orders = [];
  DeliveryLocation _selectedLocation = kDeliveryLocations[0];
  String _customerName = '';
  String _customerPhone = '';
  String _paymentMethod = 'UPI';

  List<Order> get orders => List.unmodifiable(_orders);
  DeliveryLocation get selectedLocation => _selectedLocation;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get paymentMethod => _paymentMethod;

  void setDeliveryLocation(DeliveryLocation location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setCustomer({required String name, required String phone}) {
    _customerName = name;
    _customerPhone = phone;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// Builds the order, saves it to Supabase, and returns it. If the network
  /// call fails the order is still returned and shown to the customer — it
  /// just won't reach the store dashboard, so the caller is told via
  /// [Order.dbId] being null.
  Future<Order> placeOrder({
    required Map<int, int> cartItems,
    required int subtotal,
    required int deliveryFee,
    required int total,
  }) async {
    final items = cartItems.entries.map((e) {
      final product = kProducts.firstWhere((p) => p.id == e.key);
      return OrderItem(
        productId: product.id,
        productName: product.name,
        brand: product.brand,
        unit: product.unit,
        quantity: e.value,
        pricePerUnit: product.price,
      );
    }).toList();

    final now = DateTime.now();
    final eta = now.add(Duration(minutes: _selectedLocation.deliveryTimeMinutes));
    final code = generateOrderId();

    var order = Order(
      id: code,
      createdAt: now,
      items: items,
      customerName: _customerName.trim().isEmpty ? 'Guest' : _customerName.trim(),
      customerPhone: _customerPhone.trim(),
      paymentMethod: _paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      deliveryLocation: _selectedLocation,
      estimatedDelivery: eta,
      status: 'confirmed',
    );

    try {
      final row = await supabase
          .from('orders')
          .insert({
            'order_code': code,
            'customer_name': order.customerName,
            'customer_phone': order.customerPhone,
            'delivery_location': _selectedLocation.name,
            'delivery_minutes': _selectedLocation.deliveryTimeMinutes,
            'payment_method': order.paymentMethod,
            'subtotal': subtotal,
            'delivery_fee': deliveryFee,
            'total': total,
            'status': 'confirmed',
            'estimated_delivery': eta.toUtc().toIso8601String(),
          })
          .select()
          .single();

      final orderId = row['id'] as int;
      await supabase
          .from('order_items')
          .insert(items.map((i) => i.toRow(orderId)).toList());

      order = Order(
        dbId: orderId,
        id: code,
        createdAt: now,
        items: items,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        paymentMethod: order.paymentMethod,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        deliveryLocation: _selectedLocation,
        estimatedDelivery: eta,
        status: 'confirmed',
      );
    } catch (_) {
      // Offline or backend unreachable — keep the order locally so the
      // customer still gets their confirmation.
    }

    _orders.add(order);
    notifyListeners();
    return order;
  }

  Order? getOrderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }
}

/// Loads every order plus its line items — used by the store dashboard.
Future<List<Order>> fetchAllOrders() async {
  final orderRows = await supabase
      .from('orders')
      .select()
      .order('placed_at', ascending: false);

  final orders = (orderRows as List).cast<Map<String, dynamic>>();
  if (orders.isEmpty) return [];

  final itemRows = await supabase
      .from('order_items')
      .select()
      .inFilter('order_id', orders.map((o) => o['id'] as int).toList());

  final itemsByOrder = <int, List<OrderItem>>{};
  for (final row in (itemRows as List).cast<Map<String, dynamic>>()) {
    itemsByOrder
        .putIfAbsent(row['order_id'] as int, () => [])
        .add(OrderItem.fromRow(row));
  }

  return orders
      .map((row) => Order.fromRow(row, itemsByOrder[row['id'] as int] ?? []))
      .toList();
}

Future<void> updateOrderStatus(int orderDbId, String status) async {
  await supabase.from('orders').update({'status': status}).eq('id', orderDbId);
}

/// Global order manager instance
final orderManager = OrderManager();
