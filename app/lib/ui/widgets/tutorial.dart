import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_controller.dart';
import '../theme.dart';

/// First-run guidance (R-TUT-1) and one-time tips (R-TUT-2).
class TutorialBubble extends StatelessWidget {
  const TutorialBubble({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final step = c.tutorialStep;
    String? text;
    var showOk = false;
    switch (step) {
      case TutorialStep.aim:
        text = l.tutorialAim;
      case TutorialStep.buyGrandpa:
        text = l.tutorialBuy;
      case TutorialStep.grandpaInfo:
        text = l.tutorialInfo;
        showOk = true;
      case TutorialStep.done:
        final tip = c.pendingTip;
        if (tip != null) {
          text = switch (tip) {
            'skills' => l.tip_skills,
            'golden' => l.tip_golden,
            'combo' => l.tip_combo,
            'prestige' => l.tip_prestige,
            'early' => l.tip_early(c.state.stats.meanError.abs().ms),
            'late' => l.tip_late(c.state.stats.meanError.abs().ms),
            _ => null,
          };
          showOk = true;
        }
    }
    if (text == null) return const SizedBox.shrink();
    final done = step == TutorialStep.done;
    return Container(
      key: Key(done ? 'tip-${c.pendingTip}' : 'tutorial-${step.name}'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: Palette.outline.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showOk)
            TextButton(
              key: const Key('tutorial-ok'),
              onPressed: done ? c.dismissTip : c.finishTutorial,
              child: Text(
                l.tutorialGotIt,
                style: const TextStyle(color: Palette.perfect),
              ),
            )
          else
            TextButton(
              key: const Key('tutorial-skip'),
              onPressed: c.finishTutorial,
              child: Text(
                l.skip,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
        ],
      ),
    );
  }
}

extension on double {
  /// Seconds as whole milliseconds.
  int get ms => (this * 1000).round();
}
