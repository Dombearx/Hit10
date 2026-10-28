import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import 'baked.dart';

/// A label that bounces in (0 → 1.3 → 1), holds, then rises and fades
/// (docs/04 §3). Removes itself when done.
class PopText extends PositionComponent {
  PopText({
    required String text,
    required TextStyle style,
    required Vector2 at,
    this.life = 1.1,
    this.rise = 40,
    this.dropIn = false,
  }) : _painter = TextPainter(
         text: TextSpan(text: text, style: style),
         textDirection: TextDirection.ltr,
       )..layout(),
       super(position: at.clone(), anchor: Anchor.center);

  final TextPainter _painter;
  final double life;
  final double rise;

  /// Misses fall in from above instead of bouncing (docs/04 §3).
  final bool dropIn;

  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
    if (_t >= life) removeFromParent();
  }

  double get _scale {
    if (dropIn) return 1;
    const inT = 0.12, settleT = 0.22;
    if (_t < inT) return Curves.easeOut.transform(_t / inT) * 1.3;
    if (_t < settleT) return 1.3 - 0.3 * ((_t - inT) / (settleT - inT));
    return 1;
  }

  double get _alpha {
    final fadeStart = life * 0.65;
    if (_t < fadeStart) return 1;
    return (1 - (_t - fadeStart) / (life - fadeStart)).clamp(0.0, 1.0);
  }

  double get _dy {
    if (dropIn) {
      const fall = 0.25;
      if (_t < fall) {
        return -30 * (1 - Curves.bounceOut.transform(_t / fall));
      }
    }
    final fadeStart = life * 0.55;
    return _t < fadeStart ? 0 : -rise * (_t - fadeStart) / (life - fadeStart);
  }

  Baked? _baked;

  @override
  void onRemove() {
    _baked?.dispose();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final s = _scale;
    if (s <= 0.001) return;
    final baked = _baked ??= Baked(
      _painter.width + 8,
      _painter.height + 8,
      (c) => _painter.paint(c, const Offset(4, 4)),
    );
    canvas.save();
    canvas.translate(0, _dy);
    canvas.scale(s);
    baked.draw(canvas, _alpha);
    canvas.restore();
  }
}
