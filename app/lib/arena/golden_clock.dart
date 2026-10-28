import 'dart:math' as math;

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
    required this.fromLeft,
  }) : super(anchor: Anchor.center);

  final Vector2 arenaSize;
  final double dialTop;
  final double radius;
  final double life;
  final bool fromLeft;
  double _t = 0;

  /// Set when caught or expired: shrinks/fades out, then removes itself.
  double? _leaving;
  bool caught = false;

  final _glow = Paint();
  final _face = Paint()..color = const Color(0xFFFFFBEA);
  final _gold = Paint();
  final _ray = Paint();
  final _shine = Paint()
    ..color = const Color(0xCCFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _rim = Paint()
    ..color = Palette.outline
    ..style = PaintingStyle.stroke;
  final _hand = Paint()
    ..color = Palette.outline
    ..strokeCap = StrokeCap.round;

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
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.6));
    canvas.drawCircle(Offset.zero, r * 1.6, _glow);
    _drawRays(canvas, r);
    _drawClock(canvas, r);
    if (alpha < 1) canvas.restore();
    canvas.restore();
  }

  /// Slowly turning sun rays behind the clock.
  void _drawRays(Canvas canvas, double r) {
    canvas.save();
    canvas.rotate(_t * 0.8);
    _ray.shader ??= const RadialGradient(
      colors: [Color(0x99FFF3B0), Color(0x00FFF3B0)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.9));
    for (var i = 0; i < 8; i++) {
      canvas.drawPath(_rayPath(r), _ray);
      canvas.rotate(math.pi / 4);
    }
    canvas.restore();
  }

  Path? _rayCache;
  Path _rayPath(double r) => _rayCache ??= Path()
    ..moveTo(-r * 0.16, 0)
    ..lineTo(0, -r * 1.9)
    ..lineTo(r * 0.16, 0)
    ..close();

  /// The golden alarm clock in vector (docs/04 U-27): bells, a gold body,
  /// a white face and hands that spin while it flies.
  void _drawClock(Canvas canvas, double r) {
    final outline = r * 0.13;
    _rim.strokeWidth = outline;
    _gold.shader ??= const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFE066), Color(0xFFFFC300), Color(0xFFFF8F00)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    // Bells and the hammer.
    for (final side in [-1.0, 1.0]) {
      final c = Offset(side * r * 0.62, -r * 0.82);
      canvas.drawCircle(c, r * 0.3, _gold);
      canvas.drawCircle(c, r * 0.3, _rim);
    }
    // Legs.
    _hand.strokeWidth = outline;
    canvas.drawLine(
      Offset(-r * 0.55, r * 0.8),
      Offset(-r * 0.75, r * 1.05),
      _hand,
    );
    canvas.drawLine(
      Offset(r * 0.55, r * 0.8),
      Offset(r * 0.75, r * 1.05),
      _hand,
    );
    // Body and face.
    canvas.drawCircle(Offset.zero, r, _gold);
    canvas.drawCircle(Offset.zero, r, _rim);
    canvas.drawCircle(Offset.zero, r * 0.7, _face);
    _rim.strokeWidth = outline * 0.6;
    canvas.drawCircle(Offset.zero, r * 0.7, _rim);
    // Hands: the long one spins a turn a second, the short one slowly.
    _hand.strokeWidth = r * 0.11;
    final m = _t * math.pi * 2;
    final h = _t * math.pi * 0.4;
    canvas.drawLine(
      Offset.zero,
      Offset(math.sin(m), -math.cos(m)) * r * 0.55,
      _hand,
    );
    canvas.drawLine(
      Offset.zero,
      Offset(math.sin(h), -math.cos(h)) * r * 0.36,
      _hand,
    );
    canvas.drawCircle(Offset.zero, r * 0.09, _hand);
    // Shine.
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.84),
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      _shine..strokeWidth = r * 0.1,
    );
  }
}
