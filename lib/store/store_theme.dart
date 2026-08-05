import 'package:flutter/material.dart';

/// Accent palette for the console. Deliberately separate from the customer
/// app's terracotta: this is an operations tool, so colour is used to encode
/// meaning (which metric, which status, which category) rather than to brand.
class Accent {
  final Color start;
  final Color end;
  final Color soft;

  const Accent(this.start, this.end, this.soft);

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [start, end],
      );
}

const kIndigo = Accent(Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFFEEF2FF));
const kViolet = Accent(Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFF5F3FF));
const kEmerald = Accent(Color(0xFF059669), Color(0xFF10B981), Color(0xFFECFDF5));
const kAmber = Accent(Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFFFBEB));
const kRose = Accent(Color(0xFFE11D48), Color(0xFFF43F5E), Color(0xFFFFF1F2));
const kCyan = Accent(Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFFECFEFF));

/// Colour used for each order status, everywhere in the console.
Accent accentForStatus(String status) => switch (status) {
      'confirmed' => kIndigo,
      'packing' => kAmber,
      'out_for_delivery' => kViolet,
      'delivered' => kEmerald,
      'cancelled' => kRose,
      _ => kCyan,
    };

/// Layered soft shadow — one tight shadow for edge definition, one wide and
/// faint for lift. Reads as depth without the muddy grey of a single blur.
List<BoxShadow> softShadow(Brightness brightness, {double strength = 1}) {
  if (brightness == Brightness.dark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: .28 * strength),
        blurRadius: 14 * strength,
        offset: Offset(0, 4 * strength),
      ),
    ];
  }
  return [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: .05 * strength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: .06 * strength),
      blurRadius: 18 * strength,
      offset: Offset(0, 6 * strength),
    ),
  ];
}

/// Fades and lifts a child into place, staggered by [index] so a grid of
/// cards resolves in sequence rather than all at once.
class Rise extends StatelessWidget {
  final int index;
  final Widget child;

  const Rise({super.key, this.index = 0, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 340 + (index * 70).clamp(0, 420)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
