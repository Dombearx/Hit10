import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'sheet.dart';

/// "How to play": what every part of the screen is for (playtest: players
/// didn't know what the clocks, skills or the "0/5" badge meant).
Future<void> showHelp(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.helpTitle,
    builder: (context) => _Help(controller: c),
  );
}

class _Help extends StatelessWidget {
  const _Help({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sections = <(String, String, String)>[
      ('stopwatch', l.help_goal_t, l.help_goal),
      ('coin', l.help_tiki_t, l.help_tiki),
      ('shopping_cart', l.help_clocks_t, l.help_clocks),
      ('sparkles', l.help_upgrades_t, l.help_upgrades),
      ('flexed_biceps', l.help_skills_t, l.help_skills),
      ('fire', l.help_combo_t, l.help_combo),
      ('glowing_star', l.help_golden_t, l.help_golden),
      ('see_no_evil_monkey', l.help_modes_t, l.help_modes),
      ('wrapped_gift', l.help_season_t, l.help_season),
      ('cyclone', l.help_prestige_t, l.help_prestige),
      ('red_question_mark', l.help_icons_t, l.help_icons),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // Titles only; a tap opens one (a scannable list, not a wall of
        // text).
        for (final (i, (emoji, title, body)) in sections.indexed)
          Container(
            key: Key('help-$emoji'),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Palette.outline, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: i == 0,
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.fromLTRB(56, 0, 14, 12),
              expandedAlignment: Alignment.centerLeft,
              leading: Image.asset(EmojiArt.path(emoji), width: 30, height: 30),
              title: Text(
                title,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 18),
              ),
              iconColor: Palette.outline,
              collapsedIconColor: Palette.outline,
              children: [
                Text(body, style: const TextStyle(fontSize: 14, height: 1.35)),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            key: const Key('help-replay'),
            onPressed: () {
              controller.replayTutorial();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.replay, color: Palette.outline),
            label: Text(
              l.helpReplay,
              style: const TextStyle(
                color: Palette.outline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
