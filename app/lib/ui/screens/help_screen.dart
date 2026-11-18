import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/res_text.dart';
import 'sheet.dart';

/// "How to play": how each system works, one card each (playtest: players
/// didn't know what the clocks, skills or the "0/5" badge meant). Systems
/// not met yet stay hidden behind "???" (playtest: reading about Chronons
/// in the first minute spoiled more than it helped).
Future<void> showHelp(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.helpTitle,
    builder: (context) => _Help(controller: c),
  );
}

/// One card: its icon, title, body and whether the player has met it.
typedef _Section = ({String emoji, String title, String body, bool open});

class _Help extends StatelessWidget {
  const _Help({required this.controller});
  final GameController controller;

  List<_Section> _sections(AppLocalizations l) {
    final c = controller;
    final s = c.state;
    final started = s.tutorialDone || s.prestiges > 0 || s.loopsDone > 0;
    final paradox = s.prestiges > 0 || s.loop > 1 || s.loopsDone > 0;
    final loop = s.loopGoal || s.loop > 1 || s.loopsDone > 0;
    final modes =
        c.engine.blindUnlocked() ||
        s.perks.contains('secondClock') ||
        s.perks.contains('autoBuyer') ||
        s.secondClockOn ||
        s.autoBuyerOn;
    _Section sec(String emoji, String title, String body, bool open) =>
        (emoji: emoji, title: title, body: body, open: open);
    return [
      sec('chronos', l.help_goal_t, l.help_goal, true),
      sec('stopwatch', l.help_round_t, l.help_round, true),
      sec('coin', l.help_tiki_t, l.help_tiki, true),
      sec('money_bag', l.help_res_t, _resources(l), true),
      sec('shopping_cart', l.help_clocks_t, l.help_clocks, true),
      sec('fire', l.help_combo_t, l.help_combo, true),
      sec('sparkles', l.help_upgrades_t, l.help_upgrades, s.owned.isNotEmpty),
      sec(
        'flexed_biceps',
        l.help_skills_t,
        l.help_skills,
        started || s.skills.isNotEmpty,
      ),
      sec('glowing_star', l.help_golden_t, l.help_golden, started),
      sec('see_no_evil_monkey', l.help_modes_t, l.help_modes, modes),
      sec(
        'wrapped_gift',
        l.help_season_t,
        l.help_season,
        c.season != null || s.seasonsDone.isNotEmpty,
      ),
      sec(
        'cyclone',
        l.help_prestige_t,
        l.help_prestige,
        paradox || c.engine.canPrestige(),
      ),
      sec('gear', l.help_springs_t, l.help_springs, c.econ.springsUnlocked),
      sec('classical_building', l.help_loop_t, l.help_loop, loop),
      sec(
        'sun_with_face',
        l.help_dials_t,
        l.help_dials,
        c.econ.unlockedDials.length > 1,
      ),
      sec('red_question_mark', l.help_icons_t, l.help_icons, true),
    ];
  }

  /// The resources met so far, one line each, every name with its icon.
  String _resources(AppLocalizations l) {
    final s = controller.state;
    final paradox = s.prestiges > 0 || s.loop > 1 || s.loopsDone > 0;
    return [
      l.help_res_tiki,
      if (paradox) l.help_res_chronon,
      if (paradox) l.help_res_shard,
      if (controller.econ.springsUnlocked) l.help_res_spring,
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sections = _sections(l);
    final open = [
      for (final s in sections)
        if (s.open) s,
    ];
    final locked = sections.length - open.length;
    // A plain column: a few cards, all built (no lazy list needed).
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titles only; a tap opens one (a scannable list, not a wall of
          // text).
          for (final (i, sec) in open.indexed)
            _card(
              key: Key('help-${sec.emoji}'),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: const EdgeInsets.fromLTRB(56, 0, 14, 12),
                expandedAlignment: Alignment.centerLeft,
                leading: Image.asset(
                  EmojiArt.path(sec.emoji),
                  width: 30,
                  height: 30,
                ),
                title: Text(
                  sec.title,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 18,
                  ),
                ),
                iconColor: Palette.outline,
                collapsedIconColor: Palette.outline,
                children: [
                  ResText(
                    sec.body,
                    style: const TextStyle(fontSize: 14.5, height: 1.4),
                  ),
                ],
              ),
            ),
          // What is still ahead: as many "???" as there are hidden systems,
          // and one line on how to get them.
          for (var i = 0; i < locked; i++)
            _card(
              key: Key('help-locked-$i'),
              color: Palette.paper,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Image.asset(
                  EmojiArt.path('locked'),
                  width: 30,
                  height: 30,
                  opacity: const AlwaysStoppedAnimation(0.55),
                ),
                title: Text(
                  '???',
                  style: TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 18,
                    color: Palette.outline.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          if (locked > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
              child: Text(
                l.helpLocked,
                key: const Key('help-locked-hint'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Palette.outline.withValues(alpha: 0.7),
                ),
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
      ),
    );
  }

  Widget _card({
    required Key key,
    required Widget child,
    Color color = Colors.white,
  }) => Container(
    key: key,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Palette.outline, width: 2),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}
