import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// Selector for different product pack sizes/variants (like 3L, 500ml, 250ml).
/// Shows a grid of variant options with price and discount information.
typedef OnVariantSelected = void Function(Variant variant);

class VariantSelector extends StatefulWidget {
  final List<Variant> variants;
  final Variant? initialVariant;
  final OnVariantSelected onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    this.initialVariant,
    required this.onVariantSelected,
  });

  @override
  State<VariantSelector> createState() => _VariantSelectorState();
}

class _VariantSelectorState extends State<VariantSelector> {
  late Variant _selectedVariant;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.initialVariant ?? widget.variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.variants.map((variant) {
        final isSelected = _selectedVariant.label == variant.label;
        final discountPct = variant.mrp == null
            ? 0
            : (((variant.mrp! - variant.price) / variant.mrp!) * 100).round();

        return GestureDetector(
          onTap: () {
            setState(() => _selectedVariant = variant);
            widget.onVariantSelected(variant);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? c.primaryBg : c.surface,
              border: Border.all(
                color: isSelected ? c.primary : c.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  variant.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? c.primary : c.t0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${variant.price}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: c.t0,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (variant.mrp != null && discountPct > 0) ...[
                      const SizedBox(width: 5),
                      Text(
                        '${discountPct}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
