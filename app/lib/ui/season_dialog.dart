import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';
import 'format.dart';
import 'game_controller.dart';
import 'seasons_ui.dart';
import 'theme.dart';
import 'widgets/buy_button.dart';
import 'widgets/emoji_card.dart';

/// The running calendar event (docs/02 §14): what to do, how far along the
/// player is and what it pays. Also its intro when the season starts.
Future<void> showSeasonDialog(BuildContext context, GameController c) {
  final season = c.season;
  if (season == null) return Future.value();
  return showDialog<void>(
    context: context,
    builder: (context) => ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final f = Fmt.of(context, c);
        final cfg = c.balance.seasons;
        final look = seasonLooks[season.id]!;
        final name = seasonName(l, season.id);
        final done = c.engine.seasonDone;
        final until = DateFormat.MMMMd(l.localeName).format(season.to);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color.lerp(look.tint, Colors.white, 0.3)!,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Palette.outline, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmojiCard(art: look.art, size: 72),
                const SizedBox(height: 10),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 24,
                  ),
                ),
                Text(l.seasonUntil(until), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(l.seasonHow, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                _Progress(
                  icon: look.item,
                  label: seasonItems(l, season.id),
                  value: c.state.seasonCatches,
                  goal: cfg.catches,
                  done: done,
                ),
                const SizedBox(height: 6),
                _Progress(
                  icon: 'bullseye',
                  label: l.seasonHits,
                  value: c.state.seasonHits,
                  goal: cfg.hits,
                  done: done,
                ),
                const SizedBox(height: 12),
                Text(
                  done
                      ? l.seasonDone(name)
                      : l.seasonReward(f.n(c.engine.seasonReward()), name),
                  key: const Key('season-reward'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: done ? Palette.great : Palette.outline,
                  ),
                ),
                const SizedBox(height: 14),
                BuyButton(
                  key: const Key('season-ok'),
                  price: l.seasonStart,
                  enabled: true,
                  celebrate: false,
                  minWidth: 140,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.icon,
    required this.label,
    required this.value,
    required this.goal,
    required this.done,
  });
  final String icon;
  final String label;
  final int value;
  final int goal;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final v = done ? goal : value.clamp(0, goal);
    return Row(
      children: [
        Image.asset('assets/emoji/$icon.png', width: 26, height: 26),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('$v/$goal'),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: v / goal,
                  minHeight: 8,
                  color: v >= goal ? Palette.great : Palette.perfect,
                  backgroundColor: const Color(0xFFF1ECE4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The season's badge in the header: its emoji and how far along.
class SeasonBadge extends StatelessWidget {
  const SeasonBadge({super.key, required this.controller, required this.onTap});
  final GameController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final season = c.season;
    if (season == null) return const SizedBox.shrink();
    final look = seasonLooks[season.id]!;
    final cfg = c.balance.seasons;
    final done = c.engine.seasonDone;
    final text = done
        ? '✓'
        : '${c.state.seasonCatches.clamp(0, cfg.catches)}/${cfg.catches} · '
              '${c.state.seasonHits.clamp(0, cfg.hits)}/${cfg.hits}';
    return GestureDetector(
      key: const Key('open-season'),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Palette.outline, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/emoji/${look.badge}.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(fontFamily: Fonts.display, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
