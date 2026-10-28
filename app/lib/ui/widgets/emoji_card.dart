import 'package:flutter/material.dart';

import '../catalog.dart';
import '../theme.dart';

/// Card built in code from Fluent Emoji 3D (docs/04 U-10): rounded pastel
/// square, dark outline, glossy top band, soft shadow, main emoji at 68%
/// and an optional corner emoji in a white bubble.
class EmojiCard extends StatelessWidget {
  const EmojiCard({
    super.key,
    required this.art,
    this.size = 56,
    this.locked = false,
    this.badge,
    this.circle = false,
  });

  final EmojiArt art;
  final double size;

  /// Shown as a dark silhouette with "?" (R-GEN-4).
  final bool locked;

  /// Small label in the top-right corner (upgrade level "III").
  final String? badge;

  /// Round badge shape (achievements).
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final radius = circle ? size / 2 : size * 0.2;
    final border = (size * 0.045).clamp(1.5, 6.0);
    Widget emoji(String name, double s) => Image.asset(
      EmojiArt.path(name),
      width: s,
      height: s,
      filterQuality: FilterQuality.medium,
    );
    final main = emoji(art.main, size * 0.68);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: locked ? const Color(0xFFCFC6B8) : art.background,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: Palette.outline, width: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    offset: Offset(0, size * 0.06),
                  ),
                ],
              ),
            ),
          ),
          // Gloss: translucent white band over the top 40%.
          Positioned(
            left: border + size * 0.06,
            right: border + size * 0.06,
            top: border + size * 0.04,
            height: size * 0.36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(radius * 0.8),
              ),
            ),
          ),
          Center(
            child: locked
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF6E6658),
                      BlendMode.srcIn,
                    ),
                    child: main,
                  )
                : main,
          ),
          if (locked)
            Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: size * 0.42,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Palette.outline, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          if (art.corner != null && !locked)
            Positioned(
              right: -size * 0.08,
              bottom: -size * 0.08,
              child: Container(
                width: size * 0.42,
                height: size * 0.42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Palette.outline,
                    width: border * 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: emoji(art.corner!, size * 0.3),
              ),
            ),
          if (badge != null)
            Positioned(
              right: -size * 0.1,
              top: -size * 0.1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size * 0.07),
                decoration: BoxDecoration(
                  color: Palette.accent,
                  borderRadius: BorderRadius.circular(size),
                  border: Border.all(color: Palette.outline, width: 1.5),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: size * 0.22,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
