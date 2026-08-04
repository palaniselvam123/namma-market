import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
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
