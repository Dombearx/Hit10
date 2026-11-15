import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Decoration painted on a face between the fill and the ring.
enum DialDeco {
  none,
  wood,
  porcelain,
  shine,
  station,
  swiss,
  atomic,
  neon,
  stars,
  rift,
}

/// The look of one stopwatch face (docs/12 §3.3). Drawn in code like the
/// rest of the dial (docs/01): a few colours and a decoration.
class DialSkin {
  const DialSkin({
    required this.face,
    this.faceEdge,
    required this.track,
    required this.tick,
    required this.rim,
    required this.digits,
    this.dark = false,
    this.deco = DialDeco.none,
  });

  /// Fill at the centre and, when set, at the edge (a radial gradient).
  final Color face;
  final Color? faceEdge;

  /// The progress ring's empty track, the second ticks and the outline.
  final Color track;
  final Color tick;
  final Color rim;

  /// The running time's digits.
  final Color digits;

  /// A dark face: results use the bright tier colours, the bullet-time
  /// tint goes darker instead of lighter.
  final bool dark;
  final DialDeco deco;

  /// Digit colour of a result tier ([tierIndex]: 0 PERFEKT … 3 miss).
  Color result(int tierIndex) => switch (tierIndex) {
    0 => dark ? Palette.perfect : Palette.perfectDeep,
    1 => Palette.great,
    2 => Palette.good,
    _ => dark ? const Color(0xFFB8C0D4) : Palette.miss,
  };

  /// The fill tinted by Zimna krew's focus zone ([zone] 0..1).
  Color zoneTint(double zone) => Color.lerp(
    face,
    dark ? const Color(0xFF2A3870) : const Color(0xFFDDE6FF),
    zone,
  )!;
}

/// Every face by id, in the order of the balance file.
const dialSkins = <String, DialSkin>{
  'classic': DialSkin(
    face: Palette.dial,
    track: Color(0xFFEDE6DA),
    tick: Palette.outline,
    rim: Palette.outline,
    digits: Palette.outline,
  ),
  'wood': DialSkin(
    face: Color(0xFFE2B07A),
    faceEdge: Color(0xFFB97A3D),
    track: Color(0xFF9C6A35),
    tick: Color(0xFF4A2E12),
    rim: Color(0xFF4A2E12),
    digits: Color(0xFF3B2410),
    deco: DialDeco.wood,
  ),
  'porcelain': DialSkin(
    face: Color(0xFFFFFFFF),
    faceEdge: Color(0xFFE6EEFB),
    track: Color(0xFFD3E0F4),
    tick: Color(0xFF2F5DA8),
    rim: Color(0xFF24498A),
    digits: Color(0xFF1E3F7A),
    deco: DialDeco.porcelain,
  ),
  'brass': DialSkin(
    face: Color(0xFFF7DE9A),
    faceEdge: Color(0xFFC99A3A),
    track: Color(0xFFB08A3A),
    tick: Color(0xFF5E430C),
    rim: Color(0xFF5E430C),
    digits: Color(0xFF4A3508),
    deco: DialDeco.shine,
  ),
  'station': DialSkin(
    face: Color(0xFFFFFFFF),
    track: Color(0xFFE2E2E2),
    tick: Color(0xFF111111),
    rim: Color(0xFF111111),
    digits: Color(0xFF111111),
    deco: DialDeco.station,
  ),
  'swiss': DialSkin(
    face: Color(0xFFE0362B),
    faceEdge: Color(0xFFB8231A),
    track: Color(0xFF9E1D15),
    tick: Color(0xFFFFFFFF),
    rim: Color(0xFF6E0F09),
    digits: Color(0xFFFFFFFF),
    dark: true,
    deco: DialDeco.swiss,
  ),
  'quartz': DialSkin(
    face: Color(0xFFC3CFA8),
    faceEdge: Color(0xFFA3B289),
    track: Color(0xFF94A37B),
    tick: Color(0xFF2E3A24),
    rim: Color(0xFF3A3F35),
    digits: Color(0xFF263020),
  ),
  'atomic': DialSkin(
    face: Color(0xFF233A63),
    faceEdge: Color(0xFF0E1830),
    track: Color(0xFF2E4774),
    tick: Color(0xFF7FC8FF),
    rim: Color(0xFF060C1C),
    digits: Color(0xFFD6EEFF),
    dark: true,
    deco: DialDeco.atomic,
  ),
  'neon': DialSkin(
    face: Color(0xFF1E0E33),
    faceEdge: Color(0xFF0D0618),
    track: Color(0xFF34204F),
    tick: Palette.neonCyan,
    rim: Palette.neonMagenta,
    digits: Color(0xFFFFFFFF),
    dark: true,
    deco: DialDeco.neon,
  ),
  'cosmic': DialSkin(
    face: Color(0xFF2A1866),
    faceEdge: Color(0xFF07071F),
    track: Color(0xFF2E2766),
    tick: Color(0xFFC9B8FF),
    rim: Color(0xFF04041A),
    digits: Color(0xFFFFFFFF),
    dark: true,
    deco: DialDeco.stars,
  ),
  'golden': DialSkin(
    face: Color(0xFFFFEA8A),
    faceEdge: Color(0xFFE0A800),
    track: Color(0xFFD19E06),
    tick: Color(0xFF7A5200),
    rim: Color(0xFF7A5200),
    digits: Color(0xFF5A3C00),
    deco: DialDeco.shine,
  ),
  'rift': DialSkin(
    face: Color(0xFF2B1747),
    faceEdge: Color(0xFF0B0616),
    track: Color(0xFF3A2559),
    tick: Color(0xFF9FF7FF),
    rim: Color(0xFF000000),
    digits: Color(0xFFFFFFFF),
    dark: true,
    deco: DialDeco.rift,
  ),
};

DialSkin dialSkin(String id) => dialSkins[id] ?? dialSkins['classic']!;

/// Paints the face's fill and decoration (under the ring and the ticks).
/// [fill] replaces the face colour (the golden round, the focus zone).
/// [time] animates the few decorations that move.
void paintDialFace(
  Canvas canvas,
  Offset c,
  double r,
  DialSkin skin, {
  Color? fill,
  double time = 0,
}) {
  final rect = Rect.fromCircle(center: c, radius: r);
  final edge = skin.faceEdge;
  final paint = Paint();
  if (fill != null || edge == null) {
    paint.color = fill ?? skin.face;
  } else {
    paint.shader = RadialGradient(
      colors: [skin.face, edge],
      stops: const [0.35, 1],
    ).createShader(rect);
  }
  canvas.drawCircle(c, r, paint);
  if (fill != null && fill != skin.face) return; // a special state: plain
  final stroke = Paint()..style = PaintingStyle.stroke;
  // Decorations never spill past the rim.
  canvas.save();
  canvas.clipPath(Path()..addOval(rect));
  _paintDeco(canvas, c, r, skin, stroke, rect, time);
  canvas.restore();
}

void _paintDeco(
  Canvas canvas,
  Offset c,
  double r,
  DialSkin skin,
  Paint stroke,
  Rect rect,
  double time,
) {
  switch (skin.deco) {
    case DialDeco.none:
      break;
    case DialDeco.wood:
      // Growth rings, slightly off-centre.
      stroke
        ..strokeWidth = r * 0.012
        ..color = const Color(0x405A3410);
      final o = c.translate(-r * 0.18, r * 0.1);
      for (var i = 1; i <= 7; i++) {
        canvas.drawOval(
          Rect.fromCenter(center: o, width: r * 0.32 * i, height: r * 0.24 * i),
          stroke,
        );
      }
    case DialDeco.porcelain:
      // A ring of cobalt dots just inside the rim.
      final dot = Paint()..color = const Color(0xFF2F5DA8);
      for (var i = 0; i < 24; i++) {
        final a = i * math.pi / 12;
        canvas.drawCircle(
          c + Offset(math.cos(a), math.sin(a)) * r * 0.93,
          r * (i.isEven ? 0.022 : 0.012),
          dot,
        );
      }
    case DialDeco.shine:
      // A soft diagonal glint.
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - r, c.dy - r * 0.2)
          ..lineTo(c.dx - r * 0.2, c.dy - r)
          ..lineTo(c.dx + r * 0.1, c.dy - r)
          ..lineTo(c.dx - r, c.dy + r * 0.1)
          ..close(),
        Paint()..color = const Color(0x55FFFFFF),
      );
      canvas.restore();
    case DialDeco.station:
      // The red seconds dot of a railway clock.
      canvas.drawCircle(
        c.translate(0, r * 0.62),
        r * 0.07,
        Paint()..color = const Color(0xFFD62828),
      );
    case DialDeco.swiss:
      // A small white cross below the digits.
      final p = Paint()..color = const Color(0xFFFFFFFF);
      final k = r * 0.05;
      final at = c.translate(0, r * 0.6);
      canvas
        ..drawRect(Rect.fromCenter(center: at, width: k * 3, height: k), p)
        ..drawRect(Rect.fromCenter(center: at, width: k, height: k * 3), p);
    case DialDeco.atomic:
      // Three faint electron orbits, slowly turning.
      stroke
        ..strokeWidth = r * 0.012
        ..color = const Color(0x557FC8FF);
      for (var i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(time * 0.3 + i * math.pi / 3);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: r * 1.6,
            height: r * 0.55,
          ),
          stroke,
        );
        canvas.restore();
      }
    case DialDeco.neon:
      // A glowing inner ring, breathing.
      final p = 0.5 + 0.5 * math.sin(time * 2);
      stroke
        ..strokeWidth = r * 0.03
        ..color = Palette.neonCyan.withValues(alpha: 0.35 + 0.3 * p);
      canvas.drawCircle(c, r * 0.72, stroke);
    case DialDeco.stars:
      // Fixed stars (seeded), twinkling.
      final rnd = math.Random(5);
      final star = Paint();
      for (var i = 0; i < 40; i++) {
        final a = rnd.nextDouble() * math.pi * 2;
        final d = math.sqrt(rnd.nextDouble()) * r * 0.92;
        final tw = 0.5 + 0.5 * math.sin(time * 2 + i);
        star.color = Colors.white.withValues(
          alpha: 0.25 + 0.6 * tw * rnd.nextDouble(),
        );
        canvas.drawCircle(
          c + Offset(math.cos(a), math.sin(a)) * d,
          r * (0.006 + 0.012 * rnd.nextDouble()),
          star,
        );
      }
    case DialDeco.rift:
      // A glowing crack across the face.
      final crack = Path()
        ..moveTo(c.dx - r * 0.85, c.dy - r * 0.35)
        ..lineTo(c.dx - r * 0.4, c.dy - r * 0.15)
        ..lineTo(c.dx - r * 0.25, c.dy + r * 0.2)
        ..lineTo(c.dx + r * 0.15, c.dy + r * 0.05)
        ..lineTo(c.dx + r * 0.35, c.dy + r * 0.45)
        ..lineTo(c.dx + r * 0.8, c.dy + r * 0.4);
      final p = 0.5 + 0.5 * math.sin(time * 3);
      canvas
        ..drawPath(
          crack,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.07
            ..color = Palette.neonMagenta.withValues(alpha: 0.25 + 0.2 * p),
        )
        ..drawPath(
          crack,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.02
            ..color = Palette.neonCyan.withValues(alpha: 0.8),
        );
  }
}

/// A still face for previews: fill, decoration, ring, ticks, rim and
/// "5.00" (the settings gallery, the toast).
class DialPreview extends StatelessWidget {
  const DialPreview({
    super.key,
    required this.skin,
    this.size = 64,
    this.locked = false,
  });
  final DialSkin skin;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _PreviewPainter(skin, locked)),
  );
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.skin, this.locked);
  final DialSkin skin;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2 * 0.92;
    final c = size.center(Offset.zero);
    if (locked) {
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFFE4DED3));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06
          ..color = Palette.outline.withValues(alpha: 0.35),
      );
      _text(canvas, c, r, '?', Palette.outline.withValues(alpha: 0.45), 0.8);
      return;
    }
    paintDialFace(canvas, c, r, skin);
    final ring = r * 0.085;
    final inner = r - ring * 1.2;
    canvas.drawCircle(
      c,
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring
        ..color = skin.track,
    );
    final tick = Paint()
      ..color = skin.tick
      ..strokeWidth = r * 0.03
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * (inner - ring * 1.1),
        c + dir * (inner - ring * 1.7),
        tick,
      );
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = skin.rim,
    );
    _text(canvas, c, r, '5.00', skin.digits, 0.36);
  }

  void _text(Canvas canvas, Offset c, double r, String s, Color col, double k) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: Fonts.display,
          fontSize: r * k,
          color: col,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.skin != skin || old.locked != locked;
}
