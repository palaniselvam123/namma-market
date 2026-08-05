import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme.dart';

String relativeTime(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(when);
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

String formatDateTime(DateTime d) => '${formatDate(d)} ${formatTime(d)}';

class StoreHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;
  final Widget? action;

  const StoreHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4,
                    color: c.t0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: c.t2)),
              ],
            ),
          ),
          if (action != null) ...[action!, const SizedBox(width: 8)],
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh, color: c.t1),
          ),
        ],
      ),
    );
  }
}

class StoreStatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const StoreStatTile({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: highlight ? c.primaryBg : c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? c.primary : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: highlight ? c.primary : c.t0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
              color: c.t2,
            ),
          ),
        ],
      ),
    );
  }
}

class StoreSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const StoreSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search, size: 19, color: c.t2),
        isDense: true,
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
      ),
    );
  }
}

class OrderStatusPill extends StatelessWidget {
  final String status;
  final bool large;

  const OrderStatusPill({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Semantic status colour, deliberately separate from the brand accent.
    final (bg, fg) = switch (status) {
      'confirmed' => (const Color(0xFF1D4ED8), const Color(0xFFDBEAFE)),
      'packing' => (const Color(0xFFB45309), const Color(0xFFFEF3C7)),
      'out_for_delivery' => (const Color(0xFF6D28D9), const Color(0xFFEDE9FE)),
      'delivered' => (const Color(0xFF15803D), const Color(0xFFDCFCE7)),
      'cancelled' => (const Color(0xFFB91C1C), const Color(0xFFFEE2E2)),
      _ => (c.t2, c.surfaceAlt),
    };
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 9,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: dark ? bg.withValues(alpha: .28) : fg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withValues(alpha: dark ? .55 : .28)),
      ),
      child: Text(
        orderStatusLabel(status),
        style: TextStyle(
          fontSize: large ? 11.5 : 10,
          fontWeight: FontWeight.w800,
          color: dark ? fg : bg,
        ),
      ),
    );
  }
}

class StoreInfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> lines;

  const StoreInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                  color: c.t2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: c.t0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StoreEmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;

  const StoreEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.t0,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: c.t2, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const StoreErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 34, color: c.t2),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: c.t1, height: 1.45),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: kNavy),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
