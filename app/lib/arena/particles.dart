import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

enum ParticleShape { star, circle, spark }

/// A fixed pool of particles drawn in one component, so bursts never
/// allocate per frame (T-21).
class ParticleField extends Component {
  ParticleField({this.capacity = 400});

  final int capacity;
  final _rng = math.Random();
  late final List<_P> _pool = List.generate(capacity, (_) => _P());
  int _cursor = 0;

  /// Particles scale with this (fewer on "reduce motion", U-6).
  double density = 1;

  final Paint _paint = Paint();
  late final Path _star = _starPath();

  static Path _starPath() {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? 1.0 : 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = math.cos(a) * r;
      final y = math.sin(a) * r;
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    return p..close();
  }

  /// Radial burst from [origin].
  void burst({
    required Vector2 origin,
    required int count,
    required List<Color> colors,
    double speedMin = 180,
    double speedMax = 520,
    double sizeMin = 4,
    double sizeMax = 11,
    double life = 0.9,
    double gravity = 520,
    ParticleShape shape = ParticleShape.star,
  }) {
    final n = (count * density).round();
    for (var i = 0; i < n; i++) {
      final p = _pool[_cursor];
      _cursor = (_cursor + 1) % capacity;
      final a = _rng.nextDouble() * math.pi * 2;
      final s = speedMin + _rng.nextDouble() * (speedMax - speedMin);
      p
        ..x = origin.x
        ..y = origin.y
        ..vx = math.cos(a) * s
        ..vy = math.sin(a) * s - 120
        ..size = sizeMin + _rng.nextDouble() * (sizeMax - sizeMin)
        ..life = life * (0.6 + _rng.nextDouble() * 0.4)
        ..maxLife = p.life
        ..spin = (_rng.nextDouble() - 0.5) * 10
        ..angle = _rng.nextDouble() * math.pi
        ..gravity = gravity
        ..color = colors[_rng.nextInt(colors.length)]
        ..shape = shape;
    }
  }

  @override
  void update(double dt) {
    for (final p in _pool) {
      if (p.life <= 0) continue;
      p.life -= dt;
      p.vy += p.gravity * dt;
      final drag = math.pow(0.18, dt).toDouble();
      p.vx *= drag;
      p.vy *= drag;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.angle += p.spin * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _pool) {
      if (p.life <= 0) continue;
      final k = (p.life / p.maxLife).clamp(0.0, 1.0);
      _paint.color = p.color.withValues(alpha: k);
      final size = p.size * (0.5 + 0.5 * k);
      switch (p.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(Offset(p.x, p.y), size, _paint);
        case ParticleShape.spark:
          _paint.strokeWidth = size * 0.5;
          canvas.drawLine(
            Offset(p.x, p.y),
            Offset(p.x - p.vx * 0.03, p.y - p.vy * 0.03),
            _paint,
          );
        case ParticleShape.star:
          canvas
            ..save()
            ..translate(p.x, p.y)
            ..rotate(p.angle)
            ..scale(size)
            ..drawPath(_star, _paint)
            ..restore();
      }
    }
  }
}

class _P {
  double x = 0, y = 0, vx = 0, vy = 0;
  double size = 0, life = 0, maxLife = 1, spin = 0, angle = 0, gravity = 0;
  Color color = const Color(0xFFFFFFFF);
  ParticleShape shape = ParticleShape.star;
}
