import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/ad_offers.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../l10n/master_texts.dart';
import '../trait_text.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../providers.dart';
import '../screens/sheet.dart';
import '../theme.dart';
import 'ad_buttons.dart';
import 'ad_offer_sheet.dart';
import 'coach.dart';
import 'emoji_card.dart';
import 'res_text.dart';

const _springGold = Color(0xFFE8A317);

/// A Mainspring drawn in code (docs/01: shapes by code): a coiled spiral,
/// with a ring around it that fills as the next one winds.
class SpringIcon extends StatelessWidget {
  const SpringIcon({super.key, this.size = 24, this.fraction});
  final double size;

  /// Winding of the next one, 0..1; null draws no ring.
  final double? fraction;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SpringPainter(fraction)),
  );
}

class _SpringPainter extends CustomPainter {
  _SpringPainter(this.fraction);
  final double? fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final f = fraction;
    final coil = f == null ? r * 0.95 : r * 0.68;
    canvas.drawCircle(c, coil, Paint()..color = const Color(0xFFFFF1C4));
    // Archimedean spiral, ~3 turns.
    final path = Path();
    const turns = 3.0;
    const steps = 90;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final a = t * turns * 2 * math.pi;
      final d = coil * (0.12 + 0.78 * t);
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, r * 0.13)
        ..strokeCap = StrokeCap.round
        ..color = _springGold,
    );
    canvas.drawCircle(
      c,
      coil,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * 0.08)
        ..color = Palette.outline,
    );
    if (f != null) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.18
        ..strokeCap = StrokeCap.round;
      final rr = r * 0.88;
      canvas.drawCircle(
        c,
        rr,
        ring..color = Palette.outline.withValues(alpha: 0.18),
      );
      if (f > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: rr),
          -math.pi / 2,
          2 * math.pi * f,
          false,
          ring..color = _springGold,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SpringPainter old) => old.fraction != fraction;
}

/// Some clock level is affordable right now.
bool anyClockLevelAffordable(GameController c) {
  for (final g in c.balance.generators) {
    final cost = c.econ.clockLevelCost(g.id);
    if (c.econ.clockLevelable(g.id) &&
        cost != null &&
        c.state.springs >= cost) {
      return true;
    }
  }
  return false;
}

/// What the next exact hit does to the Mainspring, for the header badge
/// (R-SPR-1): pips of the winding reserve, one per plain hit.
class SpringHitState {
  SpringHitState._(this.full, this.pips, this.maxPips);

  factory SpringHitState.of(GameController c) {
    final sp = c.balance.springs;
    final e = c.engine;
    final now = c.wallMs();
    final maxPips = sp.hitSeconds > 0
        ? (c.econ.hitReserve() / sp.hitSeconds).round()
        : 0;
    if (e.springsFull) return SpringHitState._(true, 0, maxPips);
    final left = e.springReserveAt(now);
    // A hair under a whole hit still counts as one: the reserve refills
    // by the second.
    final pips = sp.hitSeconds > 0
        ? math.min(maxPips, (left / sp.hitSeconds + 1e-6).floor())
        : 0;
    return SpringHitState._(false, pips, maxPips);
  }

  /// The stock is full: a hit winds nothing and takes nothing (R-SPR-4).
  final bool full;

  /// Plain hits the reserve still holds, out of [maxPips] (R-SPR-3).
  final int pips;
  final int maxPips;

  bool get empty => !full && pips == 0;
}

/// The reserve as pips in two rows under the stock count: gold for what is
/// left, hollow for what is gone.
class _ReservePips extends StatelessWidget {
  const _ReservePips(this.h);
  final SpringHitState h;

  @override
  Widget build(BuildContext context) {
    const dot = 3.5;
    const gap = 1.5;
    final perRow = (h.maxPips / 2).ceil();
    Widget pip(int i) {
      final on = i < h.pips;
      return Container(
        width: dot,
        height: dot,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? _springGold : Palette.outline.withValues(alpha: 0.15),
          border: on
              ? null
              : Border.all(
                  color: Palette.outline.withValues(alpha: 0.35),
                  width: 0.6,
                ),
        ),
      );
    }

    Widget row(int from) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = from; i < math.min(h.maxPips, from + perRow); i++) ...[
          if (i > from) const SizedBox(width: gap),
          pip(i),
        ],
      ],
    );
    return Column(
      key: const Key('springs-pips'),
      mainAxisSize: MainAxisSize.min,
      children: [
        row(0),
        const SizedBox(height: gap),
        row(perRow),
      ],
    );
  }
}

/// Header pill: ready Mainsprings, the next one winding (R-SPR-1/2) and
/// what exact hits can still wind (R-SPR-3/4).
class SpringBadge extends StatelessWidget {
  const SpringBadge({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.econ.springsUnlocked) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final glow = anyClockLevelAffordable(c);
    final h = SpringHitState.of(c);
    final count = '${c.state.springs}';
    return KeyedSubtree(
      key: CoachTargets.springs,
      child: Semantics(
        button: true,
        label: h.full
            ? l.springsBadgeFull(count)
            : l.springsBadgeHits(count, h.pips),
        excludeSemantics: true,
        child: GestureDetector(
          key: const Key('open-springs'),
          onTap: () => showSpringsSheet(context, c),
          child: Container(
            height: 40,
            padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
            decoration: BoxDecoration(
              color: glow
                  ? const Color(0xFFFFE08A)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Palette.outline, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  // Nothing to wind with hits right now.
                  opacity: h.empty ? 0.55 : 1,
                  child: SpringIcon(
                    size: 30,
                    fraction: c.engine.springFraction(),
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      count,
                      key: const Key('springs-count'),
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 16,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    if (h.full)
                      Text(
                        l.springsBadgeMax,
                        key: const Key('springs-max'),
                        style: TextStyle(
                          fontSize: 7.5,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: Palette.outline.withValues(alpha: 0.8),
                        ),
                      )
                    else
                      _ReservePips(h),
                  ],
                ),
                // The reserve is empty and an ad can fill it (R-SPR-3b).
                if (c.ads.available(AdOffer.spring, c.wallMs())) ...[
                  const SizedBox(width: 4),
                  Image.asset(
                    EmojiArt.path('television'),
                    key: const Key('springs-ad-hint'),
                    width: 16,
                    height: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The Mainspring workshop: what they are, when the next one is ready, and
/// every clock's level.
Future<void> showSpringsSheet(BuildContext context, GameController c) {
  c.tipActed('springs');
  return showGameSheet(
    context,
    c,
    title: (l) => l.springsTitle,
    builder: (context) => ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final f = Fmt.of(context, c);
        final s = c.state;
        final sp = c.balance.springs;
        final full = s.springs >= sp.maxStock;
        final next = c.econ.secondsPerSpring() - s.springProgress;
        final dim = TextStyle(
          fontSize: 13.5,
          color: Palette.outline.withValues(alpha: 0.75),
        );
        final gens = [
          for (final g in c.balance.generators)
            if (s.everOwned.contains(g.id)) g.id,
        ];
        return ListView(
          key: const Key('springs-sheet'),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                SpringIcon(size: 56, fraction: c.engine.springFraction()),
                const SizedBox(width: 12),
                Text(
                  '${s.springs}/${sp.maxStock}',
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ResText(
                    full
                        ? l.springsFull('${sp.maxStock}')
                        : l.springsNext(f.duration(next)),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ResText(
              l.springsIntro(f.mult(sp.levelFactor)),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            if (s.springsRefunded > 0) ...[
              const SizedBox(height: 10),
              Container(
                key: const Key('springs-refund'),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE08A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.outline, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ResText(
                        l.springsRefund(s.springsRefunded),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const Key('springs-refund-ok'),
                      onPressed: c.ackSpringsRefund,
                      child: Text(
                        l.tutorialGotIt,
                        style: const TextStyle(
                          fontFamily: Fonts.display,
                          color: Palette.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            SpringReserveCard(controller: c),
            const SizedBox(height: 14),
            if (gens.isEmpty) Text(l.springsNoClocks, style: dim),
            for (final id in gens)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Palette.outline, width: 2),
                  ),
                  child: ClockLevelSection(
                    controller: c,
                    id: id,
                    showName: true,
                    leading: EmojiCard(art: generatorArt[id]!, size: 40),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

/// One clock's Mainspring level: level, bonus, the two traits and the
/// button (the workshop sheet and the clock's full card, R-SPR-5/6,
/// docs/18 §4). The tier-3 trait shows from the start; the tier-5 one only
/// once tier 3 is reached. A title's name and joke come when it is bought.
class ClockLevelSection extends StatelessWidget {
  const ClockLevelSection({
    super.key,
    required this.controller,
    required this.id,
    this.showName = false,
    this.leading,
  });
  final GameController controller;
  final String id;

  /// Before the name and level (the clock's picture in the workshop).
  final Widget? leading;

  /// In the workshop list: the clock's name on top, no jokes (14 rows).
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final sp = c.balance.springs;
    final level = c.econ.clockLevel(id);
    final cost = c.econ.clockLevelCost(id);
    final can =
        c.econ.clockLevelable(id) && cost != null && c.state.springs >= cost;
    final mult = Fmt.of(context, c).mult(c.econ.clockLevelFactor(id));
    final small = TextStyle(
      fontSize: 12.5,
      color: Palette.outline.withValues(alpha: 0.7),
    );
    final head = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showName)
                Text(
                  generatorName(l, id),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 15,
                  ),
                ),
              Text(
                l.clockLevelLine('$level', '${sp.maxLevel}', mult),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (cost == null)
          Text(l.clockLevelMax, style: small)
        else
          GestureDetector(
            key: Key('level-up-$id'),
            onTap: can ? () => c.levelClock(id) : null,
            child: Opacity(
              opacity: can ? 1 : 0.45,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
                decoration: BoxDecoration(
                  color: can ? const Color(0xFFFFD54F) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Palette.outline, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.clockLevelUp('$cost'),
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const SpringIcon(size: 18),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
    return Column(
      key: Key('clock-level-$id'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        head,
        for (final (i, at) in sp.titleLevels.indexed) ...[
          const SizedBox(height: 6),
          TraitRow(
            controller: c,
            id: id,
            tier: i + 1,
            level: at,
            // The second tier's trait stays hidden until the first is in.
            hidden: i > 0 && level < sp.titleLevels[i - 1],
            joke: !showName,
          ),
        ],
      ],
    );
  }
}

/// One trait of a clock (docs/18): its tier, name and what it does.
/// Three looks: hidden (tier 5 before tier 3: only "Tier 5" and a lock),
/// to come (white card), at work (gold card with the title and a tick).
class TraitRow extends StatelessWidget {
  const TraitRow({
    super.key,
    required this.controller,
    required this.id,
    required this.tier,
    required this.level,
    required this.hidden,
    required this.joke,
  });
  final GameController controller;
  final String id;

  /// 1 or 2: which of the clock's traits.
  final int tier;

  /// The mastery tier it comes with.
  final int level;
  final bool hidden;

  /// Shows the title's joke once it is won (the full card).
  final bool joke;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final active = c.econ.clockLevel(id) >= level;
    final dim = Palette.outline.withValues(alpha: 0.55);
    final badge = Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? _springGold
            : hidden
            ? Palette.outline.withValues(alpha: 0.08)
            : Colors.white,
        border: Border.all(color: hidden ? dim : Palette.outline, width: 2),
      ),
      child: hidden
          ? Icon(Icons.lock_rounded, size: 14, color: dim)
          : active
          ? const Icon(Icons.check_rounded, size: 16, color: Palette.outline)
          : Text(
              '$level',
              style: const TextStyle(fontFamily: Fonts.display, fontSize: 13),
            ),
    );
    if (hidden) {
      return Container(
        key: Key('trait-$id-$tier'),
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          color: Palette.outline.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dim.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          children: [
            badge,
            const SizedBox(width: 8),
            Text(
              l.traitTier('$level'),
              style: TextStyle(
                fontFamily: Fonts.display,
                fontSize: 13.5,
                color: dim,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l.traitHidden('${_prevLevel(c)}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12, color: dim),
              ),
            ),
          ],
        ),
      );
    }
    final (name, text) = traitText(l, f, c.econ, id, tier);
    final title = active
        ? masterTexts(l, id, c.balance.springs.titleKeyAt(level)!)
        : null;
    final every = c.econ.expressEvery;
    return Container(
      key: Key('trait-$id-$tier'),
      padding: const EdgeInsets.fromLTRB(8, 7, 10, 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFF3C4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? Palette.outline
              : Palette.outline.withValues(alpha: 0.4),
          width: active ? 2 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          badge,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    '★ ${title.$1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Palette.perfectText,
                    ),
                  ),
                if (title != null && joke)
                  Text(
                    title.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Palette.outline.withValues(alpha: 0.7),
                    ),
                  ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        active ? name : '${l.traitTier('$level')} · $name',
                        style: const TextStyle(
                          fontFamily: Fonts.display,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.great,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l.traitActive,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  text,
                  style: const TextStyle(fontSize: 12.5, height: 1.25),
                ),
                // Express: how far the next double one is.
                if (active && id == 'stationClock' && tier == 2 && every > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _ExpressPips(
                      count: c.state.expressCount,
                      every: every,
                      label: l.traitExpressCount(c.state.expressCount, every),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The tier the hidden trait waits for (the one before it).
  int _prevLevel(GameController c) {
    final t = c.balance.springs.titleLevels;
    final i = t.indexOf(level);
    return i > 0 ? t[i - 1] : level;
  }
}

/// "Towards the Express: 3/5" with five pips (Station clock, docs/18).
class _ExpressPips extends StatelessWidget {
  const _ExpressPips({
    required this.count,
    required this.every,
    required this.label,
  });
  final int count;
  final int every;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    key: const Key('express-pips'),
    children: [
      for (var i = 0; i < every; i++) ...[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < count ? Palette.perfect : Colors.white,
            border: Border.all(color: Palette.outline, width: 1.2),
          ),
        ),
        const SizedBox(width: 3),
      ],
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

/// The level section for a clock's full card, or a note before the first
/// paradox. Null when the clock was never bought.
Widget? clockLevelCard(BuildContext context, GameController c, String id) {
  final l = AppLocalizations.of(context);
  if (!c.econ.springsUnlocked) return null;
  if (!c.state.everOwned.contains(id)) return null;
  return ListenableBuilder(
    listenable: c,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.clockLevelTitle,
          style: const TextStyle(fontFamily: Fonts.display, fontSize: 17),
        ),
        const SizedBox(height: 4),
        ClockLevelSection(controller: c, id: id),
      ],
    ),
  );
}

/// The winding reserve (R-SPR-3): how much exact hits can still wind, when
/// it is back, and the ad that fills it at once (R-SPR-3b).
class SpringReserveCard extends StatelessWidget {
  const SpringReserveCard({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final sp = c.balance.springs;
    final now = c.wallMs();
    final left = c.engine.springReserveAt(now);
    final empty = left < sp.hitSeconds;
    final adsLeft = c.ads.springAdsLeft(now);
    return Container(
      key: const Key('spring-reserve'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.outline, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.springsReserveTitle,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                l.springsReserve(
                  f.duration(left),
                  f.duration(c.econ.hitReserve()),
                ),
                key: const Key('spring-reserve-left'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: c.econ.hitReserve() > 0
                  ? (left / c.econ.hitReserve()).clamp(0.0, 1.0)
                  : 0,
              minHeight: 10,
              backgroundColor: Palette.outline.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(_springGold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            empty
                ? l.springsReserveEmpty(
                    f.duration(c.engine.springReserveFullIn(now)),
                  )
                : l.springsReserveHow(
                    f.duration(sp.hitSeconds),
                    f.duration(c.econ.reserveRefillSeconds()),
                  ),
            style: TextStyle(
              fontSize: 13,
              color: Palette.outline.withValues(alpha: 0.8),
            ),
          ),
          if (empty && c.ads.unlocked && adsLeft > 0) ...[
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final ads = ref.watch(rewardedAdsProvider);
                c.adOfferShown(AdOffer.spring);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdWatchButton(
                      key: const Key('ad-spring'),
                      ads: ads,
                      price: l.adSpring,
                      minWidth: 160,
                      onPressed: () async {
                        // The button goes with the offer: the result is
                        // said from the screen.
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await watchAdWithReward(
                          context,
                          c,
                          AdOffer.spring,
                          ads,
                        );
                        confirmAdResultWith(
                          messenger,
                          l,
                          c,
                          AdOffer.spring,
                          ok,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.adSpringLeft(adsLeft, c.balance.ads.springPerDay),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Palette.outline.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
