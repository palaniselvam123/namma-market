import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'catalog.dart';
import 'models.dart';
import 'supabase_config.dart';

/// The database is the source of truth for the catalog — the built-in
/// `kProducts` list is seeded into it and only acts as an offline fallback,
/// so the store console can genuinely edit and remove every product.
class CatalogStore extends ChangeNotifier {
  bool loadedFromServer = false;

  Future<void> loadRemoteProducts() async {
    try {
      final rows = await supabase.from('products').select().order('id');
      final products = (rows as List)
          .map((row) => productFromRow(row as Map<String, dynamic>))
          .toList();
      if (products.isEmpty) return; // Keep the built-in catalog as fallback.

      kProducts
        ..clear()
        ..addAll(products);
      loadedFromServer = true;
      notifyListeners();
    } catch (_) {
      // Offline or backend unreachable — app still works with the built-in
      // catalog compiled into the bundle.
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

    final product = productFromRow(row);
    addLocal(product);
    return product;
  }

  /// Saves edits to an existing product and refreshes it in the local list.
  Future<Product> updateRemoteProduct({
    required int id,
    required String name,
    required String brand,
    required String category,
    required String emoji,
    required String unit,
    required String packLabel,
    required int price,
    int? mrp,
    String? flag,
    Uint8List? newImageBytes,
  }) async {
    final patch = <String, dynamic>{
      'name': name,
      'brand': brand,
      'category': category,
      'emoji': emoji,
      'unit': unit,
      'pack_label': packLabel,
      'price': price,
      'mrp': mrp,
      if (flag != null) 'flag': flag,
    };

    if (newImageBytes != null) {
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.jpg';
      await supabase.storage
          .from('product-images')
          .uploadBinary(fileName, newImageBytes);
      patch['image_url'] =
          supabase.storage.from('product-images').getPublicUrl(fileName);
    }

    final row = await supabase
        .from('products')
        .update(patch)
        .eq('id', id)
        .select()
        .single();

    final updated = productFromRow(row);
    final index = kProducts.indexWhere((p) => p.id == id);
    if (index >= 0) {
      kProducts[index] = updated;
    } else {
      kProducts.add(updated);
    }
    notifyListeners();
    return updated;
  }

  Future<void> deleteRemoteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
    kProducts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Sends a photo to the analyze-product-photo edge function and returns
  /// every product the AI could identify in it, each with a normalized
  /// bounding box for cropping. A tight single-product photo comes back as
  /// a list of one; a wide shelf photo can come back as many. Throws on
  /// failure — callers should catch and fall back to a blank/manual form.
  Future<List<Map<String, dynamic>>> analyzeShelfPhoto(Uint8List imageBytes) async {
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
    final products = data['products'] as List<dynamic>? ?? [];
    return products.cast<Map<String, dynamic>>();
  }

  /// Crops [imageBytes] to [boundingBox] (fractional x/y/width/height, 0-1),
  /// with a small padding margin since AI-estimated boxes can run tight.
  /// Returns the original bytes unchanged if decoding or the box is bad.
  Uint8List cropToBoundingBox(Uint8List imageBytes, Map<String, dynamic> boundingBox) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return imageBytes;

    const pad = 0.03;
    var x = ((boundingBox['x'] as num).toDouble() - pad).clamp(0.0, 1.0);
    var y = ((boundingBox['y'] as num).toDouble() - pad).clamp(0.0, 1.0);
    final width = ((boundingBox['width'] as num).toDouble() + pad * 2).clamp(0.0, 1.0 - x);
    final height = ((boundingBox['height'] as num).toDouble() + pad * 2).clamp(0.0, 1.0 - y);

    final left = (x * decoded.width).round().clamp(0, decoded.width - 1);
    final top = (y * decoded.height).round().clamp(0, decoded.height - 1);
    final cropWidth = (width * decoded.width).round().clamp(1, decoded.width - left);
    final cropHeight = (height * decoded.height).round().clamp(1, decoded.height - top);

    final cropped = img.copyCrop(
      decoded,
      x: left,
      y: top,
      width: cropWidth,
      height: cropHeight,
    );
    return Uint8List.fromList(img.encodeJpg(cropped, quality: 85));
  }

  Product productFromRow(Map<String, dynamic> row) {
    final variantsJson = row['variants'] as List<dynamic>?;
    return Product(
      id: row['id'] as int,
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
      inStock: row['in_stock'] as bool? ?? true,
    );
  }

  /// Takes a product off sale (or puts it back) without deleting it.
  Future<void> setInStock(int id, bool inStock) async {
    final row = await supabase
        .from('products')
        .update({'in_stock': inStock})
        .eq('id', id)
        .select()
        .single();
    final updated = productFromRow(row);
    final index = kProducts.indexWhere((p) => p.id == id);
    if (index >= 0) kProducts[index] = updated;
    notifyListeners();
  }
}

final catalogStore = CatalogStore();
