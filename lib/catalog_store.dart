import 'dart:convert';
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

  /// Uploads [imageBytes] (if any) to storage, inserts the product row, and
  /// merges the result into the local catalog. Shared by the single-add form
  /// and the bulk AI-assisted flow.
  Future<Product> createRemoteProduct({
    required String name,
    required String brand,
    required String category,
    required String emoji,
    required String unit,
    required String packLabel,
    required int price,
    int? mrp,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.jpg';
      await supabase.storage.from('product-images').uploadBinary(fileName, imageBytes);
      imageUrl = supabase.storage.from('product-images').getPublicUrl(fileName);
    }

    final row = await supabase
        .from('products')
        .insert({
          'name': name,
          'brand': brand,
          'category': category,
          'emoji': emoji,
          'unit': unit,
          'pack_label': packLabel,
          'price': price,
          'mrp': mrp,
          'image_url': imageUrl,
        })
        .select()
        .single();

    final product = Product(
      id: _remoteIdOffset + (row['id'] as int),
      name: name,
      brand: brand,
      category: category,
      emoji: emoji,
      unit: unit,
      packLabel: packLabel,
      price: price,
      mrp: mrp,
      image: imageUrl,
    );
    addLocal(product);
    return product;
  }

  /// Sends a product photo to the analyze-product-photo edge function and
  /// returns the AI's best-guess field extraction. Throws on failure —
  /// callers should catch and fall back to a blank/manual form.
  Future<Map<String, dynamic>> analyzePhoto(Uint8List imageBytes) async {
    final response = await supabase.functions.invoke(
      'analyze-product-photo',
      body: {
        'image': base64Encode(imageBytes),
        'mediaType': 'image/jpeg',
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception(data['error']);
    }
    return data;
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
