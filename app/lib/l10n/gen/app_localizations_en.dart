// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hit10';

  @override
  String get tagline => 'Tap at exactly 10.00';

  @override
  String get tikiLabel => 'Ticks';

  @override
  String get tierPerfect => 'PERFECT!';

  @override
  String get tierGreat => 'GREAT!';

  @override
  String get tierGood => 'GOOD';

  @override
  String get missEarly => 'TOO EARLY';

  @override
  String get missLate => 'TOO LATE';

  @override
  String get tapToStart => 'Tap to start';

  @override
  String get decimalSeparator => '.';

  @override
  String get gen_grandpa => 'Grandpa with a Pocket Watch';

  @override
  String get gen_grandpa_desc => '“Back in my day a second lasted longer.”';

  @override
  String get gen_grandma => 'Grandma with an Egg Timer';

  @override
  String get gen_grandma_desc =>
      'Soft-boiled eggs since 1974. Ten seconds? Child\'s play.';

  @override
  String get gen_cuckoo => 'Cuckoo';

  @override
  String get gen_cuckoo_desc => 'Cuckoos every ten seconds. Usually.';

  @override
  String get gen_metronome => 'Metronome';

  @override
  String get gen_metronome_desc => 'Tick. Tock. Tick. Tock. Never gets bored.';

  @override
  String get gen_watchmaker => 'Watchmaker';

  @override
  String get gen_watchmaker_desc => 'Loupe in the eye, peace in the soul.';

  @override
  String get gen_sprintJudge => 'Sprint Judge';

  @override
  String get gen_sprintJudge_desc => 'False start! Then a perfect 10.00.';

  @override
  String get gen_stationClock => 'Station Clock';

  @override
  String get gen_stationClock_desc => 'Delays may vary. Still tries a lot.';

  @override
  String get gen_quartz => 'Quartz Clock';

  @override
  String get gen_quartz_desc => '32,768 wiggles a second, not one too many.';

  @override
  String get gen_atomic => 'Atomic Clock';

  @override
  String get gen_atomic_desc => 'Off by a second every hundred million years.';

  @override
  String get gen_gps => 'GPS Satellite';

  @override
  String get gen_gps_desc =>
      'Knows where you are. And exactly what time it is.';

  @override
  String get gen_pulsar => 'Pulsar';

  @override
  String get gen_pulsar_desc => 'A neutron star that ticks like clockwork.';

  @override
  String get gen_timeMachine => 'Time Machine';

  @override
  String get gen_timeMachine_desc => 'Hits before it taps.';

  @override
  String get gen_schrodinger => 'Schrödinger\'s Cat';

  @override
  String get gen_schrodinger_desc => 'Hit and missed. Until you open the box.';

  @override
  String get gen_chronos => 'Chronos';

  @override
  String get gen_chronos_desc => 'God of time. Never misses. Ever.';

  @override
  String get syn_grandparents => 'Grandparents\' Date Night';

  @override
  String get syn_birdRhythm => 'Bird Rhythm';

  @override
  String get syn_craftsmanship => 'Craft Meets Quartz';

  @override
  String get syn_photoFinish => 'Photo Finish';

  @override
  String get syn_cosmicBeat => 'Cosmic Beat';

  @override
  String get syn_delayedTrain => 'Train from the Future';

  @override
  String perSecond(String value) {
    return '$value/s';
  }

  @override
  String get tabClocks => 'Clocks';

  @override
  String get tabSkills => 'Skills';

  @override
  String get buyAmountMax => 'MAX';

  @override
  String ownedCount(int count) {
    return '×$count';
  }

  @override
  String unitRate(String value) {
    return '$value/s each';
  }

  @override
  String incomeShare(String percent) {
    return '$percent% of income';
  }

  @override
  String windowBonus(String value) {
    return 'windows ×$value';
  }

  @override
  String get lockedName => '???';

  @override
  String get lockedHint => 'Buy the previous clock to reveal';

  @override
  String get upgradesTitle => 'Upgrades';

  @override
  String upgradeName(String generator, String level) {
    return '$generator $level';
  }

  @override
  String upgradeEffect(String generator) {
    return '$generator earn ×2';
  }

  @override
  String upgradeRequires(int count) {
    return 'Needs $count owned';
  }

  @override
  String synergyEffect(String a, String b, String aPct, String bPct) {
    return '$a +$aPct% per $b · $b +$bPct% per $a';
  }

  @override
  String get buy => 'Buy';

  @override
  String cost(String value) {
    return 'Cost: $value';
  }

  @override
  String get offlineTitle => 'While you were away…';

  @override
  String offlineBody(String duration) {
    return 'Your clocks kept ticking for $duration.';
  }

  @override
  String offlineCapped(String duration) {
    return '(counted up to $duration)';
  }

  @override
  String get collect => 'Collect';

  @override
  String durationHm(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationM(int minutes) {
    return '$minutes min';
  }

  @override
  String get saveCorrupt =>
      'Your save could not be read, so the game started fresh.';

  @override
  String get comingSoon => 'Coming soon';
}
