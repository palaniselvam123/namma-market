import 'package:flutter/material.dart';
import '../theme.dart';
import '../order_manager.dart';
import '../models/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      color: c.bg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                const Text('📦', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: c.t0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: orderManager,
              builder: (context, _) {
                final orders = orderManager.orders;

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📦', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.t0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Place your first order to get started',
                          style: TextStyle(fontSize: 12.5, color: c.t2),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[orders.length - 1 - index]; // Reverse order
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderCard(order: order),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final timeElapsed = DateTime.now().difference(order.createdAt);
    final timeAgo = timeElapsed.inMinutes < 60
        ? '${timeElapsed.inMinutes}m ago'
        : timeElapsed.inHours < 24
            ? '${timeElapsed.inHours}h ago'
            : '${timeElapsed.inDays}d ago';

    final statusColor = switch (order.status) {
      'confirmed' => c.green,
      'out_for_delivery' => c.primary,
      'delivered' => c.green,
      _ => c.t2,
    };

    final statusLabel = switch (order.status) {
      'confirmed' => 'Confirmed',
      'out_for_delivery' => 'Out for Delivery',
      'delivered' => 'Delivered',
      _ => 'Pending',
    };

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ${order.id.substring(3)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: c.t0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: c.t2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.itemCount} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.t1,
                      ),
                    ),
                    Text(
                      '₹${order.total}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: c.t0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      order.deliveryLocation.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.t1,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showOrderDetails(context, order),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    final c = context.c;
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: c.t0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Icon(Icons.close, color: c.t2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.primaryBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: c.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.createdAt.toString().substring(0, 16),
                          style: TextStyle(
                            fontSize: 11,
                            color: c.t2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: c.t0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      for (final item in order.items) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.t1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${item.quantity}x',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.t0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '₹${item.subtotal}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: c.t0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: c.border),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 12, color: c.t1),
                      ),
                      Text(
                        '₹${order.subtotal}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.t0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery',
                        style: TextStyle(fontSize: 12, color: c.t1),
                      ),
                      Text(
                        order.deliveryFee == 0 ? 'FREE' : '₹${order.deliveryFee}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: order.deliveryFee == 0 ? c.green : c.t0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: c.border),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: c.t0,
                        ),
                      ),
                      Text(
                        '₹${order.total}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: c.t0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.greenBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery to ${order.deliveryLocation.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: c.green,
                                ),
                              ),
                              Text(
                                'Expected at ${order.estimatedDelivery.hour.toString().padLeft(2, '0')}:${order.estimatedDelivery.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: c.green.withValues(alpha: .8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.primaryBg,
                        border: Border.all(color: c.primary),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
