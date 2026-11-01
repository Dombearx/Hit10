import 'package:flutter/material.dart';

import '../../engine/round_engine.dart';
import '../../l10n/gen/app_localizations.dart';
import '../game_controller.dart';
import '../theme.dart';

/// ⏸ / ▶ above the dial (docs/04 U-29): stops the stopwatch on purpose
/// (no penalty, the streak stays), or starts the next round.
class PauseButton extends StatelessWidget {
  const PauseButton({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.state.tutorialDone) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final stopped = c.clocks.every((s) => s.round.phase == RoundPhase.waiting);
    return Semantics(
      button: true,
      label: stopped ? l.resume : l.pause,
      child: GestureDetector(
        key: const Key('pause-button'),
        behavior: HitTestBehavior.opaque,
        onTap: c.togglePause,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: stopped
                ? Palette.perfect
                : Colors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Palette.outline, width: 2),
          ),
          child: Icon(
            stopped ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: Palette.outline,
            size: 26,
          ),
        ),
      ),
    );
  }
}
