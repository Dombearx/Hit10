import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;

import '../engine/game_engine.dart';
import '../engine/round_engine.dart';
import '../model/grading.dart';
import '../model/number_format.dart';
import '../model/showcase.dart';
import '../ui/game_controller.dart';
import '../ui/theme.dart';
import '../ui/catalog.dart';
import 'baked.dart';
import 'generator_popup.dart';
import 'golden_clock.dart';
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
    required this.close,
    required this.tapToStart,
    required this.decimalSeparator,
    required this.goldenRound,
    required this.goldenEscaped,
    required this.frenzy,
    required this.lucky,
    required this.hotHand,
    required this.luckyBump,
    required this.shieldSaved,
  });
  final String perfect;
  final String great;
  final String good;
  final String early;
  final String late;
  final String close;
  final String tapToStart;
  final String decimalSeparator;
  final String goldenRound;
  final String goldenEscaped;
  final String Function(String mult) frenzy;
  final String Function(String amount) lucky;
  final String hotHand;
  final String luckyBump;
  final String shieldSaved;
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
    Baked.devicePixelRatio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
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
    _warmUp();
    _sub = controller.feedback.listen(stage.onFeedback);
    _starts = controller.roundStarts.listen(
      (e) => stage.onRoundStart(e.$2, clock: e.$1),
    );
  }

  /// Renders every effect label once, off screen, so the first PERFECT does
  /// not stall on font rasterisation and shader setup.
  void _warmUp() {
    final r = stage.radius;
    for (final (text, size) in [
      (labels.perfect, r * 0.24),
      (labels.great, r * 0.22),
      (labels.good, r * 0.2),
      (labels.early, r * 0.17),
      (labels.late, r * 0.17),
      (labels.close, r * 0.18),
      (labels.goldenRound, r * 0.2),
      ('+0123456789KMBT', r * 0.2),
    ]) {
      final p = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: Fonts.display,
            fontSize: size,
            color: Palette.perfect,
            shadows: const [
              Shadow(color: Palette.outline, offset: Offset(0, 3)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      Baked(
        p.width + 8,
        p.height + 8,
        (c) => p.paint(c, Offset.zero),
      ).dispose();
    }
  }

  StreamSubscription<(int, bool)>? _starts;
  GoldenClock? _golden;
  bool _goldenFromLeft = true;

  /// The screen asks before treating a tap as a round tap (R-ZLOTA-1).
  bool tapGolden(Vector2 p) {
    final g = _golden;
    if (g == null || !g.hits(p)) return false;
    g.leave(caught: true);
    stage.particles.burst(
      origin: g.position,
      count: 40,
      colors: const [Palette.perfect, Color(0xFFFFF3B0), Palette.perfectDeep],
      speedMin: 200,
      speedMax: 700,
    );
    _golden = null;
    controller.claimGolden();
    return true;
  }

  void _updateGolden() {
    final visible = controller.engine.goldenVisibleLeft > 0;
    if (visible && _golden == null) {
      _goldenFromLeft = !_goldenFromLeft;
      final g = GoldenClock(
        arenaSize: size,
        dialTop: stage.center.y - stage.radius,
        radius: stage.radius * 0.2,
        life: controller.engine.goldenVisibleLeft,
        fromLeft: _goldenFromLeft,
      );
      _golden = g;
      stage.add(g);
    } else if (!visible && _golden != null) {
      _golden!.leave(caught: false);
      _golden = null;
    }
  }

  final Map<String, ui.Image> _emoji = {};
  final _rng = math.Random();
  bool _popupLeft = true;

  /// The bubble currently shown on each side (left, right).
  final _popups = <GeneratorPopup?>[null, null];

  @override
  void update(double dt) {
    controller.tick();
    _updateGolden();
    controller.showcase.maxPerSecond =
        controller.balance.ui.generatorPopupsPerSecond;
    for (final hit in controller.showcase.update(dt, controller.econ)) {
      _spawnPopup(hit);
    }
    super.update(dt);
  }

  void _spawnPopup(ShowcaseHit hit) {
    _popupLeft = !_popupLeft;
    final n = controller.clocks.length;
    final c = stage.centerOf(_popupLeft ? 0 : n - 1);
    final r = stage.radiusOf(0);
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
    final side = _popupLeft ? 0 : 1;
    _popups[side]?.dismiss();
    final popup = _popups[side] = GeneratorPopup(
      emoji: _emoji[generatorArt[hit.generator]?.main],
      time: formatStopwatch(hit.gameTime),
      reward: hit.tier == Tier.miss
          ? '—'
          : '+${formatNumber(hit.reward, decimalSeparator: labels.decimalSeparator)}',
      tier: hit.tier,
      at: Vector2(x, y),
      scale: scale,
    );
    stage.add(popup);
  }

  @override
  void onRemove() {
    _sub?.cancel();
    _starts?.cancel();
    super.onRemove();
  }
}

/// Everything inside the arena, shaken as one (docs/04 §3).
class Stage extends Component {
  Stage(this.game);

  final ArenaGame game;
  final List<Dial> dials = [];
  final ParticleField particles = ParticleField();
  final _rng = math.Random();

  double _shake = 0; // remaining seconds
  double _shakeAmp = 0;
  double _shakeDur = 1;
  double _wobble = 0; // miss: horizontal dial wobble, seconds remaining
  int _wobbleClock = 0;

  Vector2 get size => game.size;
  int get _count => game.controller.clocks.length;

  /// One dial in the middle, or two side by side (docs/02 §9.2).
  Vector2 centerOf(int i) => _count == 1
      ? Vector2(size.x / 2, size.y * 0.5)
      : Vector2(size.x * (i == 0 ? 0.26 : 0.74), size.y * 0.5);

  double radiusOf(int i) => _count == 1
      ? math.min(size.x * 0.40, size.y * 0.42)
      : math.min(size.x * 0.23, size.y * 0.36);

  Vector2 get center => centerOf(0);
  double get radius => radiusOf(0);

  @override
  Future<void> onLoad() async {
    _syncDials();
    await add(particles);
    await add(DigitsLayer(this));
  }

  void _syncDials() {
    while (dials.length < _count) {
      final d = Dial(this, dials.length);
      dials.add(d);
      add(d);
    }
    while (dials.length > _count) {
      dials.removeLast().removeFromParent();
    }
  }

  /// "Reduce motion" (U-6): no shakes or flashes, a third of the particles.
  bool get reduceMotion => game.controller.settings.reduceMotion;

  void shake(double amplitude, double seconds) {
    if (reduceMotion) return;
    _shakeAmp = amplitude;
    _shake = seconds;
    _shakeDur = seconds;
  }

  double wobbleOffset(int clock) => _wobble <= 0 || clock != _wobbleClock
      ? 0
      : math.sin(_wobble * 60) * 10 * (_wobble / 0.35);

  @override
  void update(double dt) {
    if (dials.length != _count) _syncDials();
    particles.density = reduceMotion ? 1 / 3 : 1;
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
    final c = centerOf(f.clock);
    final r = radiusOf(f.clock);
    final l = game.labels;
    final g = f.grade;
    if (f.clock < dials.length) dials[f.clock].flash(g.tier);
    _wobbleClock = f.clock;
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
        // BLISKO pays a little: say so in a friendlier colour.
        final text = g.close
            ? l.close
            : g.missKind == MissKind.early
            ? l.early
            : l.late;
        add(
          PopText(
            text: text,
            style: label(
              g.close ? Palette.good : Palette.missText,
              r * (g.close ? 0.18 : 0.17),
            ),
            at: labelAt,
            dropIn: true,
            life: 0.85,
          ),
        );
    }
    final o = f.outcome;
    final small = label(Palette.dial, r * 0.13);
    if (o.bumpedByLuck) {
      add(
        PopText(
          text: l.luckyBump,
          style: small,
          at: Vector2(c.x, c.y + r * 0.42),
          life: 0.8,
        ),
      );
    }
    if (o.shieldUsed) {
      add(
        PopText(
          text: l.shieldSaved,
          style: label(Palette.good, r * 0.15),
          at: Vector2(c.x, c.y + r * 0.42),
          life: 0.9,
        ),
      );
    }
    final golden = o.golden;
    if (golden != null) {
      final gs = label(Palette.perfect, r * 0.2);
      final text = switch (golden.effect) {
        null => l.goldenEscaped,
        GoldenEffect.frenzy => l.frenzy(
          formatNumber(
            game.controller.balance.golden.effect('frenzy').multiplier,
          ),
        ),
        GoldenEffect.lucky => l.lucky(
          formatNumber(golden.amount, decimalSeparator: l.decimalSeparator),
        ),
        GoldenEffect.hotHand => l.hotHand,
      };
      add(
        PopText(
          text: text,
          style: gs,
          // Over the lower dial: clear of the digits and the balance.
          at: Vector2(c.x, c.y + r * 0.62),
          life: 1.8,
          rise: r * 0.15,
        ),
      );
      if (golden.effect != null) {
        particles.burst(
          origin: c,
          count: 80,
          colors: const [
            Palette.perfect,
            Color(0xFFFFF3B0),
            Palette.neonMagenta,
          ],
          speedMin: 400,
          speedMax: 1300,
          sizeMin: 6,
          sizeMax: 16,
          life: 1.3,
        );
        shake(10, 0.35);
      }
    }
    if (f.reward > 0) {
      add(
        PopText(
          text:
              '+${formatNumber(f.reward, decimalSeparator: l.decimalSeparator)}',
          style: label(Palette.dial, r * 0.2),
          // Flies up towards the balance counter (docs/04 §3) and fades
          // before reaching it.
          at: Vector2(c.x, c.y - r * 1.12),
          rise: r * 0.45,
          life: 0.8,
        ),
      );
    }
  }
}

/// Effects that start with a round: the golden-round banner.
extension on Stage {
  void onRoundStart(bool golden, {int clock = 0}) {
    if (!golden) return;
    final c = centerOf(clock);
    final r = radiusOf(clock);
    add(
      PopText(
        text: game.labels.goldenRound,
        style: TextStyle(
          fontFamily: Fonts.display,
          fontSize: r * 0.2,
          color: Palette.perfect,
          shadows: const [Shadow(color: Palette.outline, offset: Offset(0, 3))],
        ),
        at: Vector2(c.x, c.y - r * 0.55),
        life: 1.4,
      ),
    );
  }
}

/// The stopwatch face: ring, progress arc, ticks and fixed-width digits.
class Dial extends Component {
  Dial(this.stage, this.index);

  final Stage stage;

  /// Which stopwatch this face shows (0, or 1 for the second clock).
  final int index;
  double _flash = 0;
  Color _flashColor = Palette.perfect;

  /// This frame's digits; [DigitsLayer] paints them over the particles.
  void Function(Canvas canvas)? digits;
  double _time = 0; // for idle pulsing
  double _zone = 0; // bullet-time overlay strength 0..1

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

  TextPainter? _sub;
  String? _subText;
  double _subSize = 0;
  double _subAlpha = -1;

  void flash(Tier tier) {
    _flash = tier == Tier.miss || stage.reduceMotion ? 0 : 0.35;
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

  /// Glyph painters per (size, colour); a handful of combinations exist
  /// (digit colours per tier, the fast-forward ghost), so layout happens
  /// once per combination, not per frame.
  final Map<(double, int), Map<String, TextPainter>> _glyphCache = {};

  TextPainter _glyph(String ch, double size, Color color) {
    final key = (size.roundToDouble(), color.toARGB32());
    if (_glyphCache.length > 24) _glyphCache.clear();
    final set = _glyphCache.putIfAbsent(key, () => {});
    return set.putIfAbsent(
      ch,
      () => TextPainter(
        text: TextSpan(
          text: ch,
          style: TextStyle(
            fontFamily: Fonts.display,
            fontSize: key.$1,
            color: color,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  /// Digits drawn one per fixed-width cell so they never jump (U-9);
  /// [scale] throbs them without re-laying out text.
  void _drawDigits(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color, {
    double scale = 1,
  }) {
    final cell = _glyph('0', size, color).width * 1.04;
    final dotCell = cell * 0.45;
    var width = 0.0;
    for (final ch in text.split('')) {
      width += ch == '.' ? dotCell : cell;
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (scale != 1) canvas.scale(scale);
    var x = -width / 2;
    for (final ch in text.split('')) {
      final w = ch == '.' ? dotCell : cell;
      final p = _glyph(ch, size, color);
      p.paint(canvas, Offset(x + (w - p.width) / 2, -p.height / 2));
      x += w;
    }
    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    final ctrl = stage.game.controller;
    digits = null;
    if (index >= ctrl.clocks.length) return;
    final slot = ctrl.clocks[index];
    final round = slot.round;
    final now = ctrl.now();
    final t = round.gameTime(now);
    final target = ctrl.balance.round.target;
    final r = stage.radiusOf(index);
    final c = stage
        .centerOf(index)
        .toOffset()
        .translate(stage.wobbleOffset(index), 0);
    final ring = r * 0.085;

    final engine = ctrl.engine;
    final running = round.phase == RoundPhase.running;
    final map = round.phase == RoundPhase.waiting ? null : round.timeMap;
    final inZone =
        running &&
        map != null &&
        engine.econ.level('bulletTime') > 0 &&
        map.inFocusZone(t);
    final golden = engine.goldenRound;

    // Zimna krew: the arena cools and darkens at the edges (docs/04 §3).
    _zone = inZone ? math.min(1, _zone + 0.12) : math.max(0, _zone - 0.08);
    if (_zone > 0) {
      // A dark aura around the dial that fades out before the arena edges.
      final aura = r * 1.9;
      canvas.drawCircle(
        c,
        aura,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.fromRGBO(30, 40, 90, 0.5 * _zone),
              Color.fromRGBO(30, 40, 90, 0.28 * _zone),
              const Color(0x001E285A),
            ],
            stops: const [0.5, 0.72, 1],
          ).createShader(Rect.fromCircle(center: c, radius: aura)),
      );
    }

    // Frenzy: neon halo pulsing behind the dial.
    if (engine.frenzy > 1) {
      // Gradient halo: a blur filter would be redrawn every frame.
      final p = 0.5 + 0.5 * math.sin(_time * 7);
      final halo = r * (1.22 + 0.06 * p);
      final col = Color.lerp(Palette.neonCyan, Palette.neonMagenta, p)!;
      canvas.drawCircle(
        c,
        halo,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withValues(alpha: 0.75), col.withValues(alpha: 0)],
            stops: const [0.78, 1],
          ).createShader(Rect.fromCircle(center: c, radius: halo)),
      );
    }

    canvas.drawCircle(c.translate(0, r * 0.07), r, _shadow);
    _fill.color = golden
        ? const Color(0xFFFFF4C2)
        : Color.lerp(Palette.dial, const Color(0xFFDDE6FF), _zone)!;
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

    _outline
      ..strokeWidth = r * 0.045
      ..color = golden ? Palette.perfectDeep : Palette.outline;
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
    // Zimna krew makes the digits throb near the target.
    final digitSize = r * 0.44;
    final throb = _zone > 0 ? 1 + 0.05 * _zone * math.sin(_time * 14) : 1.0;
    // Drawn later by the digits layer, above every particle (U-7).
    digits = (canvas) {
      final hideAt = ctrl.balance.blind.hideDigitsAt;
      final hidden = slot.blind && running && hideAt != null && t >= hideAt;
      _drawDigits(
        canvas,
        // Blind mode (docs/02 §7): from 7.00 a pulsing "?" replaces the time.
        hidden ? '??.??' : formatStopwatch(shown),
        c,
        digitSize,
        hidden ? Palette.miss : digitColor,
        scale: hidden ? 1 + 0.06 * math.sin(_time * 6) : throb,
      );
    };
    if (golden && running) {
      final p = 0.5 + 0.5 * math.sin(_time * 6);
      _outline.color = Palette.perfect.withValues(alpha: 0.6 + 0.4 * p);
      canvas.drawCircle(c, r * 1.04, _outline);
      _outline.color = Palette.outline;
    }

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

/// The stopwatch digits of every dial, painted after (over) the particles:
/// effects never cover the time (docs/04 U-7).
class DigitsLayer extends Component {
  DigitsLayer(this.stage) : super(priority: 10);
  final Stage stage;

  @override
  void render(Canvas canvas) {
    for (final d in stage.dials) {
      d.digits?.call(canvas);
    }
  }
}
