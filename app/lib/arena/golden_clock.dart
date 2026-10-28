import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../ui/theme.dart';

/// The flying golden clock (R-ZLOTA-1): crosses the top of the arena in a
/// lazy wave for [life] seconds, glowing, trailing sparkles.
class GoldenClock extends PositionComponent {
  GoldenClock({
    required this.arenaSize,
    required this.dialTop,
    required this.radius,
    required this.life,
    required this.image,
    required this.fromLeft,
  }) : super(anchor: Anchor.center);

  final Vector2 arenaSize;
  final double dialTop;
  final double radius;
  final double life;
  final ui.Image? image;
  final bool fromLeft;
  double _t = 0;

  /// Set when caught or expired: shrinks/fades out, then removes itself.
  double? _leaving;
  bool caught = false;

  final _glow = Paint();
  final _face = Paint()..color = Palette.perfect;
  final _rim = Paint()
    ..color = Palette.outline
    ..style = PaintingStyle.stroke;
  final _hand = Paint()
    ..color = Palette.outline
    ..strokeCap = StrokeCap.round;
  final _img = Paint()..filterQuality = FilterQuality.medium;

  double get size2 => radius;

  static const _tileRow = 44.0;
  static const _wave = 0.15;

  /// Where the clock is [t] seconds into its flight.
  Vector2 at(double t) {
    final k = (t / life).clamp(0.0, 1.0);
    final x0 = -radius, x1 = arenaSize.x + radius;
    final x = fromLeft ? x0 + (x1 - x0) * k : x1 - (x1 - x0) * k;
    // The wave's crests must clear the ad tiles in the arena's top corners
    // (game_screen.dart): they swallow taps, so a clock behind them can't
    // be caught.
    final band = math.max(
      (_tileRow + radius * 0.8) / (1 - _wave),
      dialTop * 0.55,
    );
    final y = band + math.sin(k * math.pi * 3) * band * _wave;
    return Vector2(x, y);
  }

  bool hits(Vector2 p) =>
      _leaving == null && p.distanceTo(position) < radius * 1.6;

  void leave({required bool caught}) {
    this.caught = caught;
    _leaving ??= 0;
  }

  @override
  void update(double dt) {
    _t += dt;
    if (_leaving != null) {
      _leaving = _leaving! + dt;
      if (_leaving! > 0.35) removeFromParent();
      return;
    }
    position = at(_t);
  }

  @override
  void render(Canvas canvas) {
    var scale = 1 + 0.06 * math.sin(_t * 8);
    var alpha = 1.0;
    final leaving = _leaving;
    if (leaving != null) {
      final k = leaving / 0.35;
      scale *= caught ? 1 + k : 1 - k;
      alpha = 1 - k;
    }
    canvas.save();
    canvas.scale(scale);
    canvas.rotate(math.sin(_t * 3) * 0.2);
    if (alpha < 1) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    }
    final r = radius;
    _glow.shader ??= const RadialGradient(
      colors: [Color(0xAAFFD54A), Color(0x00FFD54A)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.5));
    canvas.drawCircle(Offset.zero, r * 1.5, _glow);
    final img = image;
    if (img != null) {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromCircle(center: Offset.zero, radius: r * 1.1),
        _img
          ..colorFilter = const ColorFilter.mode(
            Color(0x66FFC300),
            BlendMode.srcATop,
          ),
      );
    } else {
      canvas.drawCircle(Offset.zero, r, _face);
      _rim.strokeWidth = r * 0.12;
      canvas.drawCircle(Offset.zero, r, _rim);
      _hand.strokeWidth = r * 0.1;
      canvas.drawLine(Offset.zero, Offset(0, -r * 0.6), _hand);
      canvas.drawLine(Offset.zero, Offset(r * 0.4, 0), _hand);
    }
    if (alpha < 1) canvas.restore();
    canvas.restore();
  }
}
