import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'catalog.dart';
import 'format.dart';
import 'game_controller.dart';
import 'theme.dart';
import 'widgets/buy_button.dart';
import 'widgets/emoji_card.dart';

/// The daily bonus (playtest 08): a 7-day streak shown as tiles, today's
/// amount counting up, one button to collect.
Future<void> showDailyDialog(BuildContext context, GameController c) {
  final d = c.pendingDaily;
  if (d == null) return Future.value();
  final days = c.balance.daily.minutes.length;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final f = Fmt.of(context, c);
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Palette.outline, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmojiCard(
                art: const EmojiArt('glowing_star', Color(0xFFFFE6A7)),
                size: 72,
              ),
              const SizedBox(height: 12),
              Text(
                l.dailyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 24),
              ),
              Text(l.dailyDay(d.day, days), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= days; i++)
                    _DayTile(day: i, state: i.compareTo(d.day)),
                ],
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: d.amount),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '+${f.n(v)}',
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 40,
                    color: Palette.perfectDeep,
                  ),
                ),
              ),
              Text(
                l.dailyHint(days),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Palette.outline.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              BuyButton(
                key: const Key('daily-collect'),
                price: l.collect,
                enabled: true,
                minWidth: 140,
                onPressed: () {
                  c.collectDaily();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// One day of the streak: done (<0), today (0) or still ahead (>0).
class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.state});
  final int day;
  final int state;

  @override
  Widget build(BuildContext context) {
    final today = state == 0;
    final done = state < 0;
    return Container(
      width: 30,
      height: today ? 40 : 34,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: today
            ? Palette.perfect
            : done
            ? Palette.great.withValues(alpha: 0.35)
            : const Color(0xFFF1ECE4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.outline, width: today ? 2.5 : 1.5),
      ),
      child: Text(
        done ? '✓' : '$day',
        style: TextStyle(
          fontFamily: Fonts.display,
          fontSize: today ? 17 : 14,
          color: Palette.outline.withValues(alpha: today || done ? 1 : 0.5),
        ),
      ),
    );
  }
}
