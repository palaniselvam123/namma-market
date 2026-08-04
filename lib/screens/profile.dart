import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';
import 'admin.dart';
import 'orders.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menu = [
    ('📦', 'My Orders'),
    ('📍', 'Delivery Addresses'),
    ('💳', 'Payment Methods'),
    ('🎁', 'Offers & Coupons'),
    ('💎', 'MahaRaja Rewards'),
    ('📞', 'Help & Support'),
    ('🛠️', 'Admin Panel'),
  ];

  void _handleMenuTap(BuildContext context, int index) {
    switch (index) {
      case 0: // My Orders
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FractionallySizedBox(
            heightFactor: .93,
            child: Container(
              decoration: BoxDecoration(
                color: context.c.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: const OrdersScreen(),
            ),
          ),
        );
        break;
      case 1: // Delivery Addresses
        _showComingSoon(context, 'Delivery Addresses');
        break;
      case 2: // Payment Methods
        _showComingSoon(context, 'Payment Methods');
        break;
      case 3: // Offers & Coupons
        _showComingSoon(context, 'Offers & Coupons');
        break;
      case 4: // MahaRaja Rewards
        _showComingSoon(context, 'MahaRaja Rewards');
        break;
      case 5: // Help & Support
        _showComingSoon(context, 'Help & Support');
        break;
      case 6: // Admin Panel
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
        break;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    final c = context.c;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚀', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: c.t0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$feature is on its way!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.t1),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kNavyDeep, kNavy, kNavyLight],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: kGoldLeaf.withValues(alpha: .45),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const BrandMark(height: 42, color: kCream),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Karthik Rajan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+91 98401 23456',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: .75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MahaRaja Club Member ✦',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -14),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: c.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  _Stat('47', 'Orders', border: true),
                  _Stat('₹1,240', 'Saved', border: true),
                  _Stat('4.8★', 'Rating'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: Column(
              children: [
                for (var i = 0; i < _menu.length; i++) ...[
                  GestureDetector(
                    onTap: () => _handleMenuTap(context, i),
                    child: _MenuItem(emoji: _menu[i].$1, label: _menu[i].$2),
                  ),
                  const SizedBox(height: 6),
                ],
                GestureDetector(
                  onTap: () {},
                  child: _MenuItem(emoji: '🚪', label: 'Sign Out', danger: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool border;

  const _Stat(this.value, this.label, {this.border = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          border: border
              ? Border(right: BorderSide(color: c.borderLight))
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: c.t0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
                color: c.t2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool danger;

  const _MenuItem({
    required this.emoji,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(emoji, style: const TextStyle(fontSize: 17)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: danger ? c.primary : c.t0,
              ),
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: c.t3),
        ],
      ),
    );
  }
}
