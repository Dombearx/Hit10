import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/game_engine.dart';
import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/buy_button.dart';
import '../widgets/emoji_card.dart';
import 'sheet.dart';

/// Time paradox (docs/02 §9): Chronons, the rewind button, the perk tree.
Future<void> showPrestige(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.prestigeTitle,
    builder: (context) => _Prestige(controller: c),
    // Closing the sheet while choosing perks starts the new run too.
  ).whenComplete(c.finishPrestige);
}

class _Prestige extends StatelessWidget {
  const _Prestige({required this.controller});
  final GameController controller;

  Future<void> _rewind(BuildContext context) async {
    final l = AppLocalizations.of(context);
    Future<bool> ask(String text) async =>
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(text),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              TextButton(
                key: const Key('confirm-yes'),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.yes),
              ),
            ],
          ),
        ) ??
        false;
    // R-PRES-6: two confirmations.
    if (!await ask(l.prestigeConfirm1)) return;
    if (!context.mounted || !await ask(l.prestigeConfirm2)) return;
    if (!context.mounted) return;
    controller.rewindEffects();
    await showRewindAnimation(
      context,
      reduceMotion: controller.settings.reduceMotion,
    );
    // Chronons and Shards now; the run resets when the player has spent
    // the Shards (R-PRES-6a).
    controller.beginPrestige();
  }

  void _startRun(BuildContext context) {
    controller.finishPrestige();
    Navigator.of(context).pop();
  }

  /// Between paying out and resetting: perks first, then the new run.
  Widget _pending(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l.prestigePendingTitle(controller.lastPrestigeGain),
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: Fonts.display, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          l.prestigePendingBody,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        // Habits bought just now can be filled before the reset
        // (R-PRES-5b); otherwise they would wait a whole run.
        if (controller.engine.habitSlots() > 0) ...[
          const SizedBox(height: 10),
          _HabitPicker(controller: controller),
        ],
        const SizedBox(height: 10),
        BuyButton(
          key: const Key('prestige-start'),
          price: l.prestigeStartRun,
          enabled: true,
          minWidth: 180,
          onPressed: () => _startRun(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final s = c.state;
    final gain = c.econ.prestigeGain();
    final nextTotal = c.econ.chrononsTotalFor(s.earnedTotal) + 1;
    final needed =
        c.balance.prestige.divisor *
            math.pow(nextTotal, c.balance.prestige.root) -
        s.earnedTotal;
    final pct = (s.chronons * c.balance.prestige.bonusPerChronon * 100)
        .toStringAsFixed(0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          l.prestigeChronons(s.chronons, pct),
          style: const TextStyle(fontFamily: Fonts.display, fontSize: 18),
        ),
        Text(
          l.prestigeShards(s.shards),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE2D2FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Palette.outline, width: 2.5),
          ),
          child: c.rewindPending
              ? _pending(context)
              : Column(
                  children: [
                    Text(
                      gain > 0
                          ? l.prestigeGain(gain)
                          : l.prestigeNext(f.n(needed)),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (gain > 0) ...[
                      Text(
                        l.prestigeNext(f.n(needed)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Palette.outline.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    BuyButton(
                      key: const Key('prestige-go'),
                      price: l.prestigeButton,
                      enabled: gain > 0,
                      minWidth: 180,
                      onPressed: () => _rewind(context),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Text(
          l.perksTitle,
          style: const TextStyle(fontFamily: Fonts.display, fontSize: 22),
        ),
        const SizedBox(height: 6),
        for (final p in c.balance.prestige.perks)
          _PerkTile(controller: c, id: p.id),
      ],
    );
  }
}

/// Which skills keep every level through this paradox (R-PRES-5b).
class _HabitPicker extends StatelessWidget {
  const _HabitPicker({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final skills = [
      for (final s in c.balance.skills)
        if (c.econ.level(s.id) > 0) s.id,
    ]..sort((a, b) => c.econ.level(b).compareTo(c.econ.level(a)));
    return Column(
      children: [
        Text(
          l.prestigeHabitTitle(
            '${c.engine.activeHabits.length}',
            '${c.engine.habitSlots()}',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final id in skills)
              FilterChip(
                key: Key('habit-$id'),
                label: Text('${skillName(l, id)} ${c.econ.level(id)}'),
                selected: c.engine.activeHabits.contains(id),
                onSelected: (_) => c.toggleHabit(id),
              ),
          ],
        ),
      ],
    );
  }
}

class _PerkTile extends StatelessWidget {
  const _PerkTile({required this.controller, required this.id});
  final GameController controller;
  final String id;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final cfg = c.balance.perk(id);
    final owned = c.state.perks.contains(id);
    final available = c.engine.perkAvailable(id);
    final blocked = !owned && !available;
    return Opacity(
      opacity: blocked ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: owned ? const Color(0xFFE9FBF3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Palette.outline, width: 2),
        ),
        child: Row(
          children: [
            EmojiCard(art: perkArt[id]!, size: 46),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perkName(l, id),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    perkDescription(l, id),
                    style: TextStyle(
                      fontSize: 12,
                      color: Palette.outline.withValues(alpha: 0.75),
                    ),
                  ),
                  if (blocked && cfg.requires != null)
                    Text(
                      l.perkRequires(perkName(l, cfg.requires!)),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Palette.accent,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            BuyButton(
              key: Key('perk-$id'),
              price: owned ? l.perkOwned : '${cfg.cost} ✦',
              enabled: !owned && available && c.state.shards >= cfg.cost,
              minWidth: 72,
              onPressed: () => c.buyPerk(id) == BuyResult.ok,
            ),
          ],
        ),
      ),
    );
  }
}

/// R-PRES-6: the screen "rewinds": digits spin back to 0, then a white
/// flash.
Future<void> showRewindAnimation(
  BuildContext context, {
  bool reduceMotion = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (context, _, _) => _Rewind(reduceMotion: reduceMotion),
  );
}

class _Rewind extends StatefulWidget {
  const _Rewind({required this.reduceMotion});
  final bool reduceMotion;

  @override
  State<_Rewind> createState() => _RewindState();
}

class _RewindState extends State<_Rewind> with SingleTickerProviderStateMixin {
  late final AnimationController _a =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1800),
        )
        ..forward().whenComplete(() {
          if (mounted) Navigator.of(context).pop();
        });

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, _) {
        final k = _a.value;
        final spin = Curves.easeIn.transform(math.min(1, k / 0.8));
        final shown = 99.99 * (1 - spin);
        final flash = widget.reduceMotion || k < 0.8
            ? 0.0
            : (k < 0.9 ? (k - 0.8) / 0.1 : (1 - k) / 0.1);
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Palette.outline.withValues(alpha: 0.85)),
            Center(
              child: Transform.rotate(
                angle: -spin * math.pi * 6,
                child: Text(
                  shown.toStringAsFixed(2).padLeft(5, '0'),
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 72,
                    color: Palette.neonCyan,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: ColoredBox(
                color: Colors.white.withValues(alpha: flash.clamp(0.0, 1.0)),
              ),
            ),
          ],
        );
      },
    );
  }
}
