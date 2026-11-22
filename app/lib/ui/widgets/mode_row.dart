import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../screens/loop_screen.dart';
import '../theme.dart';
import 'auto_buyer.dart';

/// Risk modes, second clock and auto buyer, shown once unlocked
/// (docs/02 §7, §9). Changes apply from the next round, Blind switched on
/// before 4.00 at once (R-TRYB-1).
class ModeRow extends StatelessWidget {
  const ModeRow({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final e = c.engine;
    final s = c.state;
    final l = AppLocalizations.of(context);
    final chips = <Widget>[
      if (e.blindForced)
        _Toggle(
          key: const Key('mode-blind'),
          label: l.modeBlind(e.blindMultiplier().round()),
          on: true,
          onTap: () => showChronicle(context, c),
        )
      else if (e.blindUnlocked())
        _Toggle(
          key: const Key('mode-blind'),
          label: l.modeBlind(e.blindMultiplier().round()),
          on: s.modeBlind,
          note: c.blindPending ? l.modeNextRound : null,
          onTap: () => c.setMode(blind: !s.modeBlind),
        ),
      if (s.perks.contains('secondClock'))
        _Toggle(
          key: const Key('mode-second'),
          label: l.modeSecond,
          on: s.secondClockOn,
          onTap: () => c.setMode(secondClock: !s.secondClockOn),
        ),
      if (s.perks.contains('autoBuyer')) AutoBuyerChip(controller: c),
      // The loop and its rule, after the switches: a tap says what it
      // changes (R-PETLA-4).
      if (s.loop > 1)
        _Toggle(
          key: const Key('loop-chip'),
          label: s.loopRules.isEmpty
              ? l.loopNumber(s.loop)
              : '${l.loopNumber(s.loop)} · ${s.loopRules.map((r) => ruleName(l, r)).join(' + ')}',
          on: false,
          onTap: () => showChronicle(context, c),
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final ch in chips)
              Padding(padding: const EdgeInsets.only(right: 6), child: ch),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
    this.note,
  });
  final String label;
  final bool on;
  final VoidCallback onTap;

  /// A second, smaller line: "from the next round" while a switch waits.
  final String? note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        // 36 high: a finger's target without crowding the arena.
        constraints: const BoxConstraints(minHeight: 36),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: on ? Palette.great : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.outline, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: Fonts.display,
                fontSize: 13,
                color: on ? Colors.white : Palette.outline,
              ),
            ),
            if (note != null)
              Text(
                note!,
                key: const Key('mode-note'),
                style: TextStyle(
                  fontSize: 10,
                  color: on ? Colors.white : Palette.outline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
