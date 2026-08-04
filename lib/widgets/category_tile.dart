import 'package:flutter/material.dart';
import '../app_state.dart';
import '../catalog.dart';
import '../models.dart';
import '../theme.dart';

/// A category tile fronted by a real product photograph on a tint drawn from
/// the category's own accent — the emoji is only a fallback if the photo fails.
class CategoryTile extends StatelessWidget {
  final Category category;

  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final accent = category.gradient.last;
    final tint = Color.alphaBlend(accent.withValues(alpha: .15), c.surface);
    final hero = category.heroId == null ? null : productById(category.heroId!);
    final url = hero?.imageUrl(200);

    Widget fallback() => Center(
          child: Text(category.emoji, style: const TextStyle(fontSize: 26)),
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => appState.showCategory(category.key),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: .16)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // A brighter pool behind the pack lifts it off the tint.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, .25),
                        radius: .95,
                        colors: [
                          Colors.white.withValues(alpha: .55),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: url == null
                        ? fallback()
                        : Image.network(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, _, _) => fallback(),
                            loadingBuilder: (context, child, progress) =>
                                progress == null ? child : fallback(),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: c.t1,
            ),
          ),
        ],
      ),
    );
  }
}
