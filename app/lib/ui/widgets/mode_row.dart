import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_controller.dart';
import '../theme.dart';

/// Risk modes, second clock and auto buyer, shown once unlocked
/// (docs/02 §7, §9). Changes apply from the next round (R-TRYB-1).
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
      if (e.blindUnlocked())
        _Toggle(
          key: const Key('mode-blind'),
          label: l.modeBlind,
          on: s.modeBlind,
          onTap: () => c.setMode(blind: !s.modeBlind),
        ),
      if (e.fastUnlocked())
        _Toggle(
          key: const Key('mode-fast'),
          label: l.modeFast,
          on: s.modeFast,
          onTap: () => c.setMode(fast: !s.modeFast),
        ),
      if (s.perks.contains('secondClock'))
        _Toggle(
          key: const Key('mode-second'),
          label: l.modeSecond,
          on: s.secondClockOn,
          onTap: () => c.setMode(secondClock: !s.secondClockOn),
        ),
      if (s.perks.contains('autoBuyer'))
        _Toggle(
          key: const Key('mode-auto'),
          label: l.modeAuto,
          on: s.autoBuyerOn,
          onTap: () => c.setMode(autoBuyer: !s.autoBuyerOn),
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
  });
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: on ? Palette.great : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.outline, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: Fonts.display,
            fontSize: 13,
            color: on ? Colors.white : Palette.outline,
          ),
        ),
      ),
    );
  }
}
