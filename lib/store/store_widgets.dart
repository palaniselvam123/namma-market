import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme.dart';
import 'store_theme.dart';

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

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String weekdayLabel(DateTime d) => _weekdays[d.weekday - 1];

/// Gradient hero band that opens every section.
class StoreHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Accent accent;
  final VoidCallback onRefresh;
  final Widget? action;

  const StoreHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accent,
    required this.onRefresh,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: accent.gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.start.withValues(alpha: .32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 21)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: .82),
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[action!, const SizedBox(width: 4)],
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Vivid metric tile — each metric owns a colour so the row reads at a glance.
class StoreStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Accent accent;
  final bool filled;

  const StoreStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        gradient: filled ? accent.gradient : null,
        color: filled ? null : c.surface,
        borderRadius: BorderRadius.circular(16),
        border: filled
            ? null
            : Border.all(color: dark ? c.border : accent.start.withValues(alpha: .18)),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: accent.start.withValues(alpha: .3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : softShadow(Theme.of(context).brightness, strength: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: .22)
                      : (dark ? accent.start.withValues(alpha: .22) : accent.soft),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -.6,
                color: filled ? Colors.white : c.t0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .7,
              color: filled ? Colors.white.withValues(alpha: .85) : c.t2,
            ),
          ),
        ],
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const StoreCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
        boxShadow: softShadow(Theme.of(context).brightness, strength: .7),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;

  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: c.t0,
              ),
            ),
          ),
          if (trailing != null)
            Text(trailing!, style: TextStyle(fontSize: 11.5, color: c.t2)),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kIndigo.start, width: 1.5),
        ),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Accent accent;
  final VoidCallback onTap;

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? accent.gradient : null,
          color: selected ? null : c.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (dark ? c.border : accent.start.withValues(alpha: .22)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.start.withValues(alpha: .32),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : c.t1,
          ),
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
    final accent = accentForStatus(status);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 13 : 10,
        vertical: large ? 7 : 5,
      ),
      decoration: BoxDecoration(
        color: dark ? accent.start.withValues(alpha: .26) : accent.soft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.start.withValues(alpha: dark ? .5 : .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accent.start,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            orderStatusLabel(status),
            style: TextStyle(
              fontSize: large ? 11.5 : 10,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : accent.start,
            ),
          ),
        ],
      ),
    );
  }
}

class StoreInfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> lines;
  final Accent accent;

  const StoreInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.lines,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? c.surface : accent.soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.start.withValues(alpha: dark ? .3 : .18)),
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
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                  color: dark ? c.t2 : accent.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: c.t0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Seven-day revenue bars. Hand-drawn rather than pulling in a chart package
/// so it inherits the console's palette exactly.
class RevenueBarChart extends StatelessWidget {
  final List<({DateTime day, int revenue})> data;

  const RevenueBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final maxRevenue =
        data.fold<int>(0, (m, d) => d.revenue > m ? d.revenue : m);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final entry in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      entry.revenue == 0 ? '' : '₹${entry.revenue}',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: c.t2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: maxRevenue == 0
                            ? 0
                            : entry.revenue / maxRevenue,
                      ),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, _) => Container(
                        height: (96 * t).clamp(3, 96),
                        decoration: BoxDecoration(
                          gradient: kIndigo.gradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weekdayLabel(entry.day),
                      style: TextStyle(fontSize: 9.5, color: c.t2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal proportion bar per status.
class StatusBreakdown extends StatelessWidget {
  final Map<String, int> counts;
  final int total;

  const StatusBreakdown({super.key, required this.counts, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        for (final status in kOrderStatuses)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              children: [
                SizedBox(
                  width: 104,
                  child: Text(
                    orderStatusLabel(status),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: c.t1,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: total == 0 ? 0 : (counts[status] ?? 0) / total,
                      ),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, _) => Stack(
                        children: [
                          Container(height: 9, color: c.surfaceSunk),
                          FractionallySizedBox(
                            widthFactor: t.clamp(0, 1),
                            child: Container(
                              height: 9,
                              decoration: BoxDecoration(
                                gradient: accentForStatus(status).gradient,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${counts[status] ?? 0}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.5,
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
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(height: 14),
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
            Icon(Icons.cloud_off, size: 34, color: kRose.start),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: c.t1, height: 1.45),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: kIndigo.start),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
