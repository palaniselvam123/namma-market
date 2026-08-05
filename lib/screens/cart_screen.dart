import 'package:flutter/material.dart';
import '../app_state.dart';
import '../cart.dart';
import '../catalog.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import '../order_manager.dart';
import '../models/order.dart';
import 'order_confirmation.dart';
import 'checkout.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                const Text('🛒', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  'My Cart',
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
              listenable: cart,
              // Passing the items in keeps this widget non-const, so the
              // subtree actually rebuilds when quantities change.
              builder: (context, _) => cart.isEmpty
                  ? const _EmptyCart()
                  : _CartBody(items: cart.items),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: c.t0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add fresh groceries from Namma MahaRaja',
            style: TextStyle(fontSize: 12.5, color: c.t2),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => appState.goTab(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Start Shopping',
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

class _CartBody extends StatelessWidget {
  final Map<int, int> items;

  const _CartBody({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final entries = items.entries.toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              ListenableBuilder(
                listenable: orderManager,
                builder: (context, _) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.primaryBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.primary.withValues(alpha: .3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Location',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                            color: c.t2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showLocationPicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: c.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      orderManager.selectedLocation.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          orderManager.selectedLocation.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: c.t0,
                                          ),
                                        ),
                                        Text(
                                          'Arrives in ${orderManager.selectedLocation.deliveryTimeMinutes} mins',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: c.t2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right, color: c.t2, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              for (final e in entries) ...[
                _CartRow(productId: e.key, qty: e.value),
                const SizedBox(height: 8),
              ],
              if (cart.savings > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.greenBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🎉  You save ₹${cart.savings} on this order!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.green,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Order summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: c.t0,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: c.borderLight),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      'Subtotal (${cart.count} items)',
                      '₹${cart.subtotal}',
                    ),
                    _SummaryRow(
                      'Delivery fee',
                      cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee}',
                      valueColor: cart.deliveryFee == 0 ? c.green : null,
                    ),
                    if (cart.deliveryFee > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Add ₹${cart.toFreeDelivery} more for free delivery',
                            style: TextStyle(fontSize: 11, color: c.green),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 10),
                      child: Divider(height: 1, color: c.borderLight),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: c.t0,
                          ),
                        ),
                        Text(
                          '₹${cart.total}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: c.t0,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GestureDetector(
            onTap: () => _placeOrder(context),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB82800), Color(0xFFD84A18)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: .35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Place Order · ₹${cart.total}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _placeOrder(BuildContext context) {
    showCheckoutSheet(context, () async {
      // Saving the order hits the network, so hold a blocking spinner until
      // we have an order code to show — otherwise a slow connection looks
      // like the Confirm button did nothing.
      showDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final order = await orderManager.placeOrder(
        cartItems: cart.items,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        total: cart.total,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: false).pop(); // dismiss spinner
      showOrderConfirmation(context, order);
    });
  }

  void _showLocationPicker(BuildContext context) {
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
                  Text(
                    'Select Delivery Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: c.t0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      for (final location in kDeliveryLocations) ...[
                        GestureDetector(
                          onTap: () {
                            orderManager.setDeliveryLocation(location);
                            Navigator.pop(dialogContext);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: orderManager.selectedLocation.name ==
                                      location.name
                                  ? c.primaryBg
                                  : c.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: orderManager.selectedLocation.name ==
                                        location.name
                                    ? c.primary
                                    : c.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  location.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: c.t0,
                                        ),
                                      ),
                                      Text(
                                        'Arrives in ${location.deliveryTimeMinutes} mins',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: c.t2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (orderManager.selectedLocation.name ==
                                    location.name)
                                  Icon(Icons.check_circle,
                                      color: c.primary, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: c.t1)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: valueColor != null ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? c.t1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final int productId;
  final int qty;

  const _CartRow({required this.productId, required this.qty});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = productById(productId);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 58,
              height: 58,
              child: ProductImage(product: p),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.brand.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .4,
                    color: c.t2,
                  ),
                ),
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: c.t0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '₹${p.price * qty}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: c.t0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          AddControl(product: p),
        ],
      ),
    );
  }
}
