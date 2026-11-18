import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../catalog.dart';
import 'springs.dart';

/// The game's resources, each with one icon used everywhere next to its
/// name (playtest: like a board game, the icon says which is which).
enum Res { tiki, chronon, shard, spring }

/// The icon of [res], sized to sit in a line of text.
class ResIcon extends StatelessWidget {
  const ResIcon(this.res, {super.key, this.size = 16});
  final Res res;
  final double size;

  @override
  Widget build(BuildContext context) => switch (res) {
    Res.tiki => Image.asset(
      EmojiArt.path('coin'),
      width: size,
      height: size,
      excludeFromSemantics: true,
    ),
    Res.chronon => Image.asset(
      EmojiArt.path('cyclone'),
      width: size,
      height: size,
      excludeFromSemantics: true,
    ),
    Res.shard => SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _ShardPainter()),
    ),
    Res.spring => SpringIcon(size: size),
  };
}

/// A Shard of time: the four-pointed violet star the texts used to write
/// as "✦".
class _ShardPainter extends CustomPainter {
  const _ShardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final d = i.isEven ? r * 0.98 : r * 0.34;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC9A7FF), Color(0xFF7B4DFF)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * 0.12)
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF3B2A7A),
    );
  }

  @override
  bool shouldRepaint(_ShardPainter oldDelegate) => false;
}

// Resource names in PL and EN, every inflected form; a standalone "✦" is a
// Shard too. Capitalised on purpose: "tik-tak" is not a resource.
final _resWords = RegExp(
  r'(?<!\p{L})(?:'
  r'(Tik(?:i|ów|a|ach|om|ami)?|Ticks?)'
  r'|(Chronon(?:y|ów|u|a|ami|om|ach)?|Chronons?)'
  r'|(Okruch(?:y|ów|a|ami|om|ach)?(?: czasu)?|Shards?(?: of time)?)'
  r'|(Sprężyn(?:a|y|ę|ą|ie|om|ami|ach)?|Mainsprings?)'
  r')(?!\p{L})(?: ✦)?'
  r'|✦',
  unicode: true,
);

/// [text] as spans with each resource's icon right before its name
/// ("Tiki" → 🪙 Tiki). [iconSize] defaults to the font size.
List<InlineSpan> resSpans(String text, {double iconSize = 16}) {
  final spans = <InlineSpan>[];
  var at = 0;
  for (final m in _resWords.allMatches(text)) {
    if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
    final res = m.group(1) != null
        ? Res.tiki
        : m.group(2) != null
        ? Res.chronon
        : m.group(4) != null
        ? Res.spring
        : Res.shard;
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.only(right: iconSize * 0.15),
          child: ResIcon(res, size: iconSize * 1.1),
        ),
      ),
    );
    final word = m.group(1) ?? m.group(2) ?? m.group(3) ?? m.group(4);
    // "Okruchy ✦" keeps the word; the star is now the icon.
    if (word != null) spans.add(TextSpan(text: word));
    at = m.end;
  }
  if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
  return spans;
}

/// A [Text] that puts each resource's icon before its name.
class ResText extends StatelessWidget {
  const ResText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final size =
        style?.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14;
    return Text.rich(
      TextSpan(children: resSpans(text, iconSize: size)),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
