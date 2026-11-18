import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../model/challenges.dart';
import 'catalog.dart';
import 'format.dart';
import 'game_controller.dart';
import 'screens/sheet.dart';
import 'theme.dart';
import 'widgets/buy_button.dart';
import 'widgets/emoji_card.dart';
import 'widgets/res_text.dart';

/// Daily and weekly challenges (docs/02 §18): three for today, one for the
/// week, each sized to the player's own aim (docs/14).
Future<void> showChallenges(BuildContext context, GameController c) {
  c.tipActed('challenges');
  return showGameSheet(
    context,
    c,
    title: (l) => l.challengesTitle,
    builder: (context) => ChallengesPanel(controller: c),
  );
}

/// The icon of each kind.
const _art = {
  ChallengeKind.great: EmojiArt('bullseye', Color(0xFFA7E0FF)),
  ChallengeKind.greatWeek: EmojiArt('bullseye', Color(0xFFA7E0FF)),
  ChallengeKind.streak: EmojiArt('fire', Color(0xFFFFC9A8)),
  ChallengeKind.streakWeek: EmojiArt('fire', Color(0xFFFFC9A8)),
  ChallengeKind.jackpot: EmojiArt('keycap_5', Color(0xFFFFE29A)),
  ChallengeKind.jackpotWeek: EmojiArt('keycap_5', Color(0xFFFFE29A)),
  ChallengeKind.perfectWindow: EmojiArt('high_voltage', Color(0xFFFFF0A0)),
  ChallengeKind.perfect: EmojiArt('magnet', Color(0xFFB9A7FF)),
  ChallengeKind.hitEarnings: EmojiArt('money_bag', Color(0xFFB8F0C0)),
  ChallengeKind.buyClocks: EmojiArt('shopping_cart', Color(0xFFFFD36E)),
  ChallengeKind.milestones: EmojiArt('glowing_star', Color(0xFFFFE6A7)),
  ChallengeKind.skillLevels: EmojiArt('flexed_biceps', Color(0xFFFFC9DE)),
  ChallengeKind.goldenWeek: EmojiArt('sparkles', Color(0xFFFFE6A7)),
  ChallengeKind.springWeek: EmojiArt('gear', Color(0xFFD7C4FF)),
};

/// What the challenge asks, in words, with its number.
String challengeText(AppLocalizations l, Fmt f, Challenge c) {
  final n = c.target.round();
  return switch (c.kind) {
    ChallengeKind.great || ChallengeKind.greatWeek => l.chGreat(n),
    ChallengeKind.streak || ChallengeKind.streakWeek => l.chStreak(n),
    ChallengeKind.jackpot || ChallengeKind.jackpotWeek => l.chJackpot(n),
    ChallengeKind.perfectWindow => l.chPerfectWindow(n),
    ChallengeKind.perfect => l.chPerfect(n),
    ChallengeKind.hitEarnings => l.chHitEarnings(f.n(c.target)),
    ChallengeKind.buyClocks => l.chBuyClocks(n),
    ChallengeKind.milestones => l.chMilestones(n),
    ChallengeKind.skillLevels => l.chSkillLevels(n),
    ChallengeKind.goldenWeek => l.chGolden(n),
    ChallengeKind.springWeek => l.chSpring(
      (c.target / 3600).toStringAsFixed(c.target % 3600 == 0 ? 0 : 1),
    ),
  };
}

/// "7/12".
String challengeProgress(AppLocalizations l, Fmt f, Challenge c) {
  final t = c.target;
  String count(double v) => c.kind == ChallengeKind.hitEarnings
      ? f.n(v.clamp(0, t))
      : c.kind == ChallengeKind.springWeek
      ? f.duration(v.clamp(0, t))
      : '${v.clamp(0, t).floor()}';
  final total = c.kind == ChallengeKind.hitEarnings
      ? f.n(t)
      : c.kind == ChallengeKind.springWeek
      ? f.duration(t)
      : '${t.round()}';
  return '${count(c.progress)}/$total';
}

class ChallengesPanel extends StatelessWidget {
  const ChallengesPanel({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final daily = c.engine.dailyChallenges;
    final weekly = c.engine.weeklyChallenge;
    final now = DateTime.now();
    final daysLeft = 8 - now.weekday; // Monday starts a new one
    final doneToday = daily.where((d) => d.claimed).length;
    final heading = TextStyle(
      fontFamily: Fonts.display,
      fontSize: 19,
      color: Palette.outline.withValues(alpha: 0.9),
    );
    final hint = TextStyle(
      fontSize: 12.5,
      color: Palette.outline.withValues(alpha: 0.7),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        Text(l.challengesToday, style: heading),
        Text(
          c.engine.challengeRerollOpen
              ? l.challengesRerollHint
              : l.challengesNewTomorrow,
          style: hint,
        ),
        const SizedBox(height: 8),
        for (final ch in daily) _Card(controller: c, challenge: ch),
        _BonusRow(controller: c, done: doneToday, total: daily.length, f: f),
        const SizedBox(height: 18),
        if (weekly != null) ...[
          Text(l.challengesWeek, style: heading),
          Text(l.challengesDaysLeft(daysLeft), style: hint),
          const SizedBox(height: 8),
          _Card(controller: c, challenge: weekly),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.controller, required this.challenge});
  final GameController controller;
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final ch = challenge;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final springs = c.engine.challengeSprings(ch);
    final tiki = c.engine.challengeTiki(ch);
    final reward = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          springs > 0 ? '+$springs ' : '+${f.n(tiki)} ',
          style: const TextStyle(
            fontFamily: Fonts.display,
            fontSize: 14,
            color: Palette.perfectText,
          ),
        ),
        ResIcon(springs > 0 ? Res.spring : Res.tiki, size: 16),
      ],
    );
    final Widget action;
    if (ch.claimed) {
      action = Text(
        '✓ ${l.challengeClaimed}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      );
    } else if (ch.done) {
      action = BuyButton(
        key: Key('challenge-claim-${ch.slot}'),
        price: l.collect,
        enabled: true,
        minWidth: 92,
        onPressed: () => _claim(context, ch),
      );
    } else if (!ch.weekly && c.engine.challengeRerollOpen) {
      action = IconButton(
        key: Key('challenge-reroll-${ch.slot}'),
        tooltip: l.challengeReroll,
        onPressed: () => c.rerollChallenge(ch.slot),
        icon: const Icon(Icons.refresh_rounded, color: Palette.outline),
      );
    } else {
      action = const SizedBox(width: 8);
    }
    return Container(
      key: Key('challenge-${ch.slot}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      decoration: BoxDecoration(
        color: ch.claimed
            ? Palette.great.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ch.done && !ch.claimed ? Palette.perfectDeep : Palette.outline,
          width: ch.done && !ch.claimed ? 3 : 2,
        ),
      ),
      child: Row(
        children: [
          EmojiCard(art: _art[ch.kind]!, size: 46),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challengeText(l, f, ch),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ch.fraction,
                    minHeight: 8,
                    color: ch.done ? Palette.great : Palette.perfect,
                    backgroundColor: Palette.outline.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challengeProgress(l, f, ch),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    reward,
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          action,
        ],
      ),
    );
  }

  void _claim(BuildContext context, Challenge ch) {
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, controller);
    final pay = controller.claimChallenge(ch);
    if (pay.bonus <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.challengeBonusPaid(f.n(pay.bonus))),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// All three today: a bonus on top.
class _BonusRow extends StatelessWidget {
  const _BonusRow({
    required this.controller,
    required this.done,
    required this.total,
    required this.f,
  });
  final GameController controller;
  final int done;
  final int total;
  final Fmt f;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final open = controller.engine.challengeBonusOpen;
    return Container(
      key: const Key('challenge-bonus'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.perfect.withValues(alpha: open ? 0.18 : 0.32),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🎁 '),
          Expanded(
            child: Text(
              open ? l.challengeBonus(done, total) : l.challengeBonusDone,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (open) ...[
            Text(
              '+${f.n(controller.engine.challengeBonusTiki())} ',
              style: const TextStyle(
                fontFamily: Fonts.display,
                fontSize: 14,
                color: Palette.perfectText,
              ),
            ),
            const ResIcon(Res.tiki, size: 16),
          ],
        ],
      ),
    );
  }
}

/// The header badge: today's progress; gold with a dot when a reward is
/// waiting.
class ChallengeBadge extends StatelessWidget {
  const ChallengeBadge({
    super.key,
    required this.controller,
    required this.onTap,
  });
  final GameController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c.state.challenges.isEmpty) return const SizedBox.shrink();
    final daily = c.engine.dailyChallenges;
    final done = daily.where((d) => d.done).length;
    final ready = c.challengesToClaim > 0;
    return GestureDetector(
      key: const Key('open-challenges'),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
        decoration: BoxDecoration(
          color: ready
              ? Palette.perfect.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Palette.outline, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(EmojiArt.path('bullseye'), width: 30, height: 30),
            const SizedBox(width: 4),
            Text(
              ready ? '!' : '$done/${daily.length}',
              style: const TextStyle(fontFamily: Fonts.display, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
