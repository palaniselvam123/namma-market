import 'package:flutter/material.dart';

const _cdn = 'https://www.bbassets.com/media/uploads/p/l/';

enum Flag { none, bestseller, sale, isNew }

class Variant {
  final String label; // e.g., "3 L", "500 ml", "250 ml"
  final int price;
  final int? mrp;

  const Variant(this.label, this.price, {this.mrp});
}

class Product {
  final int id;
  final String name;
  final String brand;
  final String category;
  final String emoji;
  final String unit;
  final String packLabel;
  final int price;
  final int? mrp;
  final String? image;
  final List<String>? images; // Multiple views: [front, back, side, ...]
  final List<Variant>? variants; // Multiple pack sizes: [3L ₹392, 500ml ₹149, ...]
  final Flag flag;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.emoji,
    required this.unit,
    required this.packLabel,
    required this.price,
    this.mrp,
    this.image,
    this.images,
    this.variants,
    this.flag = Flag.none,
  });

  /// Real product photography, resized at the CDN edge.
  String? imageUrl([int width = 400]) =>
      image == null ? null : '$_cdn$image?tr=w-$width,q-80';

  /// Get specific view image URL by index (0=front, 1=back, 2=side, etc.)
  String? viewImageUrl(int viewIndex, [int width = 400]) =>
      images == null || viewIndex >= images!.length
          ? null
          : '${_cdn}${images![viewIndex]}?tr=w-$width,q-80';

  int get discountPct =>
      mrp == null ? 0 : (((mrp! - price) / mrp!) * 100).round();
}

class Category {
  final String key;
  final String label;
  final String emoji;
  final List<Color> gradient;

  /// Product whose photograph fronts this category's tile.
  final int? heroId;

  const Category(this.key, this.label, this.emoji, this.gradient, {this.heroId});
}

class Section {
  final String category;
  final String title;

  const Section(this.category, this.title);
}

/// Fallback packaging treatment for products with no photograph —
/// brand-accurate gradients so the shelf still reads as branded goods.
class BrandStyle {
  final List<Color> gradient;
  final Color brandColor;
  final Color labelColor;

  const BrandStyle(this.gradient, this.brandColor, this.labelColor);
}
