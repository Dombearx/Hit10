import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/grading.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'sheet.dart';

/// R-STAT-1.
Future<void> showStats(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.statsTitle,
    builder: (context) => _Stats(controller: c),
  );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final s = c.state;
    final st = s.stats;
    final total = st.rounds == 0 ? 1 : st.rounds;
    String pct(Tier t) =>
        '${(st.byTier[t]! * 100 / total).toStringAsFixed(0)}%';
    String ms(double sec) => l.ms(
      (sec * 1000).toStringAsFixed(1).replaceAll('.', l.decimalSeparator),
    );
    final rows = <(String, String)>[
      (l.statEarnedRun, f.n(s.earnedThisRun.floorToDouble())),
      (l.statEarnedTotal, f.n(s.earnedTotal.floorToDouble())),
      (l.statRounds, '${st.rounds}'),
      (l.tierPerfect, pct(Tier.perfect)),
      (l.tierGreat, pct(Tier.great)),
      (l.tierGood, pct(Tier.good)),
      ('${l.missEarly} / ${l.missLate}', pct(Tier.miss)),
      ('${l.statMeanError} (${l.statMeanHint})', ms(st.meanError)),
      (l.statSpread, ms(st.spread)),
      (l.statBestStreak, '${s.lifetime.bestPerfectStreak}'),
      (l.statBestCombo, '${s.lifetime.bestCombo}'),
      (l.statGolden, '${s.lifetime.goldenCaught}'),
      (l.statPlayTime, f.duration(s.lifetime.secondsPlayed)),
      (l.statPrestiges, '${s.prestiges}'),
      (l.statChronons, '${s.chronons}'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final (k, v) in rows)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Palette.outline, width: 2),
            ),
            child: Row(
              children: [
                Expanded(child: Text(k, style: const TextStyle(fontSize: 14))),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    v,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: Fonts.display,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
