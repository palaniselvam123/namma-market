/// Delivery locations with estimated delivery times
class DeliveryLocation {
  final String name;
  final String emoji;
  final int deliveryTimeMinutes;

  const DeliveryLocation(
    this.name,
    this.emoji,
    this.deliveryTimeMinutes,
  );
}

class OrderItem {
  final int? productId;

  /// Name/brand/unit are snapshotted onto the order rather than looked up
  /// from the catalog, so an order still reads correctly after the product
  /// is renamed, repriced, or removed from the shop.
  final String productName;
  final String? brand;
  final String? unit;
  final int quantity;
  final int pricePerUnit;

  const OrderItem({
    this.productId,
    required this.productName,
    this.brand,
    this.unit,
    required this.quantity,
    required this.pricePerUnit,
  });

  int get subtotal => quantity * pricePerUnit;

  factory OrderItem.fromRow(Map<String, dynamic> row) => OrderItem(
        productId: row['product_id'] as int?,
        productName: row['product_name'] as String,
        brand: row['brand'] as String?,
        unit: row['unit'] as String?,
        quantity: row['quantity'] as int,
        pricePerUnit: row['price_per_unit'] as int,
      );

  Map<String, dynamic> toRow(int orderId) => {
        'order_id': orderId,
        'product_id': productId,
        'product_name': productName,
        'brand': brand,
        'unit': unit,
        'quantity': quantity,
        'price_per_unit': pricePerUnit,
      };
}

class Order {
  /// Database primary key — null for an order that hasn't been saved yet.
  final int? dbId;

  /// Human-facing order code (ORDyyyymmddnnnn), shown to customer and store.
  final String id;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String customerName;
  final String customerPhone;
  final String paymentMethod;

  /// Full street address snapshotted at checkout, so the shop still sees
  /// where an order went even if the shopper later edits that address.
  final String? deliveryAddress;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final DeliveryLocation deliveryLocation;
  final DateTime estimatedDelivery;
  final String status; // confirmed, packing, out_for_delivery, delivered, cancelled

  const Order({
    this.dbId,
    required this.id,
    required this.createdAt,
    required this.items,
    this.customerName = 'Guest',
    this.customerPhone = '',
    this.paymentMethod = 'UPI',
    this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryLocation,
    required this.estimatedDelivery,
    this.status = 'confirmed',
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({String? status}) => Order(
        dbId: dbId,
        id: id,
        createdAt: createdAt,
        items: items,
        customerName: customerName,
        customerPhone: customerPhone,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        deliveryLocation: deliveryLocation,
        estimatedDelivery: estimatedDelivery,
        status: status ?? this.status,
      );

  factory Order.fromRow(Map<String, dynamic> row, List<OrderItem> items) {
    final locationName = row['delivery_location'] as String;
    final minutes = row['delivery_minutes'] as int? ?? 10;
    final placedAt = DateTime.parse(row['placed_at'] as String).toLocal();
    final eta = row['estimated_delivery'] == null
        ? placedAt.add(Duration(minutes: minutes))
        : DateTime.parse(row['estimated_delivery'] as String).toLocal();

    return Order(
      dbId: row['id'] as int,
      id: row['order_code'] as String,
      createdAt: placedAt,
      items: items,
      customerName: row['customer_name'] as String? ?? 'Guest',
      customerPhone: row['customer_phone'] as String? ?? '',
      paymentMethod: row['payment_method'] as String? ?? 'UPI',
      deliveryAddress: row['delivery_address'] as String?,
      subtotal: row['subtotal'] as int,
      deliveryFee: row['delivery_fee'] as int? ?? 0,
      total: row['total'] as int,
      deliveryLocation: kDeliveryLocations.firstWhere(
        (l) => l.name == locationName,
        orElse: () => DeliveryLocation(locationName, '📍', minutes),
      ),
      estimatedDelivery: eta,
      status: row['status'] as String? ?? 'confirmed',
    );
  }
}

/// Every status an order can move through, in the order the store works them.
const List<String> kOrderStatuses = [
  'confirmed',
  'packing',
  'out_for_delivery',
  'delivered',
  'cancelled',
];

String orderStatusLabel(String status) => switch (status) {
      'confirmed' => 'Confirmed',
      'packing' => 'Packing',
      'out_for_delivery' => 'Out for Delivery',
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled',
      _ => 'Pending',
    };

/// Where the shop physically is. Everything the app delivers to is measured
/// out from here.
const kStoreArea = 'Kovur';
const kStorePincode = '600122';
const kStoreAddress = 'Kovur, Chennai $kStorePincode';

/// Delivery zones around the Kovur store, ordered by how quickly a rider can
/// reach them. These are the neighbouring areas along Kundrathur Road and
/// towards Porur — nothing further out is served.
const List<DeliveryLocation> kDeliveryLocations = [
  DeliveryLocation('Kovur', '🏪', 8),
  DeliveryLocation('Kolapakkam', '🌳', 10),
  DeliveryLocation('Gerugambakkam', '🏘️', 11),
  DeliveryLocation('Moulivakkam', '🏢', 13),
  DeliveryLocation('Kundrathur', '🛕', 14),
  DeliveryLocation('Mangadu', '🌾', 16),
  DeliveryLocation('Iyyappanthangal', '🏬', 17),
  DeliveryLocation('Porur', '🌆', 18),
  DeliveryLocation('Madananthapuram', '🏡', 15),
  DeliveryLocation('Ramapuram', '🌃', 20),
];

String generateOrderId() {
  final now = DateTime.now();
  final timestamp = now.millisecondsSinceEpoch;
  final random = (timestamp % 10000).toString().padLeft(4, '0');
  return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
}
