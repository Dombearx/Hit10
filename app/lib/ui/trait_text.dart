import '../l10n/gen/app_localizations.dart';
import '../l10n/master_texts.dart';
import '../model/economy.dart';
import 'format.dart';

/// Name and text of clock [id]'s trait [tier] (1 at the first master
/// title, 2 at the second; docs/18 §4), its numbers taken from the balance
/// file so the text always says what the game does.
(String, String) traitText(
  AppLocalizations l,
  Fmt f,
  Economy econ,
  String id,
  int tier,
) {
  final b = econ.b;
  final p = b.traits.of(id, tier - 1);
  double v(String k) => p[k] ?? 0;
  String pct(double x) => '${(x * 100).round()}%';
  String count(double x) => '${x.round()}';
  final args = switch ((id, tier)) {
    ('grandpa', 1) => [f.duration(v('offlineCapHours') * 3600)],
    ('grandpa', 2) => [pct(v('offlineEfficiency'))],
    ('grandma', 2) => [count(v('lastDaySprings'))],
    ('metronome', 1) => [f.mult(v('reserveRefill'))],
    ('metronome', 2) => [f.mult(v('reserve'))],
    ('watchmaker', _) => [pct(1 - v('perkCost'))],
    ('sprintJudge', 1) => [
      f.duration(v('warmUpAwaySeconds')),
      count(v('warmUpHits')),
      f.mult(v('warmUpMax')),
    ],
    ('sprintJudge', 2) => [count(v('warmUpHits'))],
    ('stationClock', 1) => [pct(v('goldenOften') - 1)],
    ('stationClock', 2) => [count(v('expressEvery'))],
    ('quartz', 1) => [pct(v('clocks'))],
    ('quartz', 2) => [
      pct(v('syncPerClock')),
      pct(v('syncPerClock') * econ.clocksAtTopTier),
    ],
    ('atomic', _) => [f.duration(v('secondsPerSpring'))],
    ('gps', 1) => [v('dailyAllSpring') == 0.5 ? '½' : pct(v('dailyAllSpring'))],
    ('gps', 2) => [count(v('weeklySprings'))],
    ('pulsar', 1) => [pct(v('goldenStrength') - 1)],
    ('pulsar', 2) => [pct(v('frenzyDuration') - 1)],
    ('timeMachine', _) => [count(v('loopChronons'))],
    ('schrodinger', 1) => [pct(v('coinChance')), pct(v('coinBonus'))],
    ('schrodinger', 2) => [pct(v('coinBonus'))],
    ('chronos', 1) => [
      count(v('chronosPerkCost')),
      '${b.perk('unlockChronos').cost}',
    ],
    ('chronos', 2) => [count(v('goalBonusSprings'))],
    _ => const <String>[],
  };
  return traitTexts(l, id, tier, args) ?? ('', '');
}
