import 'package:flutter/material.dart';
import '../notifications.dart';
import '../theme.dart';

/// The customer's order-update feed. Mirrors what was pushed to their device,
/// and is the fallback whenever push isn't available or was declined.
void showNotificationsSheet(BuildContext context) {
  notificationCenter.refresh();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final c = sheetContext.c;
      return FractionallySizedBox(
        heightFactor: .8,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Text('🔔', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Order updates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: c.t0,
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: notificationCenter,
                      builder: (context, _) =>
                          notificationCenter.unreadCount == 0
                              ? const SizedBox.shrink()
                              : TextButton(
                                  onPressed: notificationCenter.markAllRead,
                                  child: const Text('Mark all read'),
                                ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Icon(Icons.close, color: c.t2),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: c.border),
              Expanded(
                child: ListenableBuilder(
                  listenable: notificationCenter,
                  builder: (context, _) {
                    final items = notificationCenter.items;
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔕',
                                  style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 12),
                              Text(
                                'No updates yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: c.t0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Once you place an order, every step from packing '
                                'to delivery shows up here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12.5, color: c.t2, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 9),
                      itemBuilder: (context, i) =>
                          _NotificationTile(item: items[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _NotificationTile extends StatelessWidget {
  final OrderNotification item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final emoji = switch (item.status) {
      'confirmed' => '✅',
      'packing' => '📦',
      'out_for_delivery' => '🛵',
      'delivered' => '🎉',
      'cancelled' => '⚠️',
      _ => '🔔',
    };

    final diff = DateTime.now().difference(item.createdAt);
    final when = diff.inMinutes < 1
        ? 'just now'
        : diff.inMinutes < 60
            ? '${diff.inMinutes}m ago'
            : diff.inHours < 24
                ? '${diff.inHours}h ago'
                : '${diff.inDays}d ago';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: item.read ? c.surface : c.primaryBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.read ? c.border : c.primary.withValues(alpha: .3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.t0,
                        ),
                      ),
                    ),
                    Text(
                      when,
                      style: TextStyle(fontSize: 10.5, color: c.t2),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 12, color: c.t1, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
