import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../format.dart';
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
    final f = Fmt.of(context, c);
    final step = c.tutorialStep;
    final grandpa = c.balance.generators.first;
    String? text;
    // Steps that only explain have a "Next"/"Got it" button; the others
    // wait for the player to do it, with "Skip".
    String? ok;
    VoidCallback? onOk;
    var pointsDown = false;
    switch (step) {
      case TutorialStep.aim:
        text = l.tutorialAim;
      case TutorialStep.earned:
        text = l.tutorialEarned(f.n(grandpa.baseCost));
        pointsDown = true;
      case TutorialStep.buyGrandpa:
        text = l.tutorialBuy(f.n(grandpa.baseCost));
        pointsDown = true;
      case TutorialStep.grandpaInfo:
        text = l.tutorialInfo(
          f.n(c.econ.unitRate(grandpa.id) * c.econ.permanentMultiplier()),
        );
        ok = l.tutorialNext;
        onOk = c.nextTutorialStep;
      case TutorialStep.shopTour:
        text = l.tutorialShop;
        ok = l.tutorialGotIt;
        onOk = c.nextTutorialStep;
        pointsDown = true;
      case TutorialStep.done:
        final tip = c.pendingTip;
        if (tip != null) {
          text = switch (tip) {
            'skills' => l.tip_skills,
            'golden' => l.tip_golden,
            'combo' => l.tip_combo,
            'prestige' => l.tip_prestige,
            'upgrade' => l.tip_upgrade,
            'modes' => l.tip_modes,
            _ => null,
          };
          ok = l.tutorialGotIt;
          onOk = c.dismissTip;
          pointsDown = tip == 'skills' || tip == 'upgrade' || tip == 'modes';
        }
    }
    if (text == null) return const SizedBox.shrink();
    final done = step == TutorialStep.done;
    return Container(
      key: Key(done ? 'tip-${c.pendingTip}' : 'tutorial-${step.name}'),
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: Palette.outline.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.perfect, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            pointsDown ? Icons.arrow_downward_rounded : Icons.lightbulb,
            color: Palette.perfect,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (ok != null)
            TextButton(
              key: const Key('tutorial-ok'),
              onPressed: onOk,
              child: Text(ok, style: const TextStyle(color: Palette.perfect)),
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
