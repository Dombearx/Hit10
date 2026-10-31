import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/economy.dart';
import '../../model/grading.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/buy_button.dart';
import '../widgets/emoji_card.dart';

/// The "Skills" tab (docs/02 §4): level, effect now → next, price.
class SkillList extends StatelessWidget {
  const SkillList({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final skills = [...c.balance.skills]
      ..sort((a, b) => a.baseCost.compareTo(b.baseCost));
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        for (final sk in skills)
          _revealed(c, sk.id)
              ? _SkillTile(key: ValueKey(sk.id), controller: c, id: sk.id)
              : _LockedSkill(controller: c, id: sk.id),
      ],
    );
  }

  /// R-UMIEJ-3: shown once the player has held half its first price.
  static bool _revealed(GameController c, String id) =>
      c.econ.level(id) > 0 ||
      c.state.peakTiki >=
          c.balance.skill(id).baseCost * c.balance.ui.skillRevealFraction;
}

/// "now → next" texts for each skill's effect.
(String, String) skillEffectValues(
  AppLocalizations l,
  Economy e,
  String id,
  int level,
) {
  String n(double v, int digits) =>
      v.toStringAsFixed(digits).replaceAll('.', l.decimalSeparator);
  TierOdds odds(int lv) => e.odds(
    e.playerSpread(),
    e.playerWindowsWith(id, lv),
    luck: e.luckChance(),
  );
  String pct(TierOdds o, double Function(TierOdds) pick) {
    final p = pick(o) * 100;
    return '${n(p, p < 10 ? 1 : 0)}%';
  }

  String at(int lv) {
    switch (id) {
      case 'power':
        return '×${n(1 + e.b.skill('power').perLevel * lv, 1)}';
      case 'fastForward':
        return n(e.laterStart(lv), 2);
      case 'ticking':
        return lv > 0 ? l.on : l.off;
      // Window skills: what they mean for this player's own taps, at
      // their measured spread (playtest: "±0.022 → 0.023 s" said nothing).
      case 'wideEye':
        return pct(odds(lv), (o) => o.perfect + o.great);
      case 'combo':
        return '${e.comboCap(lv)}';
      case 'magnet':
        return pct(odds(lv), (o) => o.perfect);
      case 'echo':
        return '${n(e.b.skill('echo').perLevel * lv, 1)} s';
      case 'bulletTime':
        return pct(odds(lv), (o) => o.hit);
      case 'luck':
        return '${(e.luckChance(lv) * 100).round()}%';
      case 'shield':
        return '$lv';
      case 'goldenTouch':
        return '×${n(1 - e.b.skill('goldenTouch').perLevel * lv, 2)}';
    }
    return '$lv';
  }

  return (at(level), at(level + 1));
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({super.key, required this.controller, required this.id});
  final GameController controller;
  final String id;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final cfg = c.balance.skill(id);
    final level = c.econ.level(id);
    final maxed = level >= cfg.maxLevel;
    final cost = c.econ.skillCost(id);
    final affordable = cost != null && cost <= c.state.tiki;
    final (now, next) = skillEffectValues(l, c.econ, id, level);
    final label = skillLabel(l, id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: affordable ? Palette.accent : Palette.outline,
          width: affordable ? 3 : 2.5,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Everything but the buy button opens the details (playtest: the
          // descriptions were cut and the full text was nowhere).
          Expanded(
            child: GestureDetector(
              key: Key('skill-info-$id'),
              behavior: HitTestBehavior.opaque,
              onTap: () => showSkillInfo(context, c, id),
              child: Row(
                children: [
                  EmojiCard(
                    art: skillArt[id]!,
                    size: 54,
                    badge: level > 0 ? '$level' : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                skillName(l, id),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Palette.outline.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                        Text(
                          maxed
                              ? l.skillEffectMax(label, now)
                              : l.skillEffect(label, now, next),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Palette.perfectDeep,
                          ),
                        ),
                        Text(
                          skillDescription(l, id),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.2,
                            color: Palette.outline.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          BuyButton(
            key: Key('skill-$id'),
            label: maxed ? null : l.skillLevel(level, cfg.maxLevel),
            price: maxed ? l.skillMaxed : f.price(cost!),
            enabled: affordable,
            onPressed: () => c.buySkill(id),
          ),
        ],
      ),
    );
  }
}

class _LockedSkill extends StatelessWidget {
  const _LockedSkill({required this.controller, required this.id});
  final GameController controller;
  final String id;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final reveal =
        c.balance.skill(id).baseCost * c.balance.ui.skillRevealFraction;
    return Opacity(
      opacity: 0.75,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Palette.outline, width: 2.5),
        ),
        child: Row(
          children: [
            EmojiCard(art: skillArt[id]!, size: 54, locked: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.lockedName,
                    style: const TextStyle(
                      fontFamily: Fonts.display,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    l.skillLockedHint(f.price(reveal)),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Palette.outline.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What a PERFECT pays right now (without combo), and how many seconds of
/// the clocks' income that is: tells whether tapping is worth it.
String _perfectNow(GameController c, AppLocalizations l, Fmt f) {
  final pay = c.engine.hitPayout(const Grade(Tier.perfect, 0));
  final ps = c.engine.passive();
  if (ps <= 0) return l.perfectNow(f.n(pay));
  final secs = (pay / ps).toStringAsFixed(pay / ps < 10 ? 1 : 0);
  return l.perfectNowSeconds(
    f.n(pay),
    secs.replaceAll('.', l.decimalSeparator),
  );
}

/// A skill's details: everything the card has to cut short (docs/04).
Future<void> showSkillInfo(BuildContext context, GameController c, String id) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final f = Fmt.of(context, c);
        final cfg = c.balance.skill(id);
        final level = c.econ.level(id);
        final maxed = level >= cfg.maxLevel;
        final cost = c.econ.skillCost(id);
        final (now, next) = skillEffectValues(l, c.econ, id, level);
        final label = skillLabel(l, id);
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Palette.outline, width: 3),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    EmojiCard(
                      art: skillArt[id]!,
                      size: 64,
                      badge: level > 0 ? '$level' : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skillName(l, id),
                            style: const TextStyle(
                              fontFamily: Fonts.display,
                              fontSize: 22,
                            ),
                          ),
                          Text(l.skillLevel(level, cfg.maxLevel)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  maxed
                      ? l.skillEffectMax(label, now)
                      : l.skillEffect(label, now, next),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Palette.perfectDeep,
                  ),
                ),
                if (id == 'power' || id == 'echo')
                  Text(
                    _perfectNow(c, l, f),
                    key: Key('perfect-now-$id'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  skillInfo(l, id),
                  key: const Key('skill-info-text'),
                  style: const TextStyle(fontSize: 14.5, height: 1.35),
                ),
                const SizedBox(height: 16),
                Center(
                  child: BuyButton(
                    key: const Key('skill-info-buy'),
                    label: maxed ? null : l.skillLevel(level + 1, cfg.maxLevel),
                    price: maxed ? l.skillMaxed : f.price(cost!),
                    enabled: cost != null && cost <= c.state.tiki,
                    minWidth: 160,
                    onPressed: () => c.buySkill(id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
