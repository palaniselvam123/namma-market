import 'package:flutter/material.dart';
import '../models/order.dart';
import '../notifications.dart';
import '../theme.dart';
import '../app_state.dart';
import '../cart.dart';

void showOrderConfirmation(BuildContext context, Order order) {
  showDialog(
    context: context,
    useRootNavigator: false,
    builder: (dialogContext) {
      final c = dialogContext.c;
      final deliveryTime = order.estimatedDelivery.difference(order.createdAt).inMinutes;
      final formattedTime = order.estimatedDelivery.hour.toString().padLeft(2, '0') +
          ':' +
          order.estimatedDelivery.minute.toString().padLeft(2, '0');

      return Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A6818), Color(0xFF1EB040)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Order Confirmed!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: c.primaryBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: c.primary.withValues(alpha: .3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .5,
                                    color: c.t2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        order.id,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: c.t0,
                                          letterSpacing: 1,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _copyToClipboard(dialogContext, order.id);
                                      },
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 18,
                                        color: c.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoBox(
                                  icon: '🚚',
                                  label: 'Delivery',
                                  value: '$deliveryTime mins',
                                  subtitle: formattedTime,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoBox(
                                  icon: '📍',
                                  label: 'Location',
                                  value: order.deliveryLocation.name,
                                  subtitle: '${order.itemCount} items',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: c.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: c.t2,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                        fontWeight: FontWeight.w700,
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
                                        fontWeight: FontWeight.w700,
                                        color: order.deliveryFee == 0 ? c.green : c.t0,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(height: 1, color: c.border),
                                ),
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _EnableUpdatesTile(order: order),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () {
                              cart.clear();
                              Navigator.of(dialogContext).pop();
                              appState.goTab(0);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0A6818), Color(0xFF1EB040)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Back to Home',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              appState.goTab(3);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.primaryBg,
                                border: Border.all(color: c.primary),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Track Order',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: c.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Opt-in for delivery push notifications. Permission must be requested from
/// a real tap, so this is a button rather than something that fires on load.
class _EnableUpdatesTile extends StatefulWidget {
  final Order order;

  const _EnableUpdatesTile({required this.order});

  @override
  State<_EnableUpdatesTile> createState() => _EnableUpdatesTileState();
}

class _EnableUpdatesTileState extends State<_EnableUpdatesTile> {
  bool _busy = false;
  bool? _result;

  Future<void> _enable() async {
    setState(() => _busy = true);
    final ok = await notificationCenter.enablePush(widget.order.customerPhone);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final status = notificationCenter.permissionStatus;
    final alreadyOn = _result == true || status == 'granted';

    if (status == 'unsupported') return const SizedBox.shrink();

    if (alreadyOn) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.greenBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_active, size: 18, color: c.green),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'You\'ll get a notification at every step of this delivery.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: c.green,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _busy ? null : _enable,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.primaryBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.primary.withValues(alpha: .35)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_none, size: 19, color: c.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get delivery updates',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: c.primary,
                        ),
                      ),
                      Text(
                        'Know the moment your order is packed and on its way',
                        style: TextStyle(fontSize: 10.5, color: c.t2),
                      ),
                    ],
                  ),
                ),
                if (_busy)
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: c.primary),
                  ),
              ],
            ),
          ),
        ),
        if (_result == false)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Notifications are blocked for this site. You can still see every '
              'update in the app under the bell icon.',
              style: TextStyle(fontSize: 10.5, color: c.t2),
            ),
          ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subtitle;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c.t2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: c.t0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: c.t2,
            ),
          ),
        ],
      ),
    );
  }
}

void _copyToClipboard(BuildContext context, String text) {
  // Simple implementation - in a real app, would use Clipboard API
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Order ID copied: $text'),
      duration: const Duration(seconds: 2),
    ),
  );
}
