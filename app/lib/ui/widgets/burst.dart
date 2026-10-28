import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Coins for purchases and rewards (docs/04 §3, U-25).
const coinColors = [Palette.perfect, Color(0xFFFFE066), Palette.perfectDeep];

/// Confetti for achievements.
const confettiColors = [
  Palette.accent,
  Palette.great,
  Palette.good,
  Palette.perfect,
  Palette.neonMagenta,
];

/// Shards for a broken combo.
const shardColors = [Palette.accent, Palette.outline, Color(0xFFFF8FB1)];

/// A one-shot particle burst over everything at [context]'s widget centre
/// (or [at], in global coordinates). Purely decorative: ignores touches and
/// removes itself. [reduceMotion] keeps a third of the particles (U-6).
void showBurst(
  BuildContext? context, {
  OverlayState? overlay,
  Offset? at,
  List<Color> colors = coinColors,
  int count = 14,
  double spread = 1,
  bool reduceMotion = false,
  bool fall = false,
}) {
  overlay ??= context == null
      ? null
      : Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  var origin = at;
  if (origin == null) {
    final box = context?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    origin = box.localToGlobal(box.size.center(Offset.zero));
  }
  final n = reduceMotion ? (count / 3).ceil() : count;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: _Burst(
        origin: origin!,
        colors: colors,
        count: n,
        spread: spread,
        fall: fall,
        onDone: () => entry.remove(),
      ),
    ),
  );
  overlay.insert(entry);
}

/// Where a widget sits on screen, captured before it may disappear.
Offset? centerOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(box.size.center(Offset.zero));
}

class _Burst extends StatefulWidget {
  const _Burst({
    required this.origin,
    required this.colors,
    required this.count,
    required this.spread,
    required this.fall,
    required this.onDone,
  });
  final Offset origin;
  final List<Color> colors;
  final int count;
  final double spread;
  final bool fall;
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _Bit {
  _Bit(this.v, this.size, this.color, this.spin);
  final Offset v;
  final double size;
  final Color color;
  final double spin;
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.fall ? 1400 : 750),
  )..forward().whenComplete(widget.onDone);

  late final List<_Bit> _bits = () {
    final rng = math.Random();
    return List.generate(widget.count, (_) {
      final angle = widget.fall
          ? math.pi *
                (0.15 + rng.nextDouble() * 0.7) // downward fan
          : rng.nextDouble() * math.pi * 2;
      final speed = (140 + rng.nextDouble() * 220) * widget.spread;
      return _Bit(
        Offset(math.cos(angle), math.sin(angle)) * speed,
        4 + rng.nextDouble() * 5,
        widget.colors[rng.nextInt(widget.colors.length)],
        (rng.nextDouble() - 0.5) * 12,
      );
    });
  }();

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _BurstPainter(widget.origin, _bits, _a.value, widget.fall),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.origin, this.bits, this.k, this.fall);
  final Offset origin;
  final List<_Bit> bits;
  final double k;
  final bool fall;
  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final secs = k * (fall ? 1.4 : 0.75);
    final gravity = fall ? 260.0 : 520.0;
    final alpha = (1 - k * k).clamp(0.0, 1.0);
    for (final b in bits) {
      final p =
          origin +
          b.v * secs * (1 - 0.35 * k) +
          Offset(0, 0.5 * gravity * secs * secs);
      _paint.color = b.color.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(b.spin * secs);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: b.size,
            height: b.size * (fall ? 0.5 : 1),
          ),
          Radius.circular(b.size * 0.3),
        ),
        _paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.k != k;
}
