import 'package:flutter/material.dart';
import '../catalog.dart';

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
  final int productId;
  final int quantity;
  final int pricePerUnit;

  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
  });

  int get subtotal => quantity * pricePerUnit;

  String get productName {
    final product = kProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => kProducts.first,
    );
    return product.name;
  }
}

class Order {
  final String id;
  final DateTime createdAt;
  final List<OrderItem> items;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final DeliveryLocation deliveryLocation;
  final DateTime estimatedDelivery;
  final String status; // pending, confirmed, out_for_delivery, delivered

  const Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryLocation,
    required this.estimatedDelivery,
    this.status = 'confirmed',
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

/// List of delivery locations in Chennai
const List<DeliveryLocation> kDeliveryLocations = [
  DeliveryLocation('T. Nagar', '🏪', 10),
  DeliveryLocation('Kodambakkam', '🏢', 12),
  DeliveryLocation('Mylapore', '🏘️', 8),
  DeliveryLocation('Besant Nagar', '🌆', 9),
  DeliveryLocation('Adyar', '🌳', 11),
  DeliveryLocation('Alwarpet', '🏬', 10),
  DeliveryLocation('Triplicane', '🏛️', 13),
  DeliveryLocation('Teynampet', '🌃', 12),
];

String generateOrderId() {
  final now = DateTime.now();
  final timestamp = now.millisecondsSinceEpoch;
  final random = (timestamp % 10000).toString().padLeft(4, '0');
  return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
}
