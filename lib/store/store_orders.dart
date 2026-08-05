import 'package:flutter/material.dart';
import '../models/order.dart';
import '../order_manager.dart';
import '../theme.dart';
import 'store_shell.dart';
import 'store_widgets.dart';

class StoreOrdersView extends StatefulWidget {
  const StoreOrdersView({super.key});

  @override
  State<StoreOrdersView> createState() => _StoreOrdersViewState();
}

class _StoreOrdersViewState extends State<StoreOrdersView> {
  late Future<List<Order>> _future;
  String _filter = 'all';
  Order? _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = fetchAllOrders();
  }

  void _reload() {
    setState(() {
      _future = fetchAllOrders();
      _selected = null;
    });
  }

  Future<void> _setStatus(Order order, String status) async {
    if (order.dbId == null) return;
    try {
      await updateOrderStatus(order.dbId!, status);
      if (!mounted) return;
      setState(() {
        _selected = order.copyWith(status: status);
        _future = fetchAllOrders();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${order.id} → ${orderStatusLabel(status)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  List<Order> _visible(List<Order> all) {
    final q = _query.trim().toLowerCase();
    return all.where((o) {
      if (_filter != 'all' && o.status != _filter) return false;
      if (q.isEmpty) return true;
      return o.id.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.customerPhone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;

    return FutureBuilder<List<Order>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return StoreErrorState(
            message: 'Could not load orders.\n${snapshot.error}',
            onRetry: _reload,
          );
        }

        final all = snapshot.data ?? [];
        final visible = _visible(all);

        final list = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoreHeader(
              title: 'Orders',
              subtitle: '${all.length} order${all.length == 1 ? '' : 's'} placed',
              onRefresh: _reload,
            ),
            _StatsRow(orders: all),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: StoreSearchField(
                hint: 'Search order ID, customer or phone',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            _FilterChips(
              selected: _filter,
              orders: all,
              onSelect: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: visible.isEmpty
                  ? StoreEmptyState(
                      emoji: '🧾',
                      title: all.isEmpty ? 'No orders yet' : 'No matching orders',
                      body: all.isEmpty
                          ? 'Orders placed in the customer app appear here in real time.'
                          : 'Try a different search or filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final order = visible[i];
                        return _OrderRow(
                          order: order,
                          selected: wide && _selected?.id == order.id,
                          onTap: () {
                            if (wide) {
                              setState(() => _selected = order);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => Scaffold(
                                    backgroundColor: c.bg,
                                    appBar: AppBar(
                                      title: Text(order.id),
                                      backgroundColor: c.surface,
                                    ),
                                    body: OrderDetailPanel(
                                      order: order,
                                      onSetStatus: (s) => _setStatus(order, s),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );

        if (!wide) return list;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 430, child: list),
            Container(width: 1, color: c.border),
            Expanded(
              child: _selected == null
                  ? StoreEmptyState(
                      emoji: '👈',
                      title: 'Select an order',
                      body: 'Pick an order on the left to see its full detail.',
                    )
                  : OrderDetailPanel(
                      order: _selected!,
                      onSetStatus: (s) => _setStatus(_selected!, s),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Order> orders;

  const _StatsRow({required this.orders});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;

    final today = orders.where((o) => isToday(o.createdAt)).toList();
    final revenue = today
        .where((o) => o.status != 'cancelled')
        .fold(0, (sum, o) => sum + o.total);
    final active = orders
        .where((o) => o.status != 'delivered' && o.status != 'cancelled')
        .length;
    final delivered = today.where((o) => o.status == 'delivered').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Expanded(child: StoreStatTile(label: 'Orders today', value: '${today.length}')),
          const SizedBox(width: 10),
          Expanded(child: StoreStatTile(label: 'Revenue today', value: '₹$revenue')),
          const SizedBox(width: 10),
          Expanded(
            child: StoreStatTile(
              label: 'Needs action',
              value: '$active',
              highlight: active > 0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: StoreStatTile(label: 'Delivered', value: '$delivered')),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final List<Order> orders;
  final ValueChanged<String> onSelect;

  const _FilterChips({
    required this.selected,
    required this.orders,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    int countFor(String s) =>
        s == 'all' ? orders.length : orders.where((o) => o.status == s).length;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final status in ['all', ...kOrderStatuses]) ...[
            GestureDetector(
              onTap: () => onSelect(status),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: selected == status ? kNavy : c.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected == status ? kNavy : c.border,
                  ),
                ),
                child: Text(
                  '${status == 'all' ? 'All' : orderStatusLabel(status)} · ${countFor(status)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: selected == status ? Colors.white : c.t1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Order order;
  final bool selected;
  final VoidCallback onTap;

  const _OrderRow({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: selected ? c.primaryBg : c.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? c.primary : c.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.id,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: c.t0,
                      ),
                    ),
                  ),
                  OrderStatusPill(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: c.t2),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: c.t0,
                      ),
                    ),
                  ),
                  Text(
                    '₹${order.total}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: c.t0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 13, color: c.t3),
                  const SizedBox(width: 4),
                  Text(
                    order.deliveryLocation.name,
                    style: TextStyle(fontSize: 11, color: c.t2),
                  ),
                  Text('  ·  ', style: TextStyle(fontSize: 11, color: c.t3)),
                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 11, color: c.t2),
                  ),
                  const Spacer(),
                  Text(
                    relativeTime(order.createdAt),
                    style: TextStyle(fontSize: 11, color: c.t2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailPanel extends StatelessWidget {
  final Order order;
  final ValueChanged<String> onSetStatus;

  const OrderDetailPanel({
    super.key,
    required this.order,
    required this.onSetStatus,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: c.t0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Placed ${formatDateTime(order.createdAt)} · ${relativeTime(order.createdAt)}',
                    style: TextStyle(fontSize: 12, color: c.t2),
                  ),
                ],
              ),
            ),
            OrderStatusPill(status: order.status, large: true),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              StoreInfoCard(
                icon: '👤',
                title: 'Customer',
                lines: [
                  order.customerName,
                  if (order.customerPhone.isNotEmpty) order.customerPhone,
                ],
              ),
              StoreInfoCard(
                icon: '📍',
                title: 'Delivery',
                lines: [
                  order.deliveryLocation.name,
                  'ETA ${formatTime(order.estimatedDelivery)}',
                ],
              ),
              StoreInfoCard(
                icon: '💳',
                title: 'Payment',
                lines: [order.paymentMethod, '₹${order.total} total'],
              ),
            ];
            if (constraints.maxWidth < 560) {
              return Column(
                children: [
                  for (final card in cards) ...[
                    SizedBox(width: double.infinity, child: card),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i < cards.length - 1) const SizedBox(width: 10),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        Text(
          'Items',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: c.t0,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < order.items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.borderLight),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.items[i].productName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: c.t0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (order.items[i].brand != null)
                                  order.items[i].brand!,
                                if (order.items[i].unit != null)
                                  order.items[i].unit!,
                              ].join(' · '),
                              style: TextStyle(fontSize: 11, color: c.t2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${order.items[i].pricePerUnit}',
                        style: TextStyle(fontSize: 12, color: c.t2),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '× ${order.items[i].quantity}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: c.t1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 66,
                        child: Text(
                          '₹${order.items[i].subtotal}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: c.t0,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Divider(height: 1, color: c.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  children: [
                    _TotalLine(label: 'Subtotal', value: '₹${order.subtotal}'),
                    const SizedBox(height: 6),
                    _TotalLine(
                      label: 'Delivery fee',
                      value: order.deliveryFee == 0
                          ? 'FREE'
                          : '₹${order.deliveryFee}',
                    ),
                    const SizedBox(height: 10),
                    _TotalLine(
                      label: 'Total',
                      value: '₹${order.total}',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Update status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: c.t0,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in kOrderStatuses)
              OutlinedButton(
                onPressed:
                    order.status == status ? null : () => onSetStatus(status),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      status == 'cancelled' ? c.primary : c.t0,
                  side: BorderSide(
                    color: status == 'cancelled' ? c.primary : c.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  orderStatusLabel(status),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        if (order.dbId == null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              'This order was not saved to the server, so its status cannot be changed.',
              style: TextStyle(fontSize: 11.5, color: c.primary),
            ),
          ),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 13.5 : 12,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            color: bold ? c.t0 : c.t1,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 13.5 : 12,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            color: c.t0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
