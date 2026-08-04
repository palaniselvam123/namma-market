import 'package:flutter/foundation.dart';
import 'catalog.dart';
import 'models.dart';
import 'supabase_config.dart';

/// Local product ids are hand-assigned (1-94). Remote (admin-added) products
/// get ids offset well past that range so the two id spaces never collide.
const _remoteIdOffset = 100000;

/// Loads admin-added products from Supabase into [kProducts] on startup,
/// and notifies listeners so already-built screens can refresh.
class CatalogStore extends ChangeNotifier {
  Future<void> loadRemoteProducts() async {
    try {
      final rows = await supabase
          .from('products')
          .select()
          .order('created_at');
      final existingIds = kProducts.map((p) => p.id).toSet();
      for (final row in rows as List) {
        final product = _productFromRow(row as Map<String, dynamic>);
        if (!existingIds.contains(product.id)) {
          kProducts.add(product);
        }
      }
      notifyListeners();
    } catch (_) {
      // Offline or backend unreachable — app still works with local catalog.
    }
  }

  void addLocal(Product product) {
    kProducts.add(product);
    notifyListeners();
  }

  Product _productFromRow(Map<String, dynamic> row) {
    final variantsJson = row['variants'] as List<dynamic>?;
    return Product(
      id: _remoteIdOffset + (row['id'] as int),
      name: row['name'] as String,
      brand: row['brand'] as String,
      category: row['category'] as String,
      emoji: row['emoji'] as String,
      unit: row['unit'] as String,
      packLabel: row['pack_label'] as String,
      price: row['price'] as int,
      mrp: row['mrp'] as int?,
      image: row['image_url'] as String?,
      images: (row['images'] as List<dynamic>?)?.cast<String>(),
      variants: variantsJson
          ?.map((v) => Variant(
                v['label'] as String,
                v['price'] as int,
                mrp: v['mrp'] as int?,
              ))
          .toList(),
      flag: Flag.values.firstWhere(
        (f) => f.name == row['flag'],
        orElse: () => Flag.none,
      ),
    );
  }
}

final catalogStore = CatalogStore();
