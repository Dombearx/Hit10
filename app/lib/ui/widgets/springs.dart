import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/ad_offers.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../l10n/master_texts.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../providers.dart';
import '../screens/sheet.dart';
import '../theme.dart';
import 'ad_buttons.dart';
import 'ad_offer_sheet.dart';
import 'emoji_card.dart';

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

/// Header pill: ready Mainsprings and the next one winding (R-SPR-1/2).
class SpringBadge extends StatelessWidget {
  const SpringBadge({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.econ.springsUnlocked) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final glow = anyClockLevelAffordable(c);
    return Semantics(
      button: true,
      label: l.springsBadge('${c.state.springs}'),
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
              SpringIcon(size: 30, fraction: c.engine.springFraction()),
              const SizedBox(width: 4),
              Text(
                '${c.state.springs}',
                key: const Key('springs-count'),
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 16),
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
    );
  }
}

/// The Mainspring workshop: what they are, when the next one is ready, and
/// every clock's level.
Future<void> showSpringsSheet(BuildContext context, GameController c) {
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
        final next = sp.secondsPerSpring - s.springProgress;
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
                  child: Text(
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
            Text(
              l.springsIntro('${(sp.levelBonus * 100).round()}'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
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
                  child: Row(
                    children: [
                      EmojiCard(art: generatorArt[id]!, size: 44),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClockLevelSection(
                          controller: c,
                          id: id,
                          showName: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

/// One clock's Mainspring level: level, bonus, next title and the button
/// (the workshop sheet and the clock's full card, R-SPR-5/6).
class ClockLevelSection extends StatelessWidget {
  const ClockLevelSection({
    super.key,
    required this.controller,
    required this.id,
    this.showName = false,
  });
  final GameController controller;
  final String id;
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
    final pct = (sp.levelBonus * level * 100).round();
    // The next title: its name stays a surprise until it is reached.
    final nextTitle = sp.titleLevels.where((t) => t > level).firstOrNull;
    final lastTitle = sp.titleLevels.where((t) => t <= level).lastOrNull;
    final reached = lastTitle == null ? null : masterTexts(l, id, lastTitle);
    final small = TextStyle(
      fontSize: 12.5,
      color: Palette.outline.withValues(alpha: 0.7),
    );
    return Row(
      key: Key('clock-level-$id'),
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showName)
                Text(
                  generatorName(l, id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 15,
                  ),
                ),
              Text(
                l.clockLevelLine('$level', '${sp.maxLevel}', '$pct'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (reached != null)
                Text(
                  '★ ${reached.$1}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Palette.perfectDeep,
                  ),
                ),
              if (nextTitle != null)
                Text(l.clockLevelTitleAt('$nextTitle', '???'), style: small),
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
  }
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
    final first = c.engine.springFirstHitReady(now) && !empty;
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
                l.springsReserve(f.duration(left), f.duration(sp.hitReserve)),
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
              value: sp.hitReserve > 0
                  ? (left / sp.hitReserve).clamp(0.0, 1.0)
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
                : first
                ? l.springsReserveFirst(
                    f.duration(math.min(sp.firstHitSeconds, left)),
                    f.duration(sp.firstHitAfter),
                  )
                : l.springsReserveHow(
                    f.duration(sp.hitSeconds),
                    f.duration(sp.reserveRefillSeconds),
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
