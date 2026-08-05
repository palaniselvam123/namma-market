import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme.dart';
import 'store_theme.dart';
import 'store_widgets.dart';

class CustomerSummary {
  final String name;
  final String phone;
  final List<Order> orders;

  const CustomerSummary({
    required this.name,
    required this.phone,
    required this.orders,
  });

  int get orderCount => orders.length;
  int get totalSpent => orders
      .where((o) => o.status != 'cancelled')
      .fold(0, (s, o) => s + o.total);
  DateTime get lastOrderAt => orders
      .map((o) => o.createdAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  String get topArea {
    final counts = <String, int>{};
    for (final o in orders) {
      counts[o.deliveryLocation.name] =
          (counts[o.deliveryLocation.name] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

/// Customers are derived from orders — there are no user accounts, so the
/// phone number captured at checkout is the identity.
List<CustomerSummary> summariseCustomers(List<Order> orders) {
  final grouped = <String, List<Order>>{};
  for (final order in orders) {
    final key = order.customerPhone.trim().isEmpty
        ? 'name:${order.customerName.toLowerCase()}'
        : order.customerPhone.trim();
    grouped.putIfAbsent(key, () => []).add(order);
  }

  final summaries = grouped.values.map((list) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return CustomerSummary(
      name: list.first.customerName,
      phone: list.first.customerPhone,
      orders: list,
    );
  }).toList();

  summaries.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
  return summaries;
}

class StoreCustomersView extends StatefulWidget {
  final List<Order> orders;
  final bool loading;
  final Object? error;
  final VoidCallback onRefresh;

  const StoreCustomersView({
    super.key,
    required this.orders,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  @override
  State<StoreCustomersView> createState() => _StoreCustomersViewState();
}

class _StoreCustomersViewState extends State<StoreCustomersView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.error != null) {
      return StoreErrorState(
        message: 'Could not load customers.\n${widget.error}',
        onRetry: widget.onRefresh,
      );
    }

    final all = summariseCustomers(widget.orders);
    final q = _query.trim().toLowerCase();
    final visible = q.isEmpty
        ? all
        : all
            .where((cust) =>
                cust.name.toLowerCase().contains(q) ||
                cust.phone.contains(q))
            .toList();

    final repeat = all.where((cust) => cust.orderCount > 1).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreHeader(
          title: 'Customers',
          subtitle:
              '${all.length} customer${all.length == 1 ? '' : 's'} · $repeat repeat',
          emoji: '👥',
          accent: kViolet,
          onRefresh: widget.onRefresh,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: StoreSearchField(
            hint: 'Search by name or phone',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? StoreEmptyState(
                  emoji: '👥',
                  title: all.isEmpty ? 'No customers yet' : 'No matches',
                  body: all.isEmpty
                      ? 'Anyone who places an order will appear here with their history.'
                      : 'Try a different name or phone number.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, i) => Rise(
                    index: i,
                    child: _CustomerCard(
                      customer: visible[i],
                      rank: q.isEmpty ? i : null,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerSummary customer;
  final int? rank;

  const _CustomerCard({required this.customer, this.rank});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final initials = customer.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final accent = [kIndigo, kViolet, kEmerald, kAmber, kCyan, kRose][
        customer.name.hashCode.abs() % 6];

    return StoreCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: accent.gradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            customer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: c.t0,
                            ),
                          ),
                        ),
                        if (rank == 0) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: kAmber.gradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'TOP',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        if (customer.orderCount > 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: kEmerald.soft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: kEmerald.start.withValues(alpha: .3)),
                            ),
                            child: Text(
                              'REPEAT',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .5,
                                color: kEmerald.start,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.phone.isEmpty
                          ? 'No phone on file'
                          : customer.phone,
                      style: TextStyle(fontSize: 11.5, color: c.t2),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${customer.totalSpent}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: c.t0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'lifetime',
                    style: TextStyle(fontSize: 9.5, color: c.t2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: c.surfaceSunk,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                _Metric(
                  label: 'Orders',
                  value: '${customer.orderCount}',
                ),
                _Divider(),
                _Metric(
                  label: 'Usual area',
                  value: customer.topArea,
                ),
                _Divider(),
                _Metric(
                  label: 'Last order',
                  value: relativeTime(customer.lastOrderAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 22,
        color: context.c.border,
      );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: c.t0,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: c.t2,
            ),
          ),
        ],
      ),
    );
  }
}
