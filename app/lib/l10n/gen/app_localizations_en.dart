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

  @override
  String get skill_power => 'Strike Power';

  @override
  String get skill_power_desc => 'Every hit pays more.';

  @override
  String get skill_power_label => 'Hit reward';

  @override
  String get skill_fastForward => 'Fast Forward';

  @override
  String get skill_fastForward_desc =>
      'The start of a round flies by. More rounds per minute.';

  @override
  String get skill_fastForward_label => 'Speed up to 9.00';

  @override
  String get skill_ticking => 'Ticking';

  @override
  String get skill_ticking_desc =>
      'A tick in the last second helps you find the beat.';

  @override
  String get skill_ticking_label => 'Ticking';

  @override
  String get skill_wideEye => 'Hawk Eye';

  @override
  String get skill_wideEye_desc =>
      'Wider GREAT and GOOD windows. For you and your clocks.';

  @override
  String get skill_wideEye_label => 'GREAT window';

  @override
  String get skill_combo => 'Combo';

  @override
  String get skill_combo_desc =>
      'A higher streak cap; the streak multiplies the whole payout.';

  @override
  String get skill_combo_label => 'Streak cap';

  @override
  String get skill_magnet => 'Magnet';

  @override
  String get skill_magnet_desc =>
      'A wider PERFECT window. The digits stick to 10.00.';

  @override
  String get skill_magnet_label => 'PERFECT window';

  @override
  String get skill_echo => 'Echo';

  @override
  String get skill_echo_desc =>
      'Hits also pay seconds of your clocks\' income.';

  @override
  String get skill_echo_label => 'Echo';

  @override
  String get skill_bulletTime => 'Bullet Time';

  @override
  String get skill_bulletTime_desc =>
      'Time slows down around 10.00. Easier to hit.';

  @override
  String get skill_bulletTime_label => 'Speed near 10.00';

  @override
  String get skill_luck => 'Luck';

  @override
  String get skill_luck_desc => 'A chance that a hit jumps one tier up.';

  @override
  String get skill_luck_label => 'Chance';

  @override
  String get skill_shield => 'Shield';

  @override
  String get skill_shield_desc =>
      'A miss uses a charge instead of breaking the streak.';

  @override
  String get skill_shield_label => 'Charges';

  @override
  String get skill_goldenTouch => 'Golden Touch';

  @override
  String get skill_goldenTouch_desc =>
      'Golden seconds come more often and hit harder.';

  @override
  String get skill_goldenTouch_label => 'Interval';

  @override
  String skillLevel(int level, int max) {
    return 'Level $level/$max';
  }

  @override
  String skillEffect(String label, String now, String next) {
    return '$label: $now → $next';
  }

  @override
  String skillEffectMax(String label, String now) {
    return '$label: $now';
  }

  @override
  String get skillMaxed => 'MAX';

  @override
  String skillLockedHint(String price) {
    return 'Revealed at $price Ticks';
  }

  @override
  String get on => 'on';

  @override
  String get off => 'off';

  @override
  String get goldenRound => 'GOLDEN ROUND!';

  @override
  String get goldenEscaped => 'It escaped!';

  @override
  String goldenFrenzy(String mult) {
    return 'FRENZY ×$mult!';
  }

  @override
  String goldenLucky(String amount) {
    return 'LUCKY! +$amount';
  }

  @override
  String get goldenHotHand => 'HOT HAND!';

  @override
  String chipFrenzy(String mult) {
    return 'Frenzy ×$mult';
  }

  @override
  String get chipHotHand => 'Hot hand';

  @override
  String get comboLabel => 'COMBO';

  @override
  String streakLabel(int count) {
    return 'streak $count';
  }

  @override
  String get luckyBump => 'LUCKY!';

  @override
  String get shieldSaved => 'SHIELD!';

  @override
  String ach_earned(String amount) {
    return 'Earned $amount';
  }

  @override
  String ach_earned_desc(String amount) {
    return 'Earn $amount Ticks in total';
  }

  @override
  String ach_owned(String generator, String count) {
    return '$generator ×$count';
  }

  @override
  String ach_owned_desc(String generator, String count) {
    return 'Own $count × $generator';
  }

  @override
  String ach_perfects(String count) {
    return 'Perfectionist $count';
  }

  @override
  String ach_perfects_desc(String count) {
    return 'Hit PERFECT $count times';
  }

  @override
  String ach_perfectStreak(String count) {
    return 'Flawless $count';
  }

  @override
  String ach_perfectStreak_desc(String count) {
    return '$count PERFECTs in a row';
  }

  @override
  String ach_combo(String count) {
    return 'Combo $count';
  }

  @override
  String ach_combo_desc(String count) {
    return 'Reach a streak of $count';
  }

  @override
  String ach_golden(String count) {
    return 'Gold digger $count';
  }

  @override
  String ach_golden_desc(String count) {
    return 'Catch $count golden seconds';
  }

  @override
  String ach_prestige(String count) {
    return 'Time traveller $count';
  }

  @override
  String ach_prestige_desc(String count) {
    return 'Prestige $count times';
  }

  @override
  String get ach_mode_blind => 'Blindfolded';

  @override
  String get ach_mode_blind_desc => 'PERFECT in blind mode';

  @override
  String get ach_mode_fast => 'Quick hands';

  @override
  String get ach_mode_fast_desc => 'PERFECT on the fast clock';

  @override
  String get ach_mode_both => 'Madman';

  @override
  String get ach_mode_both_desc => 'PERFECT with both modes on';

  @override
  String get ach_hidden_impatient => 'Impatient';

  @override
  String get ach_hidden_impatient_desc => 'TOO EARLY 100 times';

  @override
  String get ach_hidden_nap => 'Nap time';

  @override
  String get ach_hidden_nap_desc => '10 rounds in a row without a tap';

  @override
  String get ach_hidden_almost => 'So close';

  @override
  String get ach_hidden_almost_desc => '9.99, then 10.01';

  @override
  String get ach_hidden_punctual => 'Punctual';

  @override
  String get ach_hidden_punctual_desc => 'PERFECT at 10:00 in the morning';

  @override
  String get ach_hidden_tenth => 'Ten out of ten';

  @override
  String get ach_hidden_tenth_desc => '10 PERFECTs on the 10th of a month';

  @override
  String get ach_hidden_fullCollection => 'Full collection';

  @override
  String get ach_hidden_fullCollection_desc => 'Every skill maxed out';

  @override
  String get ach_hidden_museum => 'Museum';

  @override
  String get ach_hidden_museum_desc => 'One of every clock';

  @override
  String get ach_hidden_boiledEgg => 'Soft-boiled';

  @override
  String get ach_hidden_boiledEgg_desc => '100 grandmas';

  @override
  String get perk_headStart => 'Head start';

  @override
  String get perk_headStart_desc =>
      'Start each run with 10 grandpas and 1K Ticks';

  @override
  String get perk_muscleMemory1 => 'Muscle memory I';

  @override
  String get perk_muscleMemory1_desc => 'Fast Forward survives the paradox';

  @override
  String get perk_muscleMemory2 => 'Muscle memory II';

  @override
  String get perk_muscleMemory2_desc => 'Hawk Eye and Magnet survive too';

  @override
  String get perk_muscleMemory3 => 'Muscle memory III';

  @override
  String get perk_muscleMemory3_desc => 'Other skills keep half their level';

  @override
  String get perk_longNap1 => 'Long nap I';

  @override
  String get perk_longNap1_desc => 'Offline limit 12 h';

  @override
  String get perk_longNap2 => 'Long nap II';

  @override
  String get perk_longNap2_desc => 'Offline limit 24 h';

  @override
  String get perk_deepSleep1 => 'Deep sleep I';

  @override
  String get perk_deepSleep1_desc => 'Offline at 75 %';

  @override
  String get perk_deepSleep2 => 'Deep sleep II';

  @override
  String get perk_deepSleep2_desc => 'Offline at 100 %';

  @override
  String get perk_goldRush => 'Gold rush';

  @override
  String get perk_goldRush_desc => 'Golden seconds 15 % more often';

  @override
  String get perk_startShield => 'Shield at start';

  @override
  String get perk_startShield_desc =>
      'One shield charge, even without the skill';

  @override
  String get perk_comboFloor => 'Soft landing';

  @override
  String get perk_comboFloor_desc => 'A miss drops the streak to 5, not 0';

  @override
  String get perk_autoBuyer => 'Auto buyer';

  @override
  String get perk_autoBuyer_desc =>
      'A switch that buys the cheapest clock every 5 s';

  @override
  String get perk_earlyModes => 'Daredevil';

  @override
  String get perk_earlyModes_desc => 'Risk modes unlocked from the start';

  @override
  String get perk_unlockSchrodinger => 'The box';

  @override
  String get perk_unlockSchrodinger_desc => 'Unlocks Schrödinger\'s Cat';

  @override
  String get perk_secondClock => 'Second clock';

  @override
  String get perk_secondClock_desc => 'Play two stopwatches at once';

  @override
  String get perk_unlockChronos => 'Altar of Chronos';

  @override
  String get perk_unlockChronos_desc => 'Unlocks Chronos';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsSummary(int count, int total, String percent) {
    return '$count/$total · +$percent% income';
  }

  @override
  String achievementsUnlocked(int count) {
    return '$count achievements unlocked!';
  }

  @override
  String get achievementUnlocked => 'Achievement unlocked!';

  @override
  String get hiddenAchievement => 'Hidden achievement';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statEarnedRun => 'Earned this run';

  @override
  String get statEarnedTotal => 'Earned in total';

  @override
  String get statRounds => 'Rounds';

  @override
  String get statTiers => 'Hits';

  @override
  String get statMeanError => 'Average error';

  @override
  String get statSpread => 'Spread';

  @override
  String get statMeanHint => 'negative = you tap early';

  @override
  String get statBestStreak => 'Best PERFECT streak';

  @override
  String get statBestCombo => 'Highest combo';

  @override
  String get statGolden => 'Golden seconds caught';

  @override
  String get statPlayTime => 'Time played';

  @override
  String get statPrestiges => 'Prestiges';

  @override
  String get statChronons => 'Chronons';

  @override
  String ms(String value) {
    return '$value ms';
  }

  @override
  String get prestigeTitle => 'Time paradox';

  @override
  String prestigeChronons(int count, String percent) {
    return 'Chronons: $count (+$percent% forever)';
  }

  @override
  String prestigeShards(int count) {
    return 'Time shards: $count';
  }

  @override
  String prestigeGain(int count) {
    return 'Rewind now for +$count Chronons';
  }

  @override
  String prestigeNext(String amount) {
    return '$amount more Ticks for the next Chronon';
  }

  @override
  String get prestigeButton => 'Rewind time';

  @override
  String get prestigeConfirm1 =>
      'You lose your clocks, skills and Ticks. Chronons, perks and achievements stay. Continue?';

  @override
  String get prestigeConfirm2 => 'Really? Time will rewind.';

  @override
  String get perksTitle => 'Perks';

  @override
  String perkRequires(String name) {
    return 'Needs: $name';
  }

  @override
  String get perkOwned => 'Owned';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get skip => 'Skip';

  @override
  String get modeBlind => 'Blind ×3';

  @override
  String get modeFast => 'Fast clock ×2';

  @override
  String get modeSecond => 'Second clock';

  @override
  String get modeAuto => 'Auto buyer';

  @override
  String get adTurbo => 'Turbo ×2';

  @override
  String adTurboLeft(String time) {
    return '×2 · $time';
  }

  @override
  String get adGolden => 'Golden second';

  @override
  String adBag(int minutes) {
    return '+$minutes min';
  }

  @override
  String adRescue(int count) {
    return 'Streak $count lost! Restore';
  }

  @override
  String get adDouble => 'Double it';

  @override
  String get adUnavailable => 'No ad right now';

  @override
  String adCooldown(String time) {
    return 'in $time';
  }

  @override
  String get adFull => 'Full';

  @override
  String get tutorialAim => 'Tap when the clock shows exactly 10.00';

  @override
  String get tutorialBuy => 'Buy a grandpa: he will try for you!';

  @override
  String get tutorialInfo =>
      'Grandpa tries every 10 seconds. More clocks, more Ticks!';

  @override
  String get tutorialGotIt => 'Got it!';

  @override
  String get tip_skills => 'New skill! Check the Skills tab.';

  @override
  String get tip_golden =>
      'A golden second! Catch the flying clock: the next round turns golden.';

  @override
  String get tip_combo =>
      'A streak! GREAT and PERFECT hits keep raising the multiplier.';

  @override
  String get tip_prestige =>
      'You can rewind time: a prestige gives Chronons, a permanent bonus.';

  @override
  String notificationTitle(String amount) {
    return 'Your clocks collected $amount Ticks! Come back for more.';
  }

  @override
  String get notificationAsk => 'Shall we tell you when your clocks are full?';
}
