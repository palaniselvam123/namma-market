import 'package:flutter/foundation.dart';
import 'auth.dart';
import 'models/order.dart';
import 'supabase_config.dart';

class Address {
  final int id;
  final String label; // Home / Work / Other
  final String recipientName;
  final String phone;
  final String line1;
  final String? line2;
  final String area;
  final String? pincode;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.line1,
    this.line2,
    required this.area,
    this.pincode,
    required this.isDefault,
  });

  factory Address.fromRow(Map<String, dynamic> row) => Address(
        id: row['id'] as int,
        label: row['label'] as String? ?? 'Home',
        recipientName: row['recipient_name'] as String? ?? '',
        phone: row['phone'] as String? ?? '',
        line1: row['line1'] as String,
        line2: row['line2'] as String?,
        area: row['area'] as String,
        pincode: row['pincode'] as String?,
        isDefault: row['is_default'] as bool? ?? false,
      );

  /// One-line form used on the order and shown to the shop.
  String get formatted => [
        line1,
        if (line2 != null && line2!.trim().isNotEmpty) line2!.trim(),
        area,
        if (pincode != null && pincode!.trim().isNotEmpty)
          'Chennai ${pincode!.trim()}'
        else
          'Chennai',
      ].join(', ');

  DeliveryLocation get location => kDeliveryLocations.firstWhere(
        (l) => l.name == area,
        orElse: () => DeliveryLocation(area, '📍', 20),
      );
}

/// Saved delivery addresses for the signed-in shopper.
class AddressStore extends ChangeNotifier {
  final List<Address> _addresses = [];
  int? _selectedId;
  bool _loading = false;

  List<Address> get addresses => List.unmodifiable(_addresses);
  bool get loading => _loading;

  Address? get selected {
    if (_addresses.isEmpty) return null;
    for (final a in _addresses) {
      if (a.id == _selectedId) return a;
    }
    for (final a in _addresses) {
      if (a.isDefault) return a;
    }
    return _addresses.first;
  }

  void select(int id) {
    _selectedId = id;
    notifyListeners();
  }

  void clear() {
    _addresses.clear();
    _selectedId = null;
    notifyListeners();
  }

  Future<void> load() async {
    if (!auth.isSignedIn) return;
    _loading = true;
    notifyListeners();
    try {
      final rows = await supabase
          .from('addresses')
          .select()
          .order('is_default', ascending: false)
          .order('created_at');
      _addresses
        ..clear()
        ..addAll((rows as List)
            .map((r) => Address.fromRow(r as Map<String, dynamic>)));
    } catch (_) {
      // Keep whatever we already had.
    }
    _loading = false;
    notifyListeners();
  }

  Future<Address> save({
    int? id,
    required String label,
    required String recipientName,
    required String phone,
    required String line1,
    String? line2,
    required String area,
    String? pincode,
    required bool makeDefault,
  }) async {
    final userId = auth.userId;
    if (userId == null) throw Exception('Sign in to save an address');

    final payload = {
      'user_id': userId,
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'area': area,
      'pincode': pincode,
      'is_default': makeDefault,
    };

    final row = id == null
        ? await supabase.from('addresses').insert(payload).select().single()
        : await supabase
            .from('addresses')
            .update(payload)
            .eq('id', id)
            .select()
            .single();

    final saved = Address.fromRow(row);

    // Only one address can be the default.
    if (makeDefault) {
      await supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId)
          .neq('id', saved.id);
    }

    await load();
    _selectedId = saved.id;
    notifyListeners();
    return saved;
  }

  Future<void> remove(int id) async {
    await supabase.from('addresses').delete().eq('id', id);
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedId == id) _selectedId = null;
    notifyListeners();
  }

  Future<void> makeDefault(int id) async {
    final userId = auth.userId;
    if (userId == null) return;
    await supabase
        .from('addresses')
        .update({'is_default': false}).eq('user_id', userId);
    await supabase.from('addresses').update({'is_default': true}).eq('id', id);
    await load();
  }
}

final addressStore = AddressStore();
