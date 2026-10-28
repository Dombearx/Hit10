import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../model/grading.dart';
import 'baked.dart';
import '../ui/theme.dart';

/// "Grandpa: 10.00! +12" bubble that floats up beside the dial
/// (docs/04 §3, "Trafienie generatora").
class GeneratorPopup extends PositionComponent {
  GeneratorPopup({
    required this.emoji,
    required String time,
    required String reward,
    required Tier tier,
    required Vector2 at,
    required double scale,
  }) : _scaleK = scale,
       _time = _painter(time, _tierColor(tier), 15 * scale),
       _reward = _painter(reward, Palette.outline, 13 * scale),
       super(position: at.clone(), anchor: Anchor.center);

  static const life = 1.6;
  final ui.Image? emoji;
  final double _scaleK;
  final TextPainter _time;
  final TextPainter _reward;
  double _t = 0;
  final _bg = Paint()..color = const Color(0xF2FFFFFF);
  final _border = Paint()
    ..color = Palette.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final _img = Paint()..filterQuality = FilterQuality.medium;

  static Color _tierColor(Tier t) => switch (t) {
    Tier.perfect => Palette.perfectDeep,
    Tier.great => Palette.great,
    Tier.good => Palette.good,
    Tier.miss => Palette.miss,
  };

  static TextPainter _painter(String s, Color c, double size) => TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(fontFamily: Fonts.display, fontSize: size, color: c),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void update(double dt) {
    _t += dt;
    position.y -= 26 * dt * _scaleK;
    if (_t >= life) removeFromParent();
  }

  Baked? _baked;

  @override
  void onRemove() {
    _baked?.dispose();
    super.onRemove();
  }

  Baked _bake() {
    final icon = 24 * _scaleK;
    final pad = 6 * _scaleK;
    final textW = _time.width > _reward.width ? _time.width : _reward.width;
    final w = pad * 3 + icon + textW;
    final h = pad * 2 + _time.height + _reward.height * 0.85;
    return Baked(w + 4, h + 4, (canvas) {
      canvas.translate(2, 2);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(h / 2),
      );
      canvas.drawRRect(r, _bg);
      canvas.drawRRect(r, _border);
      final img = emoji;
      if (img != null) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(pad, (h - icon) / 2, icon, icon),
          _img,
        );
      }
      final tx = pad * 2 + icon;
      _time.paint(canvas, Offset(tx, pad * 0.8));
      _reward.paint(canvas, Offset(tx, pad * 0.8 + _time.height * 0.9));
    });
  }

  @override
  void render(Canvas canvas) {
    final k = _t / life;
    final alpha = k < 0.1 ? k / 0.1 : (k > 0.7 ? (1 - k) / 0.3 : 1.0);
    final pop = k < 0.12 ? 0.7 + 0.3 * (k / 0.12) : 1.0;
    final baked = _baked ??= _bake();
    canvas.save();
    canvas.scale(pop);
    baked.draw(canvas, alpha);
    canvas.restore();
  }
}
