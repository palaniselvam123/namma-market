import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/order.dart';
import '../order_manager.dart';

void showCheckoutSheet(BuildContext context, VoidCallback onConfirm) {
  final c = context.c;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return FractionallySizedBox(
        heightFactor: .85,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: c.t0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Icon(Icons.close, color: c.t2),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CheckoutSection(
                        title: 'Delivery Address',
                        icon: '📍',
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return ListenableBuilder(
                              listenable: orderManager,
                              builder: (context, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showAddressOptions(sheetContext),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: c.bg,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(color: c.border),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    orderManager
                                                        .selectedLocation.name,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: c.t0,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Delivery in ${orderManager.selectedLocation.deliveryTimeMinutes} mins',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: c.t2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.chevron_right,
                                                color: c.t2, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CheckoutSection(
                        title: 'Payment Method',
                        icon: '💳',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PaymentOption(
                              icon: '📱',
                              label: 'UPI',
                              description: 'Google Pay, PhonePe, etc.',
                              selected: true,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _PaymentOption(
                              icon: '💳',
                              label: 'Debit Card',
                              description: 'Visa, Mastercard',
                              selected: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _PaymentOption(
                              icon: '🏦',
                              label: 'Net Banking',
                              description: 'All major banks',
                              selected: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _PaymentOption(
                              icon: '💰',
                              label: 'Cash on Delivery',
                              description: 'Pay on delivery',
                              selected: false,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CheckoutSection(
                        title: 'Order Details',
                        icon: '📋',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items will be carefully packed',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.t1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Fresh produce guaranteed with our quality check',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.t2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onConfirm();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A6818), Color(0xFF1EB040)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0A6818).withValues(alpha: .25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CheckoutSection extends StatelessWidget {
  final String title;
  final String icon;
  final Widget content;

  const _CheckoutSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.t0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.primaryBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? c.primary : c.border,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.t0,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: c.t2,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: c.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

void _showAddressOptions(BuildContext context) {
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
                              Text(location.emoji,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
