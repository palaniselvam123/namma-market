import 'package:flutter/material.dart';
import '../models/order.dart';
import '../order_manager.dart';
import '../theme.dart';
import 'store_shell.dart';
import 'store_theme.dart';
import 'store_widgets.dart';

class StoreOrdersView extends StatefulWidget {
  final List<Order> orders;
  final bool loading;
  final Object? error;
  final VoidCallback onRefresh;

  const StoreOrdersView({
    super.key,
    required this.orders,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  @override
  State<StoreOrdersView> createState() => _StoreOrdersViewState();
}

class _StoreOrdersViewState extends State<StoreOrdersView> {
  String _filter = 'all';
  String _query = '';
  String? _selectedCode;
  bool _updating = false;

  Order? get _selected {
    if (_selectedCode == null) return null;
    for (final o in widget.orders) {
      if (o.id == _selectedCode) return o;
    }
    return null;
  }

  Future<void> _setStatus(Order order, String status) async {
    if (order.dbId == null) return;
    setState(() => _updating = true);
    try {
      await updateOrderStatus(order.dbId!, status);

      // Tell the customer. A failure here must not look like the status
      // change failed — the shop's record is already updated.
      var delivered = 0;
      String? notifyError;
      try {
        delivered = await notifyCustomerOfStatus(order, status);
      } catch (e) {
        notifyError = '$e';
      }

      widget.onRefresh();
      if (!mounted) return;
      setState(() => _updating = false);

      final label = orderStatusLabel(status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notifyError != null
                ? '${order.id} → $label · customer alert failed'
                : delivered > 0
                    ? '${order.id} → $label · pushed to $delivered device${delivered == 1 ? '' : 's'}'
                    : '${order.id} → $label · saved to the customer\'s updates',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _updating = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  List<Order> get _visible {
    final q = _query.trim().toLowerCase();
    return widget.orders.where((o) {
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
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.error != null) {
      return StoreErrorState(
        message: 'Could not load orders.\n${widget.error}',
        onRetry: widget.onRefresh,
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;
    final all = widget.orders;
    final visible = _visible;

    int countFor(String s) =>
        s == 'all' ? all.length : all.where((o) => o.status == s).length;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreHeader(
          title: 'Orders',
          subtitle: '${all.length} order${all.length == 1 ? '' : 's'} · '
              '${all.where((o) => o.status != 'delivered' && o.status != 'cancelled').length} open',
          emoji: '🧾',
          accent: kCyan,
          onRefresh: widget.onRefresh,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: StoreSearchField(
            hint: 'Search order ID, customer or phone',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              for (final status in ['all', ...kOrderStatuses])
                PillChip(
                  label:
                      '${status == 'all' ? 'All' : orderStatusLabel(status)} · ${countFor(status)}',
                  selected: _filter == status,
                  accent: status == 'all' ? kIndigo : accentForStatus(status),
                  onTap: () => setState(() => _filter = status),
                ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? StoreEmptyState(
                  emoji: '🧾',
                  title: all.isEmpty ? 'No orders yet' : 'No matching orders',
                  body: all.isEmpty
                      ? 'Orders placed in the customer app appear here, and the customer is notified whenever you change a status.'
                      : 'Try a different search or filter.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, i) {
                    final order = visible[i];
                    return Rise(
                      index: i,
                      child: _OrderRow(
                        order: order,
                        selected: wide && _selectedCode == order.id,
                        onTap: () {
                          if (wide) {
                            setState(() => _selectedCode = order.id);
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
                                    updating: _updating,
                                    onSetStatus: (s) => _setStatus(order, s),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (!wide) return list;

    final selected = _selected;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 440, child: list),
        Container(width: 1, color: c.border),
        Expanded(
          child: selected == null
              ? const StoreEmptyState(
                  emoji: '👈',
                  title: 'Select an order',
                  body: 'Pick an order on the left to see its full detail and update its status.',
                )
              : OrderDetailPanel(
                  order: selected,
                  updating: _updating,
                  onSetStatus: (s) => _setStatus(selected, s),
                ),
        ),
      ],
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
    final accent = accentForStatus(order.status);
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent.start : c.border,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: softShadow(Theme.of(context).brightness,
                strength: selected ? 1 : .6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Status stripe — the row's state is readable before reading.
              Container(width: 4, height: 96, color: accent.start),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
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
                      const SizedBox(height: 9),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: c.t0,
                              ),
                            ),
                          ),
                          Text(
                            '₹${order.total}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: c.t0,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 13, color: c.t3),
                          const SizedBox(width: 4),
                          Text(
                            order.deliveryLocation.name,
                            style: TextStyle(fontSize: 11, color: c.t2),
                          ),
                          Text('  ·  ',
                              style: TextStyle(fontSize: 11, color: c.t3)),
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
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailPanel extends StatelessWidget {
  final Order order;
  final bool updating;
  final ValueChanged<String> onSetStatus;

  const OrderDetailPanel({
    super.key,
    required this.order,
    required this.updating,
    required this.onSetStatus,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final accent = accentForStatus(order.status);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: accent.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: accent.start.withValues(alpha: .3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatDateTime(order.createdAt)} · ${relativeTime(order.createdAt)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: .85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderStatusLabel(order.status),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              StoreInfoCard(
                icon: '👤',
                title: 'Customer',
                accent: kViolet,
                lines: [
                  order.customerName,
                  if (order.customerPhone.isNotEmpty) order.customerPhone,
                ],
              ),
              StoreInfoCard(
                icon: '📍',
                title: 'Delivery',
                accent: kCyan,
                lines: [
                  order.deliveryLocation.name,
                  'ETA ${formatTime(order.estimatedDelivery)}',
                ],
              ),
              StoreInfoCard(
                icon: '💳',
                title: 'Payment',
                accent: kEmerald,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i < cards.length - 1) const SizedBox(width: 10),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        StoreCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: SectionTitle(
                  'Items',
                  trailing:
                      '${order.itemCount} unit${order.itemCount == 1 ? '' : 's'}',
                ),
              ),
              for (var i = 0; i < order.items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.borderLight),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
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
                        label: 'Total', value: '₹${order.total}', bold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        StoreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Update status'),
              Text(
                'The customer is notified on their phone each time you change this.',
                style: TextStyle(fontSize: 11.5, color: c.t2),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in kOrderStatuses)
                    _StatusButton(
                      status: status,
                      current: order.status == status,
                      enabled: !updating && order.status != status,
                      onTap: () => onSetStatus(status),
                    ),
                ],
              ),
              if (updating)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (order.dbId == null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'This order was never saved to the server, so its status cannot be changed.',
                    style: TextStyle(fontSize: 11.5, color: kRose.start),
                  ),
                ),
              if (order.customerPhone.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'No phone number on this order — updates are recorded but cannot be pushed.',
                    style: TextStyle(fontSize: 11.5, color: kAmber.start),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String status;
  final bool current;
  final bool enabled;
  final VoidCallback onTap;

  const _StatusButton({
    required this.status,
    required this.current,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final accent = accentForStatus(status);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: enabled || current ? 1 : .45,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: current ? accent.gradient : null,
              color: current ? null : (dark ? c.surfaceAlt : accent.soft),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: current
                    ? Colors.transparent
                    : accent.start.withValues(alpha: .3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (current) ...[
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  orderStatusLabel(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: current
                        ? Colors.white
                        : (dark ? Colors.white : accent.start),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
