import 'package:flutter/material.dart';
import '../models/order.dart';
import '../order_manager.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';
import 'store_customers.dart';
import 'store_dashboard.dart';
import 'store_orders.dart';
import 'store_products.dart';
import 'store_theme.dart';

/// Below this width the console switches from a desktop rail + master/detail
/// layout to a stacked, single-column phone layout.
const double kWideBreakpoint = 900;

/// Simple client-side gate, matching the customer app's admin panel. It keeps
/// the console out of casual reach but is not real authentication — see the
/// note in lib/screens/admin.dart.
const _storePassword = 'maharaja2026';

const _sections = [
  (icon: Icons.dashboard_rounded, label: 'Dashboard', accent: kIndigo),
  (icon: Icons.receipt_long_rounded, label: 'Orders', accent: kCyan),
  (icon: Icons.inventory_2_rounded, label: 'Products', accent: kEmerald),
  (icon: Icons.people_alt_rounded, label: 'Customers', accent: kViolet),
];

class StoreShell extends StatefulWidget {
  const StoreShell({super.key});

  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  bool _unlocked = false;
  int _tab = 0;

  // Orders are loaded once here and shared with the dashboard, orders and
  // customers sections so switching tabs doesn't refetch.
  List<Order> _orders = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await fetchAllOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  /// Locks the console back to the password screen. Staff share a device on
  /// the shop floor, so there has to be a way out without closing the tab.
  Future<void> _lock() async {
    final c = context.c;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Lock console?'),
        content: const Text(
          'The staff password will be needed to get back in.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: kIndigo.start),
            child: const Text('Lock'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _unlocked = false;
      _tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (!_unlocked) {
      return _StoreLogin(onUnlock: () => setState(() => _unlocked = true));
    }

    final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;

    final body = switch (_tab) {
      0 => StoreDashboardView(
          orders: _orders,
          loading: _loading,
          error: _error,
          onRefresh: _load,
          onSeeOrders: () => setState(() => _tab = 1),
        ),
      1 => StoreOrdersView(
          orders: _orders,
          loading: _loading,
          error: _error,
          onRefresh: _load,
        ),
      2 => const StoreProductsView(),
      _ => StoreCustomersView(
          orders: _orders,
          loading: _loading,
          error: _error,
          onRefresh: _load,
        ),
    };

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  _SideRail(
                    tab: _tab,
                    orderCount: _orders
                        .where((o) =>
                            o.status != 'delivered' && o.status != 'cancelled')
                        .length,
                    onSelect: (i) => setState(() => _tab = i),
                    onLock: _lock,
                  ),
                  Expanded(child: body),
                ],
              )
            : Column(
                children: [
                  _MobileHeader(onLock: _lock),
                  Expanded(child: body),
                ],
              ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: [
                for (final section in _sections)
                  NavigationDestination(
                    icon: Icon(section.icon),
                    label: section.label,
                  ),
              ],
            ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final VoidCallback onLock;

  const _MobileHeader({required this.onLock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [kNavyDeep, kNavy, kNavyLight],
        ),
      ),
      child: Row(
        children: [
          const BrandMark(height: 26, color: kCream),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Namma MahaRaja',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'STORE CONSOLE',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: kGoldLeaf,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLock,
            tooltip: 'Lock console',
            icon: Icon(
              Icons.lock_outline,
              size: 20,
              color: Colors.white.withValues(alpha: .85),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int tab;
  final int orderCount;
  final ValueChanged<int> onSelect;
  final VoidCallback onLock;

  const _SideRail({
    required this.tab,
    required this.orderCount,
    required this.onSelect,
    required this.onLock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kNavyDeep, kNavy, Color(0xFF23406B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
            child: Row(
              children: [
                const BrandMark(height: 34, color: kCream),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MahaRaja',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'STORE CONSOLE',
                        style: TextStyle(
                          fontSize: 8.5,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                          color: kGoldLeaf,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _sections.length; i++)
            _RailItem(
              icon: _sections[i].icon,
              label: _sections[i].label,
              accent: _sections[i].accent,
              selected: tab == i,
              badge: i == 1 && orderCount > 0 ? '$orderCount' : null,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Material(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: onLock,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: Colors.white.withValues(alpha: .8),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Lock console',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: .85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
            child: Text(
              'Namma MahaRaja\nSuper Market · $kStoreArea',
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                color: Colors.white.withValues(alpha: .4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Accent accent;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              gradient: selected ? accent.gradient : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.start.withValues(alpha: .45),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: .68),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: .76),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: .25)
                          : kAmber.start,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
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

class _StoreLogin extends StatefulWidget {
  final VoidCallback onUnlock;

  const _StoreLogin({required this.onUnlock});

  @override
  State<_StoreLogin> createState() => _StoreLoginState();
}

class _StoreLoginState extends State<_StoreLogin> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == _storePassword) {
      widget.onUnlock();
    } else {
      setState(() => _error = 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kNavyDeep, Color(0xFF13294A), Color(0xFF3B2A6B)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .3),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(height: 46, color: kNavy),
                    const SizedBox(height: 14),
                    Text(
                      'Store Console',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.3,
                        color: c.t0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Orders, products and customers',
                      style: TextStyle(fontSize: 12.5, color: c.t2),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _controller,
                      obscureText: true,
                      autofocus: true,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Staff password',
                        errorText: _error,
                        filled: true,
                        fillColor: c.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: c.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: c.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: kIndigo.gradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: _submit,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Open Console',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
