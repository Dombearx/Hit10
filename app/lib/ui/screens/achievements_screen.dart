import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../achievement_text.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/emoji_card.dart';
import 'sheet.dart';

Future<void> showAchievements(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.achievementsTitle,
    builder: (context) => _Achievements(controller: c),
  );
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final all = c.achievements;
    final got = c.state.achievements;
    final pct = (got.length * c.balance.achievements.bonusEach * 100)
        .toStringAsFixed(0);
    return Column(
      children: [
        Text(
          l.achievementsSummary(got.length, all.length, pct),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 92,
              mainAxisExtent: 112,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: all.length,
            itemBuilder: (context, i) {
              final a = all[i];
              final unlocked = got.contains(a.id);
              final secret = a.hidden && !unlocked;
              final (name, desc) = achievementText(l, f, a);
              return Tooltip(
                message: secret ? l.hiddenAchievement : desc,
                triggerMode: TooltipTriggerMode.tap,
                child: Column(
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.45,
                      child: EmojiCard(
                        art: achievementArt(a),
                        size: 62,
                        circle: true,
                        locked: secret,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      secret ? '???' : name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: Palette.outline.withValues(
                          alpha: unlocked ? 1 : 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
