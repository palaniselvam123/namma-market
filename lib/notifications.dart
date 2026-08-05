import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'supabase_config.dart';

/// Public half of the VAPID pair. Safe to ship in the client — the private
/// half lives only in the send-order-notification edge function.
const kVapidPublicKey =
    'BJm5-gtzwDmtG6-A_B_wF8rrBtyAqMEdmvTfo2jWadbOqZeMW6yFC4AsF8stS_7gowA1JzCy-lcz9aIcJGU1ZDE';

@JS('nammaPush.subscribe')
external JSPromise<JSString> _jsSubscribe(JSString vapidPublicKey);

@JS('nammaPush.status')
external JSString _jsStatus();

class OrderNotification {
  final int id;
  final String orderCode;
  final String title;
  final String body;
  final String? status;
  final bool read;
  final DateTime createdAt;

  const OrderNotification({
    required this.id,
    required this.orderCode,
    required this.title,
    required this.body,
    this.status,
    required this.read,
    required this.createdAt,
  });

  factory OrderNotification.fromRow(Map<String, dynamic> row) =>
      OrderNotification(
        id: row['id'] as int,
        orderCode: row['order_code'] as String,
        title: row['title'] as String,
        body: row['body'] as String,
        status: row['status'] as String?,
        read: row['read'] as bool? ?? false,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );
}

/// Owns the customer's order-update feed: Web Push registration for messages
/// that arrive while the app is closed, and a Realtime subscription so an
/// open app updates the moment the shop changes a status.
class NotificationCenter extends ChangeNotifier {
  final List<OrderNotification> _items = [];
  String _phone = '';
  bool _listening = false;

  List<OrderNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  /// 'unsupported' | 'default' | 'granted' | 'denied'
  String get permissionStatus {
    if (!kIsWeb) return 'unsupported';
    try {
      return _jsStatus().toDart;
    } catch (_) {
      return 'unsupported';
    }
  }

  /// Called once the customer has a phone number (i.e. at checkout). Starts
  /// the live feed and loads anything they missed.
  Future<void> attachToPhone(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty || trimmed == _phone) return;
    _phone = trimmed;
    await refresh();
    _listenForUpdates();
  }

  Future<void> refresh() async {
    if (_phone.isEmpty) return;
    try {
      final rows = await supabase
          .from('order_notifications')
          .select()
          .eq('customer_phone', _phone)
          .order('created_at', ascending: false)
          .limit(50);
      _items
        ..clear()
        ..addAll((rows as List)
            .map((r) => OrderNotification.fromRow(r as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Leave whatever is already in the list.
    }
  }

  void _listenForUpdates() {
    if (_listening || _phone.isEmpty) return;
    _listening = true;
    try {
      supabase
          .channel('order_updates_$_phone')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'order_notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'customer_phone',
              value: _phone,
            ),
            callback: (payload) {
              _items.insert(0, OrderNotification.fromRow(payload.newRecord));
              notifyListeners();
            },
          )
          .subscribe();
    } catch (_) {
      _listening = false;
    }
  }

  Future<void> markAllRead() async {
    if (_phone.isEmpty || unreadCount == 0) return;
    final unreadIds = _items.where((n) => !n.read).map((n) => n.id).toList();
    for (var i = 0; i < _items.length; i++) {
      final n = _items[i];
      if (!n.read) {
        _items[i] = OrderNotification(
          id: n.id,
          orderCode: n.orderCode,
          title: n.title,
          body: n.body,
          status: n.status,
          read: true,
          createdAt: n.createdAt,
        );
      }
    }
    notifyListeners();
    try {
      await supabase
          .from('order_notifications')
          .update({'read': true}).inFilter('id', unreadIds);
    } catch (_) {
      // Local state already reflects it; the next refresh will reconcile.
    }
  }

  /// Asks for notification permission and stores the push endpoint against
  /// this customer's phone. Returns true when a subscription was saved.
  Future<bool> enablePush(String phone) async {
    if (!kIsWeb || phone.trim().isEmpty) return false;
    try {
      final raw = (await _jsSubscribe(kVapidPublicKey.toJS).toDart).toDart;
      if (raw.isEmpty) return false;

      final sub = jsonDecode(raw) as Map<String, dynamic>;
      final keys = sub['keys'] as Map<String, dynamic>?;
      if (keys == null) return false;

      await supabase.from('push_subscriptions').upsert({
        'customer_phone': phone.trim(),
        'endpoint': sub['endpoint'],
        'p256dh': keys['p256dh'],
        'auth': keys['auth'],
      }, onConflict: 'endpoint');
      return true;
    } catch (_) {
      return false;
    }
  }
}

final notificationCenter = NotificationCenter();
