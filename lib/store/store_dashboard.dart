import 'package:flutter/material.dart';
import '../catalog.dart';
import '../models/order.dart';
import '../theme.dart';
import 'store_theme.dart';
import 'store_widgets.dart';

class StoreDashboardView extends StatelessWidget {
  final List<Order> orders;
  final bool loading;
  final Object? error;
  final VoidCallback onRefresh;
  final VoidCallback onSeeOrders;

  const StoreDashboardView({
    super.key,
    required this.orders,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onSeeOrders,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return StoreErrorState(
        message: 'Could not load the dashboard.\n$error',
        onRetry: onRefresh,
      );
    }

    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final live = orders.where((o) => o.status != 'cancelled').toList();
    final today = live.where((o) => sameDay(o.createdAt, now)).toList();
    final revenueToday = today.fold(0, (s, o) => s + o.total);
    final revenueAll = live.fold(0, (s, o) => s + o.total);
    final needsAction = orders
        .where((o) => o.status != 'delivered' && o.status != 'cancelled')
        .length;
    final avgBasket = live.isEmpty ? 0 : (revenueAll / live.length).round();

    // Last seven days, oldest first.
    final week = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final revenue = live
          .where((o) => sameDay(o.createdAt, day))
          .fold(0, (s, o) => s + o.total);
      return (day: day, revenue: revenue);
    });

    final statusCounts = <String, int>{};
    for (final o in orders) {
      statusCounts[o.status] = (statusCounts[o.status] ?? 0) + 1;
    }

    // Units sold per product across every non-cancelled order.
    final soldUnits = <String, int>{};
    final soldValue = <String, int>{};
    for (final o in live) {
      for (final item in o.items) {
        soldUnits[item.productName] =
            (soldUnits[item.productName] ?? 0) + item.quantity;
        soldValue[item.productName] =
            (soldValue[item.productName] ?? 0) + item.subtotal;
      }
    }
    final topProducts = soldUnits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final outOfStock = kProducts.where((p) => !p.inStock).length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        StoreHeader(
          title: 'Dashboard',
          subtitle: 'Namma MahaRaja Super Market · ${formatDate(now)}',
          emoji: '📊',
          accent: kIndigo,
          onRefresh: onRefresh,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720 ? 4 : 2;
                  final tiles = [
                    StoreStatTile(
                      label: 'Revenue today',
                      value: '₹$revenueToday',
                      icon: '💰',
                      accent: kEmerald,
                      filled: true,
                    ),
                    StoreStatTile(
                      label: 'Orders today',
                      value: '${today.length}',
                      icon: '🧾',
                      accent: kIndigo,
                    ),
                    StoreStatTile(
                      label: 'Needs action',
                      value: '$needsAction',
                      icon: '⏳',
                      accent: kAmber,
                      filled: needsAction > 0,
                    ),
                    StoreStatTile(
                      label: 'Avg basket',
                      value: '₹$avgBasket',
                      icon: '🛒',
                      accent: kViolet,
                    ),
                  ];
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    childAspectRatio: columns == 4 ? 1.5 : 1.65,
                    children: [
                      for (var i = 0; i < tiles.length; i++)
                        Rise(index: i, child: tiles[i]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final revenueCard = Rise(
                    index: 4,
                    child: StoreCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Revenue · last 7 days'),
                          RevenueBarChart(data: week),
                        ],
                      ),
                    ),
                  );
                  final statusCard = Rise(
                    index: 5,
                    child: StoreCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            'Orders by status',
                            trailing: '${orders.length} total',
                          ),
                          const SizedBox(height: 4),
                          StatusBreakdown(
                            counts: statusCounts,
                            total: orders.length,
                          ),
                        ],
                      ),
                    ),
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        revenueCard,
                        const SizedBox(height: 14),
                        statusCard,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: revenueCard),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: statusCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final topCard = Rise(
                    index: 6,
                    child: StoreCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Top sellers'),
                          if (topProducts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'No sales yet.',
                                style: TextStyle(fontSize: 12, color: c.t2),
                              ),
                            )
                          else
                            for (var i = 0;
                                i < topProducts.length.clamp(0, 5);
                                i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: i == 0
                                            ? kAmber.gradient
                                            : null,
                                        color: i == 0 ? null : c.surfaceAlt,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: i == 0 ? Colors.white : c.t2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        topProducts[i].key,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: c.t0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${topProducts[i].value} sold',
                                      style: TextStyle(
                                          fontSize: 11, color: c.t2),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '₹${soldValue[topProducts[i].key] ?? 0}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: c.t0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  );

                  final healthCard = Rise(
                    index: 7,
                    child: StoreCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Shop health'),
                          _HealthRow(
                            icon: '📦',
                            label: 'Products listed',
                            value: '${kProducts.length}',
                            accent: kCyan,
                          ),
                          _HealthRow(
                            icon: '🚫',
                            label: 'Out of stock',
                            value: '$outOfStock',
                            accent: outOfStock > 0 ? kRose : kEmerald,
                          ),
                          _HealthRow(
                            icon: '👥',
                            label: 'Customers served',
                            value:
                                '${orders.map((o) => o.customerPhone).where((p) => p.isNotEmpty).toSet().length}',
                            accent: kViolet,
                          ),
                          _HealthRow(
                            icon: '💵',
                            label: 'Lifetime revenue',
                            value: '₹$revenueAll',
                            accent: kEmerald,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: onSeeOrders,
                              child: const Text('Go to orders'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        topCard,
                        const SizedBox(height: 14),
                        healthCard,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: topCard),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: healthCard),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Accent accent;

  const _HealthRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? accent.start.withValues(alpha: .2) : accent.soft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: c.t1),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: c.t0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
