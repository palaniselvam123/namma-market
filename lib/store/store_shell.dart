import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';
import 'store_orders.dart';
import 'store_products.dart';

/// Below this width the console switches from a desktop rail + master/detail
/// layout to a stacked, single-column phone layout.
const double kWideBreakpoint = 900;

/// Simple client-side gate, matching the customer app's admin panel. It keeps
/// the console out of casual reach but is not real authentication — see the
/// note in lib/screens/admin.dart.
const _storePassword = 'maharaja2026';

class StoreShell extends StatefulWidget {
  const StoreShell({super.key});

  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  bool _unlocked = false;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (!_unlocked) {
      return _StoreLogin(onUnlock: () => setState(() => _unlocked = true));
    }

    final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;
    final body = _tab == 0 ? const StoreOrdersView() : const StoreProductsView();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  _SideRail(
                    tab: _tab,
                    onSelect: (i) => setState(() => _tab = i),
                  ),
                  Expanded(child: body),
                ],
              )
            : Column(
                children: [
                  const _MobileHeader(),
                  Expanded(child: body),
                ],
              ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Products',
                ),
              ],
            ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [kNavyDeep, kNavy],
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
        ],
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onSelect;

  const _SideRail({required this.tab, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kNavyDeep, kNavy, kNavyLight],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
          _RailItem(
            icon: Icons.receipt_long,
            label: 'Orders',
            selected: tab == 0,
            onTap: () => onSelect(0),
          ),
          _RailItem(
            icon: Icons.inventory_2,
            label: 'Products',
            selected: tab == 1,
            onTap: () => onSelect(1),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Namma MahaRaja\nSuper Market',
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
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? Colors.white.withValues(alpha: .12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? kGoldLeaf : Colors.white.withValues(alpha: .72),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : Colors.white.withValues(alpha: .78),
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
            colors: [kNavyDeep, kNavy, kNavyLight],
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(height: 46, color: kNavy),
                    const SizedBox(height: 14),
                    Text(
                      'Store Console',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: c.t0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Orders and product management',
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
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: c.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: kNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Open Console',
                          style: TextStyle(fontWeight: FontWeight.w800),
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
