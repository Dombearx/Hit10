import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';

/// One line over the shop: what to aim for next, with its progress as the
/// pill's fill (R-TUT-7), for the whole game.
class NextGoalBar extends StatelessWidget {
  const NextGoalBar({super.key, required this.controller, required this.onTap});
  final GameController controller;

  /// Opens the place the goal is reached in.
  final ValueChanged<NextGoal> onTap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final goal = c.nextGoal;
    if (goal == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final id = goal.generator;
    final text = switch (goal.kind) {
      GoalKind.bonus => l.goalBonus(
        generatorName(l, id!),
        '${goal.have.round()}',
        '${goal.need.round()}',
        f.round(c.econ.milestoneMultiplier(id)),
      ),
      GoalKind.newClock => l.goalNewClock(generatorName(l, id!)),
      GoalKind.loopBonus => l.goalLoopBonus(
        generatorName(l, id!),
        '${goal.have.round()}',
        '${goal.need.round()}',
      ),
      GoalKind.prestige =>
        c.state.prestiges == 0
            ? l.goalPrestige
            : goal.perk != null
            ? l.goalPrestigePerk(perkName(l, goal.perk!))
            : l.goalPrestigeDouble,
      GoalKind.perk =>
        goal.have >= goal.need
            ? l.goalPerkBuy(perkName(l, goal.perk!))
            : l.goalPerk(
                perkName(l, goal.perk!),
                '${goal.have.round()}',
                '${goal.need.round()}',
              ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: GestureDetector(
        key: Key('next-goal-${goal.kind.name}'),
        onTap: () => onTap(goal),
        child: Container(
          height: 32,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Palette.outline, width: 2),
          ),
          child: Stack(
            children: [
              if (goal.kind != GoalKind.prestige)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: goal.progress,
                    child: const ColoredBox(color: Palette.perfect),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Palette.outline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
