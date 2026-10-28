import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../engine/round_engine.dart';
import '../model/grading.dart';
import '../model/number_format.dart';
import '../model/showcase.dart';
import '../ui/game_controller.dart';
import '../ui/theme.dart';
import '../ui/catalog.dart';
import 'generator_popup.dart';
import 'particles.dart';
import 'pop_text.dart';

/// Localised strings the arena draws (it has no BuildContext).
class ArenaLabels {
  const ArenaLabels({
    required this.perfect,
    required this.great,
    required this.good,
    required this.early,
    required this.late,
    required this.tapToStart,
    required this.decimalSeparator,
  });
  final String perfect;
  final String great;
  final String good;
  final String early;
  final String late;
  final String tapToStart;
  final String decimalSeparator;
}

/// The stopwatch arena (docs/04 §1, §3). Pure drawing: all game decisions
/// happen in [GameController]; this only reads it and reacts to feedback.
class ArenaGame extends FlameGame {
  ArenaGame(this.controller, this.labels);

  final GameController controller;
  ArenaLabels labels;

  late final Stage stage;
  StreamSubscription<HitFeedback>? _sub;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/';
    for (final art in generatorArt.values) {
      try {
        _emoji[art.main] = await images.load('emoji/${art.main}.png');
      } on Object {
        // A missing emoji just leaves the bubble without an icon.
      }
    }
    stage = Stage(this);
    await add(stage);
    _sub = controller.feedback.listen(stage.onFeedback);
  }

  final Map<String, ui.Image> _emoji = {};
  final _rng = math.Random();
  bool _popupLeft = true;

  @override
  void update(double dt) {
    controller.tick();
    controller.showcase.maxPerSecond =
        controller.balance.ui.generatorPopupsPerSecond;
    for (final hit in controller.showcase.update(dt, controller.econ)) {
      _spawnPopup(hit);
    }
    super.update(dt);
  }

  void _spawnPopup(ShowcaseHit hit) {
    final c = stage.center;
    final r = stage.radius;
    _popupLeft = !_popupLeft;
    final scale = (r / 150).clamp(0.8, 1.4);
    // Keep the whole bubble on screen (about 100 px wide at scale 1).
    final half = 52 * scale;
    final x = (_popupLeft ? c.x - r * 0.95 : c.x + r * 0.95).clamp(
      half + 4,
      size.x - half - 4,
    );
    // Spawn low on the dial: bubbles float up ~0.27 r and must never cover
    // the digits (U-7), whose lower edge is at about c.y + 0.22 r.
    final y = c.y + r * (0.55 + 0.35 * _rng.nextDouble());
    stage.add(
      GeneratorPopup(
        emoji: _emoji[generatorArt[hit.generator]?.main],
        time: formatStopwatch(hit.gameTime),
        reward: hit.tier == Tier.miss
            ? '—'
            : '+${formatNumber(hit.reward, decimalSeparator: labels.decimalSeparator)}',
        tier: hit.tier,
        at: Vector2(x, y),
        scale: scale,
      ),
    );
  }

  @override
  void onRemove() {
    _sub?.cancel();
    super.onRemove();
  }
}

/// Everything inside the arena, shaken as one (docs/04 §3).
class Stage extends Component {
  Stage(this.game);

  final ArenaGame game;
  late final Dial dial = Dial(this);
  final ParticleField particles = ParticleField();
  final _rng = math.Random();

  double _shake = 0; // remaining seconds
  double _shakeAmp = 0;
  double _shakeDur = 1;
  double _wobble = 0; // miss: horizontal dial wobble, seconds remaining

  Vector2 get size => game.size;
  Vector2 get center => Vector2(size.x / 2, size.y * 0.5);
  double get radius => math.min(size.x * 0.40, size.y * 0.42);

  @override
  Future<void> onLoad() async {
    await addAll([dial, particles]);
  }

  void shake(double amplitude, double seconds) {
    _shakeAmp = amplitude;
    _shake = seconds;
    _shakeDur = seconds;
  }

  double get wobbleOffset =>
      _wobble <= 0 ? 0 : math.sin(_wobble * 60) * 10 * (_wobble / 0.35);

  @override
  void update(double dt) {
    if (_shake > 0) _shake = math.max(0, _shake - dt);
    if (_wobble > 0) _wobble = math.max(0, _wobble - dt);
  }

  @override
  void renderTree(Canvas canvas) {
    if (_shake > 0) {
      final k = _shake / _shakeDur;
      canvas.save();
      canvas.translate(
        (_rng.nextDouble() * 2 - 1) * _shakeAmp * k,
        (_rng.nextDouble() * 2 - 1) * _shakeAmp * k,
      );
      super.renderTree(canvas);
      canvas.restore();
    } else {
      super.renderTree(canvas);
    }
  }

  void onFeedback(HitFeedback f) {
    final c = center;
    final r = radius;
    final l = game.labels;
    final g = f.grade;
    dial.flash(g.tier);
    TextStyle label(Color color, double size) => TextStyle(
      fontFamily: Fonts.display,
      fontSize: size,
      color: color,
      shadows: const [Shadow(color: Palette.outline, offset: Offset(0, 3))],
    );
    final labelAt = Vector2(c.x, c.y - r * 0.52);
    switch (g.tier) {
      case Tier.perfect:
        particles
          ..burst(
            origin: c,
            count: 60,
            colors: const [
              Palette.perfect,
              Palette.perfectDeep,
              Color(0xFFFFF3B0),
            ],
            speedMin: 350,
            speedMax: 1100,
            sizeMin: 6,
            sizeMax: 15,
            life: 1.1,
          )
          ..burst(
            origin: c,
            count: 30,
            colors: const [Color(0xFFFFFFFF), Palette.perfect],
            speedMin: 500,
            speedMax: 1300,
            sizeMin: 2,
            sizeMax: 4,
            life: 0.5,
            gravity: 0,
            shape: ParticleShape.spark,
          );
        add(Shockwave(center: c, from: r, to: r * 1.9, color: Palette.perfect));
        shake(8, 0.25);
        add(
          PopText(
            text: l.perfect,
            style: label(Palette.perfect, r * 0.24),
            at: labelAt,
            life: 0.85,
          ),
        );
      case Tier.great:
        particles.burst(
          origin: c,
          count: 25,
          colors: const [Palette.great, Color(0xFFB8F2EC)],
          speedMin: 250,
          speedMax: 750,
          sizeMin: 5,
          sizeMax: 11,
        );
        add(Shockwave(center: c, from: r, to: r * 1.5, color: Palette.great));
        shake(4, 0.18);
        add(
          PopText(
            text: l.great,
            style: label(Palette.great, r * 0.22),
            at: labelAt,
            life: 0.85,
          ),
        );
      case Tier.good:
        particles.burst(
          origin: c,
          count: 8,
          colors: const [Palette.good],
          speedMin: 200,
          speedMax: 450,
          shape: ParticleShape.circle,
          sizeMax: 7,
        );
        add(
          PopText(
            text: l.good,
            style: label(Palette.good, r * 0.2),
            at: labelAt,
            life: 0.85,
          ),
        );
      case Tier.miss:
        _wobble = 0.35;
        final text = g.missKind == MissKind.early ? l.early : l.late;
        add(
          PopText(
            text: text,
            style: label(Palette.missText, r * 0.17),
            at: labelAt,
            dropIn: true,
            life: 0.85,
          ),
        );
    }
    if (f.reward > 0) {
      add(
        PopText(
          text:
              '+${formatNumber(f.reward, decimalSeparator: l.decimalSeparator)}',
          style: label(Palette.dial, r * 0.2),
          // Flies up towards the balance counter (docs/04 §3).
          at: Vector2(c.x, c.y - r * 1.15),
          rise: r * 0.9,
          life: 0.8,
        ),
      );
    }
  }
}

/// The stopwatch face: ring, progress arc, ticks and fixed-width digits.
class Dial extends Component {
  Dial(this.stage);

  final Stage stage;
  double _flash = 0;
  Color _flashColor = Palette.perfect;
  double _time = 0; // for idle pulsing

  final _fill = Paint()..color = Palette.dial;
  final _outline = Paint()
    ..color = Palette.outline
    ..style = PaintingStyle.stroke;
  final _track = Paint()
    ..color = const Color(0xFFEDE6DA)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _arc = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _tick = Paint()
    ..color = Palette.outline
    ..strokeCap = StrokeCap.round;
  // Hard cartoon shadow; a blur filter is costly to redraw every frame.
  final _shadow = Paint()..color = const Color(0x2E000000);

  static final _blueHsv = HSVColor.fromColor(Palette.good);
  static final _goldHsv = HSVColor.fromColor(Palette.perfect);

  /// Blue → pink → orange → gold as the last second runs out: the hue goes
  /// "up" through magenta instead of through green.
  static Color _heat(double k) {
    final h = _blueHsv.hue + ((_goldHsv.hue + 360) - _blueHsv.hue) * k;
    return HSVColor.fromAHSV(
      1,
      h % 360,
      _blueHsv.saturation + (_goldHsv.saturation - _blueHsv.saturation) * k,
      _blueHsv.value + (_goldHsv.value - _blueHsv.value) * k,
    ).toColor();
  }

  final Map<String, TextPainter> _glyphs = {};
  TextPainter? _sub;
  String? _subText;
  double _subSize = 0;
  double _subAlpha = -1;
  double _glyphSize = 0;
  Color _glyphColor = Palette.outline;

  void flash(Tier tier) {
    _flash = tier == Tier.miss ? 0 : 0.35;
    _flashColor = switch (tier) {
      Tier.perfect => Palette.perfect,
      Tier.great => Palette.great,
      _ => Palette.good,
    };
  }

  @override
  void update(double dt) {
    _time += dt;
    if (_flash > 0) _flash = math.max(0, _flash - dt);
  }

  TextPainter _glyph(String ch) => _glyphs.putIfAbsent(ch, () {
    return TextPainter(
      text: TextSpan(
        text: ch,
        style: TextStyle(
          fontFamily: Fonts.display,
          fontSize: _glyphSize,
          color: _glyphColor,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  });

  /// Digits drawn one per fixed-width cell so they never jump (U-9).
  void _drawDigits(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color,
  ) {
    if (size != _glyphSize || color != _glyphColor) {
      _glyphs.clear();
      _glyphSize = size;
      _glyphColor = color;
    }
    final cell = _glyph('0').width * 1.04;
    final dotCell = cell * 0.45;
    var width = 0.0;
    for (final ch in text.split('')) {
      width += ch == '.' ? dotCell : cell;
    }
    var x = center.dx - width / 2;
    for (final ch in text.split('')) {
      final w = ch == '.' ? dotCell : cell;
      final p = _glyph(ch);
      p.paint(canvas, Offset(x + (w - p.width) / 2, center.dy - p.height / 2));
      x += w;
    }
  }

  @override
  void render(Canvas canvas) {
    final ctrl = stage.game.controller;
    final round = ctrl.round;
    final now = ctrl.now();
    final t = round.gameTime(now);
    final target = ctrl.balance.round.target;
    final r = stage.radius;
    final c = stage.center.toOffset().translate(stage.wobbleOffset, 0);
    final ring = r * 0.085;

    canvas.drawCircle(c.translate(0, r * 0.07), r, _shadow);
    canvas.drawCircle(c, r, _fill);

    // Progress arc: blue, turning gold in the last second.
    final innerR = r - ring * 1.2;
    _track.strokeWidth = ring;
    canvas.drawCircle(c, innerR, _track);
    final frac = (t / target).clamp(0.0, 1.03);
    if (frac > 0) {
      final gold = ((t - (target - 1)) / 1).clamp(0.0, 1.0);
      _arc
        ..strokeWidth = ring
        ..color = _heat(gold);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: innerR),
        -math.pi / 2,
        frac * math.pi * 2,
        false,
        _arc,
      );
    }

    // Ten ticks, one per second.
    _tick.strokeWidth = r * 0.02;
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * (innerR - ring * 1.1),
        c + dir * (innerR - ring * 1.6),
        _tick,
      );
    }

    _outline.strokeWidth = r * 0.045;
    canvas.drawCircle(c, r, _outline);

    if (_flash > 0) {
      canvas.drawCircle(
        c,
        r,
        Paint()..color = _flashColor.withValues(alpha: (_flash / 0.35) * 0.45),
      );
    }

    // Digits; a perfect result snaps to 10.00 (R-RUNDA-9).
    final grade = round.lastGrade;
    final inResult = round.phase == RoundPhase.result && grade != null;
    var shown = t;
    if (inResult && grade.tier == Tier.perfect) shown = target;
    final digitColor = !inResult
        ? Palette.outline
        : switch (grade.tier) {
            Tier.perfect => Palette.perfectDeep,
            Tier.great => Palette.great,
            Tier.good => Palette.good,
            Tier.miss => Palette.miss,
          };
    _drawDigits(canvas, formatStopwatch(shown), c, r * 0.44, digitColor);

    String? line;
    var alpha = 1.0;
    if (round.phase == RoundPhase.waiting) {
      line = stage.game.labels.tapToStart;
      // Quantised so the cached painter is rebuilt a few times a second.
      alpha =
          ((0.55 + 0.45 * (0.5 + 0.5 * math.sin(_time * 4))) * 20).round() / 20;
    } else if (inResult && grade.missKind != MissKind.noTap) {
      line = formatError(grade.error);
    }
    if (line != null) {
      final size = r * 0.105;
      if (line != _subText || size != _subSize || alpha != _subAlpha) {
        _subText = line;
        _subSize = size;
        _subAlpha = alpha;
        _sub = TextPainter(
          text: TextSpan(
            text: line,
            style: TextStyle(
              fontFamily: Fonts.body,
              fontSize: size,
              fontWeight: FontWeight.w600,
              color: Palette.outline.withValues(alpha: 0.75 * alpha),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: r * 1.7);
      }
      final p = _sub!;
      p.paint(canvas, c.translate(-p.width / 2, r * 0.3));
    }
  }
}

/// Expanding ring on strong hits.
class Shockwave extends Component {
  Shockwave({
    required this.center,
    required this.from,
    required this.to,
    required this.color,
    this.life = 0.45,
  });

  final Vector2 center;
  final double from;
  final double to;
  final Color color;
  final double life;
  double _t = 0;
  final _paint = Paint()..style = PaintingStyle.stroke;

  @override
  void update(double dt) {
    _t += dt;
    if (_t >= life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final k = (_t / life).clamp(0.0, 1.0);
    final e = Curves.easeOutCubic.transform(k);
    _paint
      ..strokeWidth = from * 0.12 * (1 - k) + 1
      ..color = color.withValues(alpha: (1 - k) * 0.9);
    canvas.drawCircle(center.toOffset(), from + (to - from) * e, _paint);
  }
}
