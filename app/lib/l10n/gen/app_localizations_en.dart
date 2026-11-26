// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hit5';

  @override
  String get tagline => 'Tap at exactly 5.00';

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
  String get missClose => 'CLOSE!';

  @override
  String get arenaLabel => 'Stopwatch. Stop it at exactly 5.00.';

  @override
  String get tapToStart => 'Tap to start';

  @override
  String get pausedTapToPlay => 'Paused · tap to play';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Play';

  @override
  String get decimalSeparator => '.';

  @override
  String get gen_grandpa => 'Grandpa with a Pocket Watch';

  @override
  String get gen_grandpa_desc =>
      'Grandpa: “My father\'s watch. Runs like a dream.”\nGrandma: “Dreams don\'t run on time.”';

  @override
  String get gen_grandma => 'Grandma with an Egg Timer';

  @override
  String get gen_grandma_desc =>
      'Grandma: “Egg timer from seventy-four. Never late once.”\nGrandpa: “It never has to go anywhere.”';

  @override
  String get gen_cuckoo => 'Cuckoo';

  @override
  String get gen_cuckoo_desc =>
      'Grandpa: “Cuckoos every five seconds exactly.”\nGrandma: “It did. Before you fixed it.”';

  @override
  String get gen_metronome => 'Metronome';

  @override
  String get gen_metronome_desc =>
      'Grandpa: “I learned to dance with this.”\nGrandma: “You didn\'t, though.”';

  @override
  String get gen_watchmaker => 'Watchmaker';

  @override
  String get gen_watchmaker_desc =>
      'Grandpa: “Mr Henry. He can fix any watch.”\nGrandma: “He hands yours back without a word.”';

  @override
  String get gen_sprintJudge => 'Sprint Judge';

  @override
  String get gen_sprintJudge_desc =>
      'Grandpa: “Knows what a hundredth of a second is.”\nGrandma: “Do you know what five p.m. is?”';

  @override
  String get gen_stationClock => 'Station Clock';

  @override
  String get gen_stationClock_desc =>
      'Grandpa: “Always late, but it always gets there.”\nGrandma: “So do you. That\'s why you like it.”';

  @override
  String get gen_quartz => 'Quartz Clock';

  @override
  String get gen_quartz_desc =>
      'Grandpa: “32,768 vibrations a second.”\nGrandma: “And you don\'t budge until I call you for dinner.”';

  @override
  String get gen_atomic => 'Atomic Clock';

  @override
  String get gen_atomic_desc =>
      'Grandpa: “Off by a second every hundred million years. Now I\'ll make it.”\nGrandma: “You said that about the cuckoo.”';

  @override
  String get gen_gps => 'GPS Satellite';

  @override
  String get gen_gps_desc =>
      'Grandpa: “Knows where I am to the metre.”\nGrandma: “So do I. The garage.”';

  @override
  String get gen_pulsar => 'Pulsar';

  @override
  String get gen_pulsar_desc =>
      'Grandpa: “A star that ticks. Borrowed from space.”\nGrandma: “You\'ll return it like my drill.”';

  @override
  String get gen_timeMachine => 'Time Machine';

  @override
  String get gen_timeMachine_desc =>
      'Grandpa: “If only I\'d had this in seventy-four… But I made it anyway!”\nGrandma: “Mm-hm.”';

  @override
  String get gen_schrodinger => 'Schrödinger\'s Cat';

  @override
  String get gen_schrodinger_desc =>
      'Grandpa: “Hit and missed at the same time.”\nGrandma: “Like you with anniversary flowers.”';

  @override
  String get gen_chronos => 'Chronos';

  @override
  String get gen_chronos_desc =>
      'Grandpa: “Time itself. The most accurate clock in the world.”\nGrandma: “You don\'t buy time. You invite it.”';

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
  String get lockedName => '???';

  @override
  String get lockedHint => 'Buy the previous clock to reveal';

  @override
  String get lockedKeyHint => 'Locked — the key is among the paradox perks';

  @override
  String get upgradesTitle => 'Upgrades';

  @override
  String upgradeRequires(int count) {
    return 'Needs $count owned';
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
  String durationH(int hours) {
    return '$hours h';
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
  String get skill_power_desc => 'More Ticks for every hit.';

  @override
  String get skill_power_label => 'Ticks per PERFECT';

  @override
  String get skill_fastForward => 'Late Start';

  @override
  String get skill_fastForward_desc =>
      'The stopwatch starts from a higher value, so a round is shorter.';

  @override
  String get skill_fastForward_label => 'Stopwatch starts at';

  @override
  String get skill_ticking => 'Ticking';

  @override
  String get skill_ticking_desc =>
      'Ticking in the last second before the target.';

  @override
  String get skill_ticking_label => 'Ticking';

  @override
  String get skill_wideEye => 'Hawk Eye';

  @override
  String get skill_wideEye_desc =>
      'Wider GREAT and GOOD windows. Yours and your clocks\'.';

  @override
  String get skill_wideEye_label => 'GREAT / GOOD';

  @override
  String get skill_combo => 'Combo';

  @override
  String get skill_combo_desc => 'A higher cap on the multiplier.';

  @override
  String get skill_combo_label => 'Multiplier up to';

  @override
  String get skill_magnet => 'Magnet';

  @override
  String get skill_magnet_desc =>
      'A wider PERFECT window. Yours and your clocks\'.';

  @override
  String get skill_magnet_label => 'PERFECT window';

  @override
  String get skill_echo => 'Echo';

  @override
  String get skill_echo_desc =>
      'A hit adds the Ticks your clocks make in a fraction of a second.';

  @override
  String get skill_echo_label => 'PERFECT adds clock time';

  @override
  String get skill_bulletTime => 'Cold Blood';

  @override
  String get skill_bulletTime_desc =>
      'All your windows wider. Doesn\'t work on clocks.';

  @override
  String get skill_bulletTime_label => 'Your GOOD window';

  @override
  String get skill_luck => 'Luck';

  @override
  String get skill_luck_desc => 'Some hits land a tier higher.';

  @override
  String get skill_luck_label => 'Hits bumped a tier up';

  @override
  String get skill_shield => 'Shield';

  @override
  String get skill_shield_desc =>
      'A miss uses a charge instead of resetting the multiplier.';

  @override
  String get skill_shield_label => 'Charges';

  @override
  String get skill_goldenTouch => 'Golden Touch';

  @override
  String get skill_goldenTouch_desc =>
      'Golden Second more often, with a stronger effect.';

  @override
  String get skill_goldenTouch_label => 'Golden Second every';

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
  String skillKeptInfo(String kept, String share) {
    return 'After a paradox $kept levels stay (Muscle memory: $share% of levels, rounded).';
  }

  @override
  String get skillKeptNone =>
      'After a paradox skills go back to zero. The Muscle memory perk keeps part of the levels, and a Habit keeps a chosen skill whole — what you buy now gives the next run a better start.';

  @override
  String prestigeHabitTitle(String used, String slots) {
    return 'Habit $used/$slots: which skills keep every level?';
  }

  @override
  String get skillKeptHabit =>
      'In a Habit slot: after a paradox every level stays.';

  @override
  String get skillHabitRemove => 'Take out of the Habit';

  @override
  String skillHabitAdd(String used, String slots) {
    return 'Keep it whole (Habit $used/$slots)';
  }

  @override
  String skillHabitMove(String skill) {
    return 'Keep it whole instead of $skill';
  }

  @override
  String inHundred(String n) {
    return '$n%';
  }

  @override
  String get oddsPerfect => 'PERFECTs';

  @override
  String get oddsGreatOrBetter => 'GREAT or better';

  @override
  String get oddsHits => 'hits';

  @override
  String skillOdds(String tier, String now, String next) {
    return 'Your $tier: about $now% → $next% of rounds';
  }

  @override
  String skillOddsMax(String tier, String now) {
    return 'Your $tier: about $now% of rounds';
  }

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
  String get chipLastRound => 'last round';

  @override
  String get justInTime => 'JUST IN TIME!';

  @override
  String get comboLabel => 'COMBO';

  @override
  String streakLabel(int count, int target) {
    return 'streak $count/$target';
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
    return 'Reach a multiplier of $count';
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
    return 'Rewind time $count times';
  }

  @override
  String get ach_mode_blind => 'Blindfolded';

  @override
  String get ach_mode_blind_desc => 'PERFECT in blind mode';

  @override
  String get ach_mode_fast => 'Feel the beat';

  @override
  String get ach_mode_fast_desc =>
      'PERFECT in Blind mode at a multiplier of ×1.5 or more';

  @override
  String get ach_mode_both => 'Metronome inside';

  @override
  String get ach_mode_both_desc =>
      'PERFECT in Blind mode at the full multiplier';

  @override
  String get ach_hidden_impatient => 'Impatient';

  @override
  String get ach_hidden_impatient_desc => 'TOO EARLY 100 times';

  @override
  String get ach_hidden_nap => 'Nap time';

  @override
  String get ach_hidden_nap_desc =>
      'Put the phone down until the stopwatch stops by itself';

  @override
  String get ach_hidden_almost => 'So close';

  @override
  String get ach_hidden_almost_desc => '4.99, then 5.01';

  @override
  String get ach_hidden_punctual => 'Punctual';

  @override
  String get ach_hidden_punctual_desc => 'A PERFECT at 5:00 or 17:00';

  @override
  String get ach_hidden_tenth => 'High five';

  @override
  String get ach_hidden_tenth_desc => '10 PERFECTs on the 5th of a month';

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
  String get ach_hidden_boiledEgg_desc => '74 grandmas';

  @override
  String ach_exact(String count) {
    return 'Spot on $count';
  }

  @override
  String ach_exact_desc(String count) {
    return 'Stop the dial at exactly 5.00 $count times';
  }

  @override
  String ach_rounds(String count) {
    return 'Persistent $count';
  }

  @override
  String ach_rounds_desc(String count) {
    return 'Play $count rounds';
  }

  @override
  String ach_income(String count) {
    return 'Time factory $count/s';
  }

  @override
  String ach_income_desc(String count) {
    return 'Your clocks earn $count Ticks a second (without Frenzy and Turbo)';
  }

  @override
  String ach_clocks(String count) {
    return 'Clockmaker $count';
  }

  @override
  String ach_clocks_desc(String count) {
    return 'Own $count clocks in total';
  }

  @override
  String ach_skillLevels(String count) {
    return 'Practice $count';
  }

  @override
  String ach_skillLevels_desc(String count) {
    return 'Have $count skill levels in total';
  }

  @override
  String ach_blindPerfects(String count) {
    return 'Bat $count';
  }

  @override
  String ach_blindPerfects_desc(String count) {
    return '$count blind PERFECTs';
  }

  @override
  String ach_playHours(String count) {
    return 'Regular $count h';
  }

  @override
  String ach_playHours_desc(String count) {
    return 'Play $count h in total';
  }

  @override
  String ach_achievements(String count) {
    return 'Collector $count';
  }

  @override
  String ach_achievements_desc(String count) {
    return 'Earn $count achievements';
  }

  @override
  String ach_daily(String count) {
    return 'Daily ritual $count';
  }

  @override
  String ach_daily_desc(String count) {
    return 'Collect the daily bonus $count times';
  }

  @override
  String ach_shield(String count) {
    return 'Armored $count';
  }

  @override
  String ach_shield_desc(String count) {
    return 'Your Shield saved the multiplier $count times';
  }

  @override
  String get ach_feat_goldenFast => 'Reflexes';

  @override
  String get ach_feat_goldenFast_desc =>
      'Catch a Golden Second within a second of it appearing';

  @override
  String get ach_feat_goldenFrenzy => 'Gold on gold';

  @override
  String get ach_feat_goldenFrenzy_desc =>
      'Catch a Golden Second during a Frenzy';

  @override
  String get ach_feat_dailyWeek => 'Full week';

  @override
  String get ach_feat_dailyWeek_desc => 'Reach day 7 of the daily bonus';

  @override
  String get ach_feat_offlineFull => 'Hibernation';

  @override
  String get ach_feat_offlineFull_desc =>
      'Come back after a break longer than the offline limit';

  @override
  String get ach_feat_bothClocks => 'Both hands';

  @override
  String get ach_feat_bothClocks_desc =>
      'A PERFECT on one clock right after a PERFECT on the other';

  @override
  String get ach_feat_allPerks => 'Master of time';

  @override
  String get ach_feat_allPerks_desc => 'Buy every perk';

  @override
  String get ach_feat_noHands => 'No hands';

  @override
  String get ach_feat_noHands_desc =>
      'Earn 1M Ticks in one run with at most 15 taps';

  @override
  String get ach_hidden_midnight => 'Cinderella';

  @override
  String get ach_hidden_midnight_desc => 'A PERFECT at midnight';

  @override
  String get ach_hidden_stubborn => 'Stubborn';

  @override
  String get ach_hidden_stubborn_desc => '1000 misses';

  @override
  String get ach_hidden_atomic => 'Atomic clock';

  @override
  String get ach_hidden_atomic_desc =>
      'Half of your last 100 taps within 15 ms';

  @override
  String get perk_headStart => 'Head start';

  @override
  String get perk_headStart_desc =>
      'After each paradox start with 10 Grandpas and 1K Ticks';

  @override
  String get perk_muscleMemory1 => 'Muscle memory I';

  @override
  String get perk_muscleMemory1_desc =>
      'After a paradox every skill keeps 50% of its levels';

  @override
  String get perk_muscleMemory2 => 'Muscle memory II';

  @override
  String get perk_muscleMemory2_desc => '…65% of its levels';

  @override
  String get perk_muscleMemory3 => 'Muscle memory III';

  @override
  String get perk_muscleMemory3_desc => '…80% of its levels';

  @override
  String get perk_habit1 => 'Habit I';

  @override
  String get perk_habit1_desc =>
      'One skill you choose keeps all its levels after a paradox (choose in the skill details)';

  @override
  String get perk_habit2 => 'Habit II';

  @override
  String get perk_habit2_desc => '…and a second one';

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
  String get perk_shieldRecharge => 'Quick shield';

  @override
  String get perk_shieldRecharge_desc =>
      'A Shield charge every 7 hits instead of 10';

  @override
  String get perk_comboFloor => 'Soft landing';

  @override
  String get perk_comboFloor_desc =>
      'A miss drops the multiplier to ×1.25, not ×1';

  @override
  String get perk_autoBuyer => 'Auto buyer';

  @override
  String get perk_autoBuyer_desc =>
      'A switch: buys the clock you pick up to its next bonus';

  @override
  String get perk_daredevil => 'Daredevil';

  @override
  String get perk_daredevil_desc => 'Blind mode pays ×4 instead of ×3';

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
  String get undiscoveredAchievement =>
      'Discover more clocks to see this achievement';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statEarnedRun => 'Earned since the last paradox';

  @override
  String get statEarnedTotal => 'Earned in total';

  @override
  String get statRounds => 'Rounds';

  @override
  String get statTypical => 'Typical error';

  @override
  String get statTypicalHint => 'half your taps land closer';

  @override
  String get statAccidental => 'Stray taps (ignored)';

  @override
  String get statTiers => 'Hits';

  @override
  String get statMeanError => 'Average error';

  @override
  String get statMeanHint => 'negative = you tap early';

  @override
  String get statBestStreak => 'Best PERFECT streak';

  @override
  String get statBestCombo => 'Highest multiplier';

  @override
  String get statGolden => 'Golden seconds caught';

  @override
  String get statPlayTime => 'Time played';

  @override
  String get statPrestiges => 'Paradoxes';

  @override
  String get statChronons => 'Chronons';

  @override
  String ms(String value) {
    return '$value ms';
  }

  @override
  String get prestigeTitle => 'Time paradox';

  @override
  String prestigeChronons(int count, String mult) {
    return 'Chronons: $count · income $mult';
  }

  @override
  String prestigeGainMult(String from, String to) {
    return 'Income $from → $to';
  }

  @override
  String prestigeShards(int count) {
    return 'Time shards: $count ✦';
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
  String prestigePendingTitle(int count) {
    return 'Time rewound: +$count ✦';
  }

  @override
  String get prestigePendingBody =>
      'Spend your Shards on perks now: Muscle memory and Head start already work in the new run.';

  @override
  String get prestigeStartRun => 'Start the new run';

  @override
  String get prestigeConfirm1 =>
      'You lose your clocks, skills and Ticks. Chronons, Shards ✦, perks and achievements stay. Before the new run starts you can spend Shards on perks. Continue?';

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
  String modeBlind(int mult) {
    return 'Blind ×$mult';
  }

  @override
  String get modeNextRound => 'from next round';

  @override
  String get modeSecond => 'Second clock';

  @override
  String get modeAuto => 'Auto buyer';

  @override
  String autoBuying(String owned, String until) {
    return '$owned/$until';
  }

  @override
  String autoDone(String until) {
    return '✓ $until · pick next';
  }

  @override
  String get autoPick => 'Auto buyer: pick a clock';

  @override
  String autoSheetHint(String seconds) {
    return 'Buys the clock you pick, one every $seconds s while the Tiki last, up to its next bonus. Then it waits for your next pick.';
  }

  @override
  String autoContinue(String clock, String until) {
    return 'Next: $clock → $until';
  }

  @override
  String get autoOff => 'Switch off';

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
  String adRescue(String count) {
    return 'Multiplier $count lost! ▶ Restore for an ad';
  }

  @override
  String get adDouble => '▶ ×2 for an ad';

  @override
  String get adUnavailable => 'No ad right now';

  @override
  String adCooldown(String time) {
    return 'in $time';
  }

  @override
  String get adFull => 'Full';

  @override
  String get tip_golden => 'Catch the golden clock for a golden round!';

  @override
  String get tip_combo =>
      'A PERFECT raises the multiplier! An exact 5.00 fills it.';

  @override
  String get tip_prestige =>
      'You can turn back time! You start over, but with Chronons that permanently speed up your income. Shards ✦ buy perks that stay through every reset. The swirl up top: you choose when.';

  @override
  String tip_milestone(String need) {
    return 'The bar under the name: at $need owned, the clock earns ×2!';
  }

  @override
  String milestoneProgress(String owned, String next, String mult) {
    return '$owned/$next → ×$mult';
  }

  @override
  String get milestoneMax => 'All bonuses reached';

  @override
  String milestoneToast(String name) {
    return 'New bonus · $name';
  }

  @override
  String milestoneTitle(String generator, String mult) {
    return '$generator ×$mult';
  }

  @override
  String get synergyToast => 'Synergy!';

  @override
  String get tutorialAim => 'Tap when the gold ring meets the clock — at 5.00!';

  @override
  String tutorialEarned(String cost) {
    return 'These are your Ticks. Collect $cost for your first clock!';
  }

  @override
  String get tutorialBuy => 'Buy Grandpa — he\'ll play for you!';

  @override
  String tutorialInfo(String rate) {
    return 'Grandpa adds Ticks on his own: +$rate a second, even while you\'re away.';
  }

  @override
  String get tutorialEarnedReplay =>
      'These are your Ticks. You spend them on clocks.';

  @override
  String goalBonus(String name, String have, String need, String mult) {
    return 'Goal: $name $have/$need → ×$mult';
  }

  @override
  String goalNewClock(String name) {
    return 'Goal: a new clock — $name';
  }

  @override
  String goalUnlockClock(int n, String have, String need) {
    return 'Goal: unlock clock #$n — $have/$need shards';
  }

  @override
  String get goalNewLoopChapter => 'Goal: a new loop — the next chapter';

  @override
  String get goalNewLoop => 'Goal: a new loop';

  @override
  String get statMultTitle => 'Income multipliers';

  @override
  String statMultChronons(int count) {
    return 'Chronons ($count)';
  }

  @override
  String statMultAchievements(int count) {
    return 'Achievements ($count)';
  }

  @override
  String get statMultLevels => 'Clock mastery';

  @override
  String get statMultTurbo => 'Turbo';

  @override
  String get statMultTotal => 'Together';

  @override
  String get tutorialGotIt => 'OK';

  @override
  String get tutorialAutoStart =>
      'From now on the stopwatch starts by itself: right after each result, the next round begins.';

  @override
  String get tip_springs =>
      'Mainsprings! They wind by themselves, one a day. Spend them on clock mastery: it stays forever. Every 7th day of the daily bonus brings one more.';

  @override
  String get tip_loop =>
      'A new loop: everything from zero, but Mainsprings and mastery stay.';

  @override
  String tip_loopRule(String rule) {
    return 'A new loop: everything from zero, but Mainsprings and mastery stay. Chronos\' rule: $rule.';
  }

  @override
  String get tip_skills => 'Skills boost your own hits.';

  @override
  String get tip_modes => 'A new mode! Tap to switch it on.';

  @override
  String skillBuyLevel(String level) {
    return 'Buy Lv $level';
  }

  @override
  String generatorEarnsEach(String value) {
    return '+$value/s each';
  }

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpReplay => 'Show the tutorial again';

  @override
  String get help_goal_t => 'Goal';

  @override
  String get help_goal =>
      'Grandpa is always late for Grandma\'s afternoon tea, and he wants the one clock that is never wrong: Chronos, the god of time — the last and most expensive clock in the game. Get him and the story goes on.\nThe way there: hit 5.00, collect Ticks, and spend them on clocks that earn for you.';

  @override
  String get help_tiki_t => 'Ticks';

  @override
  String get help_tiki =>
      'Ticks are the game\'s currency. At the top of the screen:\n• the big number — your Ticks\n• below it — how many you gain per second\n• \"5.00 = +…\" — what a hit on exactly 5.00 pays\nYou spend Ticks in the shop at the bottom: on clocks and skills.';

  @override
  String get help_clocks_t => 'Clocks';

  @override
  String get help_clocks =>
      'Clocks play rounds for you (the bubbles beside the dial show their results) and give Ticks every second — even while the game is closed, up to a time limit.\n• Buying a clock reveals the next one: pricier and stronger.\n• The number on the icon — how many you own.\n• Each extra copy of the same clock costs a bit more.\n• ×1, ×10, ×100, MAX — how many you buy at once.';

  @override
  String get help_upgrades_t => 'Clock bonuses';

  @override
  String get help_upgrades =>
      'The bar under a clock shows how many more you need for the next step, e.g. \"20/40 → ×2\". At each step all clocks of that kind earn that many times more, for good.\n• First clocks: steps at 10, 20, 40… and ×2.\n• Pricier clocks: lower steps, smaller multipliers.\nSynergy: 25 each of two matching clocks (e.g. Grandpa and Grandma) boosts both.';

  @override
  String get help_skills_t => 'Skills';

  @override
  String get help_skills =>
      'Skills boost your own hits — not the clocks. Among others: bigger rewards, wider grade windows and a higher multiplier.\n• Each has levels, e.g. \"Level 2/10\"; the next level costs more Ticks.\n• A new card appears as you get close to its price.\n• Tap a card to see its exact effect.';

  @override
  String get help_combo_t => 'Multiplier (combo)';

  @override
  String get help_combo =>
      'The multiplier next to COMBO multiplies all your payouts. A PERFECT raises it by 0.05, an exact 5.00 straight to the cap (the Combo skill raises the cap). GREAT and GOOD leave it alone.\nA CLOSE or a miss resets the multiplier. Except: a Shield charge (a skill) takes one miss; charges come back every 10 hits, counting from zero once one is used.\nThe streak — hits in a row — counts only during a \"streak\" challenge: from zero until the first miss, even one a Shield took.';

  @override
  String get help_golden_t => 'Golden Second';

  @override
  String get help_golden =>
      'About every 10 minutes a golden clock flies across the screen. Tapping it turns the next round golden.\nA hit in a golden round gives a random reward:\n• Frenzy (45%) — all income ×7 for 77 s\n• Lucky (45%) — Ticks worth 10 minutes of your clocks, right away\n• Hot hand (10%) — for 60 s every hit counts as PERFECT and pays ×10\nThe reward\'s strength depends on the grade: PERFECT 100%, GREAT 60%, GOOD 30%, a miss nothing.';

  @override
  String get help_modes_t => 'Toggles';

  @override
  String get help_modes =>
      'Toggles above the shop change the rules of a round. Each appears only once unlocked:\n• Blind — somewhere between 3.60 and 4.20 (a different moment each round) the digits and the ring disappear; hits pay ×3 (×4 with the Daredevil perk)\n• Second clock — two stopwatches at once; the left and right half of the screen are separate clocks\n• Auto-buyer — buys the clock you pick up to its next bonus, then turns orange and waits for your next pick';

  @override
  String get help_season_t => 'Events';

  @override
  String get help_season =>
      'On holidays the golden clock changes its look. The badge at the top counts two goals: holiday clocks caught (e.g. 0/5) and hits (e.g. 0/50). Both together earn a reward, and the holiday theme stays unlocked.';

  @override
  String get help_prestige_t => 'Time paradox';

  @override
  String get help_prestige =>
      'Once you\'ve earned enough Ticks, the swirl at the top lights up. Rewinding time resets your Ticks, clocks and skills. In return you get:\n• Chronons — a permanent multiplier on all income; their number grows with the Ticks earned this loop\n• Shards of time — as many as Chronons; they pay for perks\nYou buy perks right after the rewind or later on the paradox screen. Chronons, Shards, perks and achievements stay.';

  @override
  String get help_icons_t => 'Icons at the top';

  @override
  String get help_icons =>
      '• Trophy — achievements (each: +1% income)\n• Chart — statistics\n• Dial — the stopwatch look\n• Question mark — this help\n• Gear — settings\n• Swirl — time paradox\n• Spiral — Mainsprings';

  @override
  String notificationTitle(String amount) {
    return 'Your clocks collected $amount Ticks!';
  }

  @override
  String get notificationAsk => 'Shall we tell you when your clocks are full?';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sound effects';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAnalytics => 'Send game statistics';

  @override
  String get settingsAnalyticsHint =>
      'Gameplay statistics and crash reports help us tune the game. No account, no name, no ad ID.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsNotation => 'Numbers';

  @override
  String get notationShort => 'Short (12.4M)';

  @override
  String get notationScientific => 'Scientific (1.24e7)';

  @override
  String get settingsReduceMotion => 'Calm mode';

  @override
  String get settingsReduceMotionHint =>
      'Less motion and flicker, a calmer Frenzy';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsExportDone =>
      'Save copied to the clipboard. Keep it somewhere safe.';

  @override
  String get settingsImport => 'Import';

  @override
  String get settingsImportHint => 'Paste the save text here';

  @override
  String get settingsImportConfirm =>
      'Replace the current game with this save?';

  @override
  String get settingsImportBad => 'That doesn\'t look like a Hit5 save.';

  @override
  String get settingsReset => 'Start over';

  @override
  String get settingsResetConfirm1 =>
      'Sure? You lose everything: Ticks, clocks, Chronons, Shards, perks and achievements. Settings stay.';

  @override
  String settingsResetConfirm2(String word) {
    return 'Type $word to confirm.';
  }

  @override
  String get resetWord => 'RESET';

  @override
  String get settingsCredits => 'Credits and licences';

  @override
  String get creditsLegalese =>
      'Art: our own, generated with Qwen-Image (Apache 2.0).\nFonts: Paytone One and Nunito (SIL Open Font License 1.1).\nSounds and music: our own, synthesised in code.';

  @override
  String get settingsOther => 'Other';

  @override
  String get upg_grandpa_1 => 'Reading Glasses';

  @override
  String get upg_grandpa_1_desc => 'Finally sees the hands.';

  @override
  String get upg_grandpa_2 => 'New Battery';

  @override
  String get upg_grandpa_2_desc => 'First one since cassette tapes.';

  @override
  String get upg_grandpa_3 => 'Non-slip Slippers';

  @override
  String get upg_grandpa_3_desc => 'Steady feet, steady thumb.';

  @override
  String get upg_grandpa_4 => 'Crossword: TIME';

  @override
  String get upg_grandpa_4_desc => 'Solved in exactly 5.00 s.';

  @override
  String get upg_grandpa_5 => 'Spa Retreat';

  @override
  String get upg_grandpa_5_desc => 'Comes back rested and twice as sharp.';

  @override
  String get upg_grandpa_6 => 'Tech-savvy Grandson';

  @override
  String get upg_grandpa_6_desc => 'Synced his watch to an atomic server.';

  @override
  String get upg_grandpa_7 => 'Punctuality Medal';

  @override
  String get upg_grandpa_7_desc => 'Pinned proudly to the waistcoat.';

  @override
  String get upg_grandpa_8 => 'Great-grandpa\'s Watch';

  @override
  String get upg_grandpa_8_desc =>
      'Ticking in the family for three generations.';

  @override
  String get upg_grandma_1 => 'Happy Hen Eggs';

  @override
  String get upg_grandma_1_desc => 'Happy hens, happy timers.';

  @override
  String get upg_grandma_2 => 'Polka-dot Apron';

  @override
  String get upg_grandma_2_desc => 'Aerodynamic.';

  @override
  String get upg_grandma_3 => 'A Second Timer';

  @override
  String get upg_grandma_3_desc => 'One for the eggs, one for the soup.';

  @override
  String get upg_grandma_4 => 'Baking Club';

  @override
  String get upg_grandma_4_desc => 'Precision training. With cake.';

  @override
  String get upg_grandma_5 => '“Five-Second Recipes”';

  @override
  String get upg_grandma_5_desc => 'Quick dishes only.';

  @override
  String get upg_grandma_6 => 'Induction Hob';

  @override
  String get upg_grandma_6_desc => 'Boils before you think.';

  @override
  String get upg_grandma_7 => 'Influencer Granddaughter';

  @override
  String get upg_grandma_7_desc => 'Films every perfect 5.00.';

  @override
  String get upg_grandma_8 => 'Golden Rolling Pin';

  @override
  String get upg_grandma_8_desc => 'A neighbourhood legend.';

  @override
  String get upg_cuckoo_1 => 'Diction Lessons';

  @override
  String get upg_cuckoo_1_desc => 'Cuck-oo. Crisp and on time.';

  @override
  String get upg_cuckoo_2 => 'Fresh Springs';

  @override
  String get upg_cuckoo_2_desc => 'Pops out like a slingshot.';

  @override
  String get upg_cuckoo_3 => 'Nest with a View';

  @override
  String get upg_cuckoo_3_desc => 'Better view, better cuckoos.';

  @override
  String get upg_cuckoo_4 => 'Cuckoo Choir';

  @override
  String get upg_cuckoo_4_desc => 'Cuckooing in canon.';

  @override
  String get upg_cuckoo_5 => 'Swiss Master Class';

  @override
  String get upg_cuckoo_5_desc => 'Precision straight from the Alps.';

  @override
  String get upg_cuckoo_6 => 'Espresso Beans';

  @override
  String get upg_cuckoo_6_desc => 'Cuckoos faster than it means to.';

  @override
  String get upg_cuckoo_7 => 'A Proper Agent';

  @override
  String get upg_cuckoo_7_desc => 'Signed for a world tour.';

  @override
  String get upg_cuckoo_8 => 'Black Forest Original';

  @override
  String get upg_cuckoo_8_desc => 'Certified, with a pedigree.';

  @override
  String get upg_metronome_1 => 'New Weight';

  @override
  String get upg_metronome_1_desc => 'Less wobble, more hits.';

  @override
  String get upg_metronome_2 => 'Pendulum Oil';

  @override
  String get upg_metronome_2_desc => 'Silence. Just tick-tock.';

  @override
  String get upg_metronome_3 => 'Six-Eight Time';

  @override
  String get upg_metronome_3_desc => 'For a change.';

  @override
  String get upg_metronome_4 => 'Orchestra Gig';

  @override
  String get upg_metronome_4_desc => 'A hundred violins watch only him.';

  @override
  String get upg_metronome_5 => 'Techno Mode';

  @override
  String get upg_metronome_5_desc => '140 beats a minute, not one off.';

  @override
  String get upg_metronome_6 => 'Digital Twin';

  @override
  String get upg_metronome_6_desc => 'Sibling rivalry.';

  @override
  String get upg_metronome_7 => 'Jazz Quartet Tour';

  @override
  String get upg_metronome_7_desc => 'Swings, never late.';

  @override
  String get upg_metronome_8 => 'Golden Pendulum';

  @override
  String get upg_metronome_8_desc => 'Perfect rhythm.';

  @override
  String get upg_watchmaker_1 => 'New Loupe';

  @override
  String get upg_watchmaker_1_desc => 'Sees every gear. Even the mental ones.';

  @override
  String get upg_watchmaker_2 => 'Screwdriver Set';

  @override
  String get upg_watchmaker_2_desc => '48 sizes, all of them tiny.';

  @override
  String get upg_watchmaker_3 => 'Apprentice';

  @override
  String get upg_watchmaker_3_desc => 'Learns on your Ticks.';

  @override
  String get upg_watchmaker_4 => 'Window Workbench';

  @override
  String get upg_watchmaker_4_desc => 'Daylight, daylight precision.';

  @override
  String get upg_watchmaker_5 => 'Swiss Movement';

  @override
  String get upg_watchmaker_5_desc => 'Delivered in a padlocked case.';

  @override
  String get upg_watchmaker_6 => 'Tourbillon';

  @override
  String get upg_watchmaker_6_desc => 'Spins so it never errs.';

  @override
  String get upg_watchmaker_7 => 'Watchmakers\' Guild';

  @override
  String get upg_watchmaker_7_desc =>
      'Secret knowledge, passed on in whispers.';

  @override
  String get upg_watchmaker_8 => 'Grand Complication';

  @override
  String get upg_watchmaker_8_desc => 'Nobody knows what it does. It works.';

  @override
  String get upg_sprintJudge_1 => 'New Whistle';

  @override
  String get upg_sprintJudge_1_desc => 'Tweet! Right on time.';

  @override
  String get upg_sprintJudge_2 => 'Photo Finish';

  @override
  String get upg_sprintJudge_2_desc => 'Sees one hundredth of a second.';

  @override
  String get upg_sprintJudge_3 => 'Starter Pistol';

  @override
  String get upg_sprintJudge_3_desc => 'No bullets, all timing.';

  @override
  String get upg_sprintJudge_4 => 'Umpire\'s Chair';

  @override
  String get upg_sprintJudge_4_desc => 'With a view straight down the line.';

  @override
  String get upg_sprintJudge_5 => 'Olympic Licence';

  @override
  String get upg_sprintJudge_5_desc => 'It\'s official now.';

  @override
  String get upg_sprintJudge_6 => 'Video Replay';

  @override
  String get upg_sprintJudge_6_desc => 'Frame by frame.';

  @override
  String get upg_sprintJudge_7 => 'World-record Judging';

  @override
  String get upg_sprintJudge_7_desc => '9.58 s? Too slow.';

  @override
  String get upg_sprintJudge_8 => 'Golden Stopwatch';

  @override
  String get upg_sprintJudge_8_desc => 'Times as if it invented time.';

  @override
  String get upg_stationClock_1 => 'New Timetable';

  @override
  String get upg_stationClock_1_desc => 'Now accounts for reality.';

  @override
  String get upg_stationClock_2 => 'Polished Face';

  @override
  String get upg_stationClock_2_desc => 'Visible from platform five.';

  @override
  String get upg_stationClock_3 => 'PA Announcement';

  @override
  String get upg_stationClock_3_desc => '“The 5.00 will arrive on time.”';

  @override
  String get upg_stationClock_4 => 'Stationmaster';

  @override
  String get upg_stationClock_4_desc => 'Peaked cap, dead serious.';

  @override
  String get upg_stationClock_5 => 'High-speed Rail';

  @override
  String get upg_stationClock_5_desc => 'Fewer delays, more hits.';

  @override
  String get upg_stationClock_6 => 'Radio-controlled';

  @override
  String get upg_stationClock_6_desc => 'The radio knows the time.';

  @override
  String get upg_stationClock_7 => 'Grand Central';

  @override
  String get upg_stationClock_7_desc => 'A thousand commuters, one clock.';

  @override
  String get upg_stationClock_8 => 'The Train That Was On Time';

  @override
  String get upg_stationClock_8_desc => 'A legend nobody believed.';

  @override
  String get upg_quartz_1 => 'Fresh Crystal';

  @override
  String get upg_quartz_1_desc => 'Vibrates like new.';

  @override
  String get upg_quartz_2 => 'Proper Soldering';

  @override
  String get upg_quartz_2_desc => 'No cold joints, no excuses.';

  @override
  String get upg_quartz_3 => 'LCD Display';

  @override
  String get upg_quartz_3_desc => 'Digits straight from the 80s.';

  @override
  String get upg_quartz_4 => 'Temperature Compensation';

  @override
  String get upg_quartz_4_desc => 'Doesn\'t care about the weather.';

  @override
  String get upg_quartz_5 => 'Dual Oscillator';

  @override
  String get upg_quartz_5_desc => 'Two times 32,768.';

  @override
  String get upg_quartz_6 => 'Swiss Factory';

  @override
  String get upg_quartz_6_desc => 'The irony.';

  @override
  String get upg_quartz_7 => 'Built-in Calculator';

  @override
  String get upg_quartz_7_desc => 'Counts Ticks on the fly.';

  @override
  String get upg_quartz_8 => 'Rock Crystal';

  @override
  String get upg_quartz_8_desc => 'The one from the legends.';

  @override
  String get upg_atomic_1 => 'Laser Cooling';

  @override
  String get upg_atomic_1_desc => 'Atoms almost stand still. Almost.';

  @override
  String get upg_atomic_2 => 'Purer Caesium';

  @override
  String get upg_atomic_2_desc => 'Caesium-133, no additives.';

  @override
  String get upg_atomic_3 => 'Atomic Fountain';

  @override
  String get upg_atomic_3_desc => 'Atoms bounce to the beat.';

  @override
  String get upg_atomic_4 => 'Optical Clock';

  @override
  String get upg_atomic_4_desc => 'Measures time with light.';

  @override
  String get upg_atomic_5 => 'Ion Trap';

  @override
  String get upg_atomic_5_desc => 'One ion, zero excuses.';

  @override
  String get upg_atomic_6 => 'Lab Network';

  @override
  String get upg_atomic_6_desc => 'Every second is put to a vote.';

  @override
  String get upg_atomic_7 => 'Leap Second';

  @override
  String get upg_atomic_7_desc => 'Added while nobody was looking.';

  @override
  String get upg_atomic_8 => 'Nuclear Clock';

  @override
  String get upg_atomic_8_desc => 'Thorium-229 doesn\'t do jokes.';

  @override
  String get upg_gps_1 => 'Better Antenna';

  @override
  String get upg_gps_1_desc => 'Hears Earth more clearly.';

  @override
  String get upg_gps_2 => 'Relativity Fix';

  @override
  String get upg_gps_2_desc => 'Einstein would be proud.';

  @override
  String get upg_gps_3 => 'Bigger Solar Panel';

  @override
  String get upg_gps_3_desc => 'More power, more ticks.';

  @override
  String get upg_gps_4 => 'Constellation';

  @override
  String get upg_gps_4_desc => '31 friends in orbit.';

  @override
  String get upg_gps_5 => 'Ionosphere Correction';

  @override
  String get upg_gps_5_desc => 'Through clouds and storms.';

  @override
  String get upg_gps_6 => 'Ground Station';

  @override
  String get upg_gps_6_desc => 'Someone keeps watch from below.';

  @override
  String get upg_gps_7 => 'Laser Link';

  @override
  String get upg_gps_7_desc => 'Satellites whispering in light.';

  @override
  String get upg_gps_8 => 'Geostationary Orbit';

  @override
  String get upg_gps_8_desc => 'Always in the same place. Always on time.';

  @override
  String get upg_pulsar_1 => 'Bigger Dish';

  @override
  String get upg_pulsar_1_desc => 'Hears every pulse.';

  @override
  String get upg_pulsar_2 => 'Millisecond Pulsar';

  @override
  String get upg_pulsar_2_desc => '700 spins a second.';

  @override
  String get upg_pulsar_3 => 'Sky Map';

  @override
  String get upg_pulsar_3_desc => 'Finally we know where to look.';

  @override
  String get upg_pulsar_4 => 'Pulsar Timing Array';

  @override
  String get upg_pulsar_4_desc => 'A cosmic metronome choir.';

  @override
  String get upg_pulsar_5 => 'Gravitational Waves';

  @override
  String get upg_pulsar_5_desc => 'Spacetime wobbles on the beat.';

  @override
  String get upg_pulsar_6 => 'Magnetar';

  @override
  String get upg_pulsar_6_desc => 'A pulsar with attitude.';

  @override
  String get upg_pulsar_7 => 'Cosmic Lighthouse';

  @override
  String get upg_pulsar_7_desc => 'Guides ships home. On time.';

  @override
  String get upg_pulsar_8 => 'Heart of the Galaxy';

  @override
  String get upg_pulsar_8_desc => 'The whole Milky Way ticks along.';

  @override
  String get upg_timeMachine_1 => 'Flux Capacitor';

  @override
  String get upg_timeMachine_1_desc => '1.21 gigawatts, not a watt less.';

  @override
  String get upg_timeMachine_2 => 'Seat Belts';

  @override
  String get upg_timeMachine_2_desc => 'In case of paradox.';

  @override
  String get upg_timeMachine_3 => 'Note from the Future';

  @override
  String get upg_timeMachine_3_desc => '“Tap now.”';

  @override
  String get upg_timeMachine_4 => 'Time Loop';

  @override
  String get upg_timeMachine_4_desc =>
      'Practises the same five seconds forever.';

  @override
  String get upg_timeMachine_5 => 'Spare Timeline';

  @override
  String get upg_timeMachine_5_desc => 'Just in case.';

  @override
  String get upg_timeMachine_6 => 'Tours to 5.00';

  @override
  String get upg_timeMachine_6_desc => 'Guided, of course.';

  @override
  String get upg_timeMachine_7 => 'Meeting Yourself';

  @override
  String get upg_timeMachine_7_desc => 'Polite, but weird.';

  @override
  String get upg_timeMachine_8 => 'End of Time';

  @override
  String get upg_timeMachine_8_desc => 'One-way ticket.';

  @override
  String get upg_schrodinger_1 => 'Bigger Box';

  @override
  String get upg_schrodinger_1_desc => 'More room for uncertainty.';

  @override
  String get upg_schrodinger_2 => 'Quantum Kibble';

  @override
  String get upg_schrodinger_2_desc => 'Eaten and not eaten.';

  @override
  String get upg_schrodinger_3 => 'Entangled Yarn';

  @override
  String get upg_schrodinger_3_desc => 'Entanglement on demand.';

  @override
  String get upg_schrodinger_4 => 'Superposition Catnip';

  @override
  String get upg_schrodinger_4_desc => 'Purrs in two states at once.';

  @override
  String get upg_schrodinger_5 => 'Observer on Holiday';

  @override
  String get upg_schrodinger_5_desc => 'No one looks, everything hits.';

  @override
  String get upg_schrodinger_6 => 'A Second Cat';

  @override
  String get upg_schrodinger_6_desc => 'Now there are four states.';

  @override
  String get upg_schrodinger_7 => 'Many Worlds';

  @override
  String get upg_schrodinger_7_desc => 'In one of them it\'s always 5.00.';

  @override
  String get upg_schrodinger_8 => 'Box Opened';

  @override
  String get upg_schrodinger_8_desc => 'It hit. Definitely hit.';

  @override
  String get upg_chronos_1 => 'Sharpened Scythe';

  @override
  String get upg_chronos_1_desc => 'Slices seconds into hundredths.';

  @override
  String get upg_chronos_2 => 'Olympian Hourglass';

  @override
  String get upg_chronos_2_desc => 'Sand straight from the gods.';

  @override
  String get upg_chronos_3 => 'Temple';

  @override
  String get upg_chronos_3_desc => 'The faithful bring watches.';

  @override
  String get upg_chronos_4 => 'A Word with Kairos';

  @override
  String get upg_chronos_4_desc => 'About the right moment.';

  @override
  String get upg_chronos_5 => 'Throne of Gears';

  @override
  String get upg_chronos_5_desc => 'Comfy, if a bit ticky.';

  @override
  String get upg_chronos_6 => 'Pantheon of Punctuality';

  @override
  String get upg_chronos_6_desc => 'Gods who are never late.';

  @override
  String get upg_chronos_7 => 'Eternity';

  @override
  String get upg_chronos_7_desc => 'Has time. Literally.';

  @override
  String get upg_chronos_8 => 'The Absolute Second';

  @override
  String get upg_chronos_8_desc => '5.00. Always was, always will be.';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsAdPrivacy => 'Ad privacy choices';

  @override
  String get dailyTitle => 'Daily bonus';

  @override
  String dailyDay(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String dailyHint(int total, String spring) {
    String _temp0 = intl.Intl.selectLogic(spring, {
      'yes': ', and the last one brings a Mainspring',
      'other': '',
    });
    return 'Come back every day — the bonus grows for $total days$_temp0. One missed day a week is forgiven.';
  }

  @override
  String get adOfferHow => 'A short video ad. The reward comes after it ends.';

  @override
  String get adWatch => '▶ Watch';

  @override
  String get adNotNow => 'Not now';

  @override
  String get adOfferTurboTitle => 'Turbo';

  @override
  String adOfferTurboReward(int mult, int minutes) {
    return '×$mult Ticks for $minutes min';
  }

  @override
  String adOfferTurboDetail(int hours) {
    return 'All earnings — clocks and your hits — are doubled. Turbo time runs only while you play; stock up to $hours h.';
  }

  @override
  String adOfferTurboStock(String time) {
    return 'You still have $time — the ad adds another 30 min.';
  }

  @override
  String get adOfferGoldenTitle => 'Golden Second';

  @override
  String get adOfferGoldenReward => 'A golden clock right away';

  @override
  String get adOfferGoldenDetail =>
      'After the ad a golden clock flies in. Catch it and the next round gives a random bonus: Frenzy, Lucky or Hot Hand.';

  @override
  String get adOfferBagTitle => 'Bag of Ticks';

  @override
  String adOfferBagDetail(int minutes) {
    return 'Right away, as much as your clocks earn in $minutes min (without Frenzy and Turbo).';
  }

  @override
  String get adNoReward =>
      'The ad didn\'t finish — no reward. You can try again.';

  @override
  String adDoneTurbo(String time) {
    return 'Turbo on! ×2 for $time.';
  }

  @override
  String get adDoneGolden => 'The golden clock is coming — catch it!';

  @override
  String get adDoneBag => 'Bag of Ticks collected!';

  @override
  String get adDoneRescue => 'Multiplier restored!';

  @override
  String get adDoneOffline => 'Offline income doubled!';

  @override
  String get season_valentine => 'Valentine\'s';

  @override
  String get season_valentine_items => 'Hearts';

  @override
  String get season_easter => 'Easter';

  @override
  String get season_easter_items => 'Chicks';

  @override
  String get season_summer => 'Summer';

  @override
  String get season_summer_items => 'Suns';

  @override
  String get season_halloween => 'Halloween';

  @override
  String get season_halloween_items => 'Pumpkins';

  @override
  String get season_christmas => 'Christmas';

  @override
  String get season_christmas_items => 'Gifts';

  @override
  String get season_newYear => 'New Year';

  @override
  String get season_newYear_items => 'Party poppers';

  @override
  String seasonUntil(String date) {
    return 'Event until $date';
  }

  @override
  String get seasonHow =>
      'The golden clock dresses up for the occasion. Catch it and hit (GOOD or better) to earn the reward.';

  @override
  String get seasonHits => 'Hits';

  @override
  String seasonReward(String amount, String name) {
    return 'Reward: +$amount Ticks, the “$name” theme for good and an achievement (+1%).';
  }

  @override
  String seasonDone(String name) {
    return 'Done! Pick the “$name” theme in Settings.';
  }

  @override
  String seasonCompleted(String name, String amount) {
    return '$name complete! +$amount Ticks';
  }

  @override
  String get seasonStart => 'Let\'s go!';

  @override
  String ach_season(String name) {
    return '$name';
  }

  @override
  String ach_season_desc(String name) {
    return 'Complete the “$name” event';
  }

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeAuto => 'Seasonal';

  @override
  String get themeClassic => 'Classic';

  @override
  String get themeHint =>
      '“Seasonal” follows the events. Themes from completed events are yours for good.';

  @override
  String get diagSeason => 'Event preview';

  @override
  String get diagSeasonNone => 'By date';

  @override
  String perfectNow(String amount) {
    return 'PERFECT now: +$amount';
  }

  @override
  String perfectNowSeconds(String amount, String seconds) {
    return 'PERFECT now: +$amount (≈ $seconds s of clock income)';
  }

  @override
  String jackpotPrice(String target, String amount) {
    return '$target = +$amount';
  }

  @override
  String generatorTotal(String perSecond) {
    return '$perSecond in total';
  }

  @override
  String get generatorBonuses => 'Bonuses';

  @override
  String generatorBonusLine(String count, String name, String mult) {
    return '$count pcs · $name · ×$mult';
  }

  @override
  String get generatorSynergies => 'Synergies';

  @override
  String generatorSynergyOn(String name) {
    return '$name ✓ active';
  }

  @override
  String generatorSynergyEffect(String pct, String other) {
    return '+$pct% for each $other';
  }

  @override
  String generatorSynergyNeeds(
    String need,
    String a,
    String aOwned,
    String b,
    String bOwned,
  ) {
    return 'Turns on at $need of both: $a $aOwned/$need, $b $bOwned/$need';
  }

  @override
  String get season_fiveDay => 'Five Day';

  @override
  String get season_fiveDay_items => 'Fives';

  @override
  String get skill_power_info =>
      'A hit pays a fixed number of Ticks: PERFECT 6, GREAT 3, GOOD 1. Each level adds 150% of that (PERFECT: 6 → 15 → 24…).';

  @override
  String get skill_fastForward_info =>
      'Each level moves the stopwatch\'s start by about 0.13 s, up to 2.00 s at the top level. The stopwatch runs at normal speed and the target is still 5.00.';

  @override
  String get skill_ticking_info =>
      'From 4.00 to 5.00 you hear a tick every 0.1 s (with vibration if it\'s on).';

  @override
  String get skill_wideEye_info =>
      'The GREAT (±30 ms) and GOOD (±50 ms) windows grow by about 5% a level, up to ×1.8 at the top level (±54 and ±90 ms). Works on clocks too.';

  @override
  String get skill_combo_info =>
      'A PERFECT raises the multiplier by 0.05, an exact 5.00 straight to the cap. GREAT and GOOD leave it alone, a miss resets it. Without upgrades the cap is ×1.25; each level raises it by 0.10. It multiplies the whole payout for a hit, 5.00 and Echo included.';

  @override
  String get skill_magnet_info =>
      'The PERFECT window (±15 ms) grows by about 0.7 ms a level, up to ±25 ms. The 5.00 window (±10 ms) stays. Works on clocks too.';

  @override
  String get skill_echo_info =>
      'A hit adds as many Ticks as your clocks make in the given time. Per level: PERFECT 0.2 s, GREAT about 0.11 s, GOOD about 0.03 s.';

  @override
  String get skill_bulletTime_info =>
      'The PERFECT, GREAT, GOOD and CLOSE windows grow up to ×2.5 at the top level (e.g. GOOD: ±50 → ±125 ms). The 5.00 window stays. Near the target the screen pulses and you hear a heartbeat. Doesn\'t work on clocks.';

  @override
  String get skill_luck_info =>
      'At each level 2 hits in 100 jump a tier: GREAT → PERFECT, GOOD → GREAT. A PERFECT never becomes a 5.00.';

  @override
  String get skill_shield_info =>
      'Each level is one charge. A miss uses a charge and the multiplier stays. Used charges come back one per 10 hits; using a charge restarts that count.';

  @override
  String get skill_goldenTouch_info =>
      'A Golden Second appears every 10 minutes on average. Each level cuts that by 30 s and makes its effects (Frenzy, Lucky, Hot hand) 5% stronger.';

  @override
  String springWound(String minutes) {
    return 'Mainspring +$minutes min';
  }

  @override
  String get springsTitle => 'Mainsprings';

  @override
  String springsBadgeHits(String count, int hits) {
    String _temp0 = intl.Intl.pluralLogic(
      hits,
      locale: localeName,
      other: '$hits exact hits left to wind',
      one: '1 exact hit left to wind',
      zero: 'Exact hits wind nothing until the reserve is back',
    );
    return 'Mainsprings: $count. $_temp0';
  }

  @override
  String springsBadgeFull(String count) {
    return 'Mainsprings: $count. Storage full: exact hits wind nothing and keep the reserve';
  }

  @override
  String get springsBadgeMax => 'MAX';

  @override
  String springsIntro(String mult) {
    return 'A Mainspring winds itself: one a day, even while you\'re away. Every exact 5.00 winds it faster. Spend Mainsprings on clock mastery: every tier multiplies that clock\'s income by $mult, for good — nothing takes it back.';
  }

  @override
  String springsNext(String time) {
    return 'Next one in $time';
  }

  @override
  String springsFull(String max) {
    return 'Storage full ($max). Exact hits keep the reserve for now. Spend some to keep winding.';
  }

  @override
  String get springsReserveTitle => 'Winding reserve';

  @override
  String springsReserve(String left, String max) {
    return '$left of $max';
  }

  @override
  String springsReserveHow(String time, String refill) {
    return 'Every exact 5.00 winds $time out of the reserve. The reserve comes back by itself in $refill.';
  }

  @override
  String springsReserveEmpty(String time) {
    return 'The reserve is empty: hits wind nothing now. Full again in $time.';
  }

  @override
  String get springEmpty => 'Winding reserve empty';

  @override
  String get adSpring => '▶ Refill for an ad';

  @override
  String adSpringLeft(int left, int max) {
    return 'Ads today: $left of $max';
  }

  @override
  String get adDoneSpring => 'The reserve is full — hit 5.00!';

  @override
  String get springsNoClocks => 'Buy a clock to raise its mastery.';

  @override
  String get clockLevelTitle => 'Clock mastery';

  @override
  String clockLevelLine(String level, String max, String mult) {
    return 'Tier $level/$max · $mult';
  }

  @override
  String clockLevelUp(String cost) {
    return 'Level up · $cost';
  }

  @override
  String get clockLevelMax => 'Full mastery';

  @override
  String clockLevelTitleAt(String level, String title) {
    return 'Tier $level: $title';
  }

  @override
  String get clockLevelLocked => 'Mainsprings arrive with the first paradox.';

  @override
  String ach_mastery_desc(String generator, String level) {
    return '$generator: mastery tier $level';
  }

  @override
  String get dialTitle => 'Dial face';

  @override
  String get dialHint =>
      'You earn faces on several tracks at once. Each one shows what the next face takes.';

  @override
  String dialLocked(String amount) {
    return 'Earn $amount';
  }

  @override
  String get dialToast => 'New dial face';

  @override
  String dialProgress(String have, String need) {
    return 'Earned in total: $have of $need';
  }

  @override
  String get updateReady => 'A new version is ready';

  @override
  String get updateRestart => 'Restart';

  @override
  String get updateInstall => 'Install the new version';

  @override
  String get updateInstallHint =>
      'The game restarts and keeps your progress. Otherwise it installs by itself when you leave the game.';

  @override
  String get help_springs_t => 'Mainsprings and clock mastery';

  @override
  String get help_springs =>
      'Mainsprings work from your first rewind (the spiral at the top).\n• They wind themselves: one a day, even while you\'re away. At most 10 fit.\n• A hit on exactly 5.00 winds 15 minutes from the reserve. The reserve holds 2 hours and refills in 4 hours.\n• The first exactly-5.00 after an hour\'s break winds a whole hour.\nMainsprings pay for clock mastery: tier 1 costs 1 Mainspring, tier 2 costs 2, and so on up to tier 5. Each tier multiplies that clock\'s income ×1.5 for good — also after a rewind and in a new loop. Tiers 3 and 5 give a master\'s title.';

  @override
  String get help_dials_t => 'Dial faces';

  @override
  String get help_dials =>
      'Dial faces change only how the stopwatch looks, not your results. You earn them on several tracks at once: Ticks in the first days, clock mastery, Time Loops, a feat for the patient, and days in the game. Pick one with the dial button at the top of the screen.';

  @override
  String springsRefund(int count) {
    return 'Clock levels are now 5 mastery tiers, each worth more. The $count Mainsprings you had spent are back — spend them again.';
  }

  @override
  String get dialLockedSeal => 'Loop trophy';

  @override
  String get dialTrack_earned => 'Earnings';

  @override
  String get dialTrack_mastery => 'Clock mastery';

  @override
  String get dialTrack_loops => 'Time Loops';

  @override
  String get dialTrack_feat => 'Feat';

  @override
  String get dialTrack_loyalty => 'Loyalty';

  @override
  String dialLockedTiers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mastery tiers',
      one: '1 mastery tier',
    );
    return '$_temp0';
  }

  @override
  String get dialLockedLoop => 'Get Chronos';

  @override
  String dialLockedChronos(int count) {
    return '$count Chronos in one loop';
  }

  @override
  String dialLockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0 with the daily bonus claimed';
  }

  @override
  String dialProgressCount(String have, String need) {
    return '$have of $need';
  }

  @override
  String loopNumber(int n) {
    return 'Loop $n';
  }

  @override
  String get loopTitle => 'Time Loop';

  @override
  String get loopGoal => 'Loop goal: get Chronos';

  @override
  String get loopGoalDone => 'Goal reached: Chronos is yours';

  @override
  String get loopNoRule => 'No changed rule';

  @override
  String get loopRuleLabel => 'Chronos\' rule';

  @override
  String get loopEndTitle => 'Time is beaten!';

  @override
  String loopEndStats(String time, int count) {
    return 'Play time: $time · Paradoxes: $count';
  }

  @override
  String get loopRewardChapter => 'A new chapter of the Chronicle';

  @override
  String get loopRewardSeal => 'Seal won — it holds for good';

  @override
  String loopRewardDial(String name) {
    return 'Dial face: $name';
  }

  @override
  String get loopNextTitle => 'Next loop';

  @override
  String get loopNextSeal => 'Seal for beating it: ???';

  @override
  String get loopNextFree =>
      'The story is told. From now on you pick the rules of every loop yourself — in the Chronicle.';

  @override
  String get loopStay => 'Stay a while';

  @override
  String loopStayHint(int left) {
    return 'Every bonus of Chronos in this loop pays +1 Mainspring ($left left).';
  }

  @override
  String get loopStart => 'New loop';

  @override
  String get loopConfirmTitle => 'Start a new loop?';

  @override
  String get loopConfirmResets =>
      'Starts from zero: Ticks, clocks, skills, Chronons, shards and perks.';

  @override
  String get loopConfirmKeeps =>
      'Stays: Mainsprings, clock mastery, seals, achievements, dial faces and statistics.';

  @override
  String get loopConfirmYes => 'Start from zero';

  @override
  String get loopConfirmNo => 'Not yet';

  @override
  String get loopBonusToast => 'Chronos bonus';

  @override
  String loopBonusToastBody(int count) {
    return 'Mainsprings: +$count for the next loops';
  }

  @override
  String get chronicleTitle => 'Chronicle';

  @override
  String get chronicleOpen => 'Open the Chronicle';

  @override
  String get chronicleChapters => 'Chapters';

  @override
  String get chronicleSeals => 'Seals';

  @override
  String chronicleChapter(int n) {
    return 'Chapter $n';
  }

  @override
  String chronicleChapterLocked(int n) {
    return 'Finish loop $n';
  }

  @override
  String get chronicleSealLocked => 'Beat this rule to win its seal';

  @override
  String chronicleBest(String time) {
    return 'Best: $time of play';
  }

  @override
  String get chroniclePick => 'Rules of the next loop';

  @override
  String get chroniclePickHint => 'Pick any, several at once, or none.';

  @override
  String chronicleLoopTime(String time, int count) {
    return 'In this loop: $time of play, $count paradoxes';
  }

  @override
  String get adBlockedRule => 'loop rule';

  @override
  String get statLoop => 'Time Loop';

  @override
  String get help_loop_t => 'Time Loop and the Chronicle';

  @override
  String get help_loop =>
      'Buying Chronos finishes the Time Loop: it opens a chapter of the story and lets you start a new loop.\n• A new loop resets everything, Chronons and perks included.\n• Mainsprings, clock mastery, achievements and dial faces stay.\n• In each loop Chronos changes one rule. Finishing such a loop earns a seal: a small permanent bonus and a dial face.\n• Each Chronos bonus earned before you leave the loop gives +1 Mainspring.\nSeven loops tell the whole story; after that you pick the rules. The Chronicle on the paradox screen keeps it all.';

  @override
  String get rule_blindfold => 'Broken Stopwatch';

  @override
  String get rule_blindfold_desc =>
      'Blind mode is always on: the digits vanish about a second before the target. It pays as usual.';

  @override
  String get rule_blindfold_quote =>
      '“Want to be on time? Learn to feel time. No digits.”';

  @override
  String get seal_blindfold => 'A Feel for It';

  @override
  String get seal_blindfold_desc =>
      'Blind mode pays one more (×4, ×5 with Daredevil).';

  @override
  String get rule_inflation => 'Price Hike';

  @override
  String get rule_inflation_desc =>
      'Each clock raises the price of the next one by 20% instead of 15%.';

  @override
  String get rule_inflation_quote =>
      '“Time costs. From now on every second costs more.”';

  @override
  String get seal_inflation => 'Regular Customer';

  @override
  String get seal_inflation_desc => 'The first 10 of every clock cost half.';

  @override
  String get rule_noGold => 'Cloudy Day';

  @override
  String get rule_noGold_desc =>
      'No Golden Second flies in (seasonal events still do).';

  @override
  String get rule_noGold_quote =>
      '“The sun stays behind a cloud. You don\'t get lucky with tea. You turn up for it.”';

  @override
  String get seal_noGold => 'Ray of Sun';

  @override
  String get seal_noGold_desc =>
      'Back after an hour or more: a Golden Second flies in within 30 seconds.';

  @override
  String get rule_shortFuse => 'Short Fuse';

  @override
  String get rule_shortFuse_desc =>
      'The multiplier can climb 0.50 higher than usual, but anything short of a PERFECT resets it. No Shield.';

  @override
  String get rule_shortFuse_quote =>
      '“One sloppy hit and you start over. That\'s how it is with dates.”';

  @override
  String get seal_shortFuse => 'Long Fuse';

  @override
  String get seal_shortFuse_desc => 'The multiplier can climb 0.20 higher.';

  @override
  String get rule_precision => 'Swiss Precision';

  @override
  String get rule_precision_desc =>
      'A GOOD pays you nothing. Only GREAT and PERFECT count.';

  @override
  String get rule_precision_quote => '“A sloppy hit doesn\'t count.”';

  @override
  String get seal_precision => 'Steady Hand';

  @override
  String get seal_precision_desc => 'The PERFECT window is 0.001 s wider.';

  @override
  String get rule_insomnia => 'Insomnia';

  @override
  String get rule_insomnia_desc =>
      'While you\'re away the clocks earn only 25%.';

  @override
  String get rule_insomnia_quote => '“Those who sleep run late. Clocks too.”';

  @override
  String get seal_insomnia => 'Sound Sleep';

  @override
  String get seal_insomnia_desc => 'Offline income counts for 12 more hours.';

  @override
  String get chapter_1_t => 'Summoned';

  @override
  String get chapter_1 =>
      '*: Grandpa\'s garage. An altar, smoke, and the smell of cheesecake.\nchronos: Who summons me?\ngrandpa: Me. Small favour. Every day at five I need to be in the kitchen.\nchronos: You summoned the god of time to make it to tea.\ngrandpa: Afternoon tea. There\'s cheesecake.\ngrandma (from the kitchen): The cake\'s getting cold!\nchronos (freezes): Who was that?\ngrandpa: The wife.\nchronos: I\'m turning time back. To that afternoon tea.\ngrandpa: And the clocks?\nchronos: The clocks won\'t remember. You will. And this time, no digits.';

  @override
  String get chapter_2_t => 'No digits';

  @override
  String get chapter_2 =>
      '*: The garage. The altar. Again.\nchronos: No digits, and still on five. You can feel time.\ngrandpa: Why did you run off last time?\nchronos: Gods don\'t run off. Gods withdraw.\ngrandpa: Grandma asks if you\'d drop by for tea.\nchronos: Gods don\'t drop by.\nchronos: Next lesson: time costs. From now on every second costs more.';

  @override
  String get chapter_3_t => 'Price hike';

  @override
  String get chapter_3 =>
      'chronos: Expensive?\ngrandpa: Less than anniversary flowers. I forgot those, so it came out cheaper.\nchronos (quietly): The fourteenth of May.\ngrandpa: How do you know?\nchronos: I don\'t. Lucky guess.\nchronos: Next lesson: the sun stays behind a cloud. You don\'t get lucky with tea. You turn up for it.';

  @override
  String get chapter_4_t => 'The fourth cup';

  @override
  String get chapter_4 =>
      'chronos: No sun, and you still made it.\nchronos: Who\'s the fourth cup for?\ngrandpa: Grandma always sets one too many. I don\'t ask. Fifty years, I don\'t ask.\nchronos: …\nchronos: Next lesson: one sloppy hit and you start over. That\'s how it is with dates.\ngrandpa: With what?\nchronos: Nothing. Turning time back.';

  @override
  String get chapter_5_t => 'Five seconds';

  @override
  String get chapter_5 =>
      'chronos: Once in my life I stopped time for a human.\ngrandpa: For long?\nchronos: Five seconds.\ngrandpa: For whom?\nchronos: Someone running late. Running with flowers. Losing petals.\ngrandpa: What an idiot.\nchronos: Mm-hm.\nchronos: Next lesson: a sloppy hit doesn\'t count.';

  @override
  String get chapter_6_t => 'Behind the door';

  @override
  String get chapter_6 =>
      '*: The kitchen. The garage door is shut.\ngrandma (to the door): I know you\'re in there.\nchronos (behind the door): I\'m not here.\ngrandma: You haven\'t been here for fifty years. I still cut the cheesecake in four.\ngrandpa (whispering, to you): Who\'s she talking to?\nchronos: Last lesson. No sleeping. Those who sleep run late.';

  @override
  String get chapter_7_t => 'Five sharp';

  @override
  String get chapter_7 =>
      '*: Grandma\'s kitchen. The clock says 4:59.\n*: The door. Grandpa. Early, for the first time ever.\ngrandma: A minute early.\ngrandpa: All by myself. No clocks.\n*: A knock. Five o\'clock sharp.\nchronos: On time.\ngrandma (pours the fourth cup): Sit down.\nchronos: I don\'t do tea.\ngrandma: I know. Fifty years you haven\'t.\ngrandpa: You two know each other?\ngrandma: For five seconds. Back in seventy-four.\nchronos (sits down): …Cheesecake?';

  @override
  String get help_round_t => 'The round';

  @override
  String get help_round =>
      'The stopwatch counts up from zero. Tap the screen when it shows 5.00 — how close you get sets the grade:\n• exactly 5.00 (±0.010 s) — a PERFECT, a bonus of Ticks worth a few seconds of your clocks, and the full multiplier\n• PERFECT (±0.015 s) — 6 Ticks, multiplier +0.05\n• GREAT (±0.030 s) — 3 Ticks\n• GOOD (±0.050 s) — 1 Tick\n• CLOSE (±0.150 s) — a small consolation, the multiplier is lost\nAnything further is a miss. A tap more than a second before 5.00 doesn\'t count. Skills widen the grade windows (except \"exactly 5.00\").';

  @override
  String get help_res_t => 'Resources';

  @override
  String get help_res_tiki => 'Ticks — currency: clocks and skills';

  @override
  String get help_res_chronon =>
      'Chronons — a permanent income multiplier from the paradox';

  @override
  String get help_res_shard => 'Shards of time — the currency of perks';

  @override
  String get help_res_spring => 'Mainsprings — clock mastery';

  @override
  String get helpLocked => 'Keep playing to unlock new mechanics';

  @override
  String get notificationAskBody =>
      'Your clocks earn while the game is closed — but only up to a time limit. We\'ll tell you when they reach it and remind you of the daily bonus. Two notifications at most, never at night.';

  @override
  String get notificationAskYes => 'Yes, let me know';

  @override
  String get notificationAskNo => 'No, thanks';

  @override
  String get prologue_t => 'Prologue: Seven minutes';

  @override
  String get prologue =>
      '*: Grandma\'s kitchen. The table is set for four.\n*: Five o\'clock. Grandpa\'s chair is empty.\ngrandma (hands you a stopwatch): Time him, dear.\n*: Seven minutes later.\ngrandma: Seven minutes.\ngrandpa: Impossible. My watch says five.\ngrandma: Your watch has said five for fifty years.\ngrandpa (whispering, to you): You\'ve got a hand for the stopwatch. Takes after Grandma.\ngrandpa: Tomorrow I\'ll be on the dot. I just need a better clock.\ngrandma: There\'s only one clock that\'s never wrong.\ngrandpa: Chronos. I know. I\'ve read about him.\ngrandma (looks at the fourth cup): We don\'t talk about him at the table.\ngrandpa (whispering, to you): But we can get him. We\'ll start with smaller clocks.';

  @override
  String get prologueGoal => 'Goal: get Chronos';

  @override
  String get prologueGo => 'Let\'s go!';

  @override
  String get chroniclePrologue => 'Prologue';

  @override
  String get calibTitle => 'Calibration';

  @override
  String get calibIntro =>
      'Every phone registers touches and shows the picture a little late. Tap 10 times when the stopwatch shows 5.00: the game measures how late you usually are and takes that off from now on. Your precision stays yours — only the constant delay goes away.';

  @override
  String calibCurrent(String offset) {
    return 'Current offset: $offset';
  }

  @override
  String get calibStart => 'Start';

  @override
  String get calibTapHint => 'Tap at 5.00';

  @override
  String get calibNoTap => 'No tap — again';

  @override
  String calibResultLate(int ms) {
    return 'Your taps register $ms ms late on average.';
  }

  @override
  String calibResultEarly(int ms) {
    return 'Your taps register $ms ms early on average.';
  }

  @override
  String get calibResultZero =>
      'Your taps land right on time — no offset needed.';

  @override
  String get calibUnreliable =>
      'The taps were very scattered. Try again calmly, watching the digits.';

  @override
  String calibApply(String offset) {
    return 'Apply ($offset)';
  }

  @override
  String get calibRepeat => 'Again';

  @override
  String get calibReset => 'Reset to 0 ms';

  @override
  String settingsCalibration(String offset) {
    return 'Input lag calibration: $offset';
  }

  @override
  String settingsCalibrationHint(String offset) {
    return 'Your recent taps average $offset — calibrating may help.';
  }

  @override
  String get adShowFailed =>
      'The ad couldn\'t be shown — no reward, and the offer is still yours. Try again in a moment.';

  @override
  String get welcomeTitle => 'Welcome back!';

  @override
  String get collectAll => 'Collect all';

  @override
  String welcomeSeason(String season) {
    return '$season is on! The badge at the top shows your progress.';
  }

  @override
  String get dailyGrace =>
      'You missed a day — this week\'s grace day kept your streak.';

  @override
  String get statsAskTitle => 'Help us tune the game?';

  @override
  String get statsAskBody =>
      'May the game send anonymous gameplay statistics and crash reports? No account, no name, no ad ID. You can change this in the settings anytime.';

  @override
  String get statsAskYes => 'Yes, send them';

  @override
  String get statsAskNo => 'No, thanks';

  @override
  String get buyAmountNext => 'BONUS';

  @override
  String get notificationOfflineBody =>
      'The offline limit is full: from now on waiting earns nothing more.';

  @override
  String notificationDailyTitle(int day, int days) {
    return 'Daily bonus waiting — day $day/$days';
  }

  @override
  String get notificationDailyBody =>
      'Drop in to collect it and keep your streak going.';

  @override
  String get notificationReserveTitle => 'Winding reserve full';

  @override
  String notificationReserveBody(String time) {
    return 'Exact 5.00s wind your Mainspring again — $time each.';
  }

  @override
  String get settingsNotificationsHint =>
      'The offline limit, the daily bonus, a full winding reserve. Two at most, never at night.';

  @override
  String get cloudOfferTitle => 'Cloud save found';

  @override
  String cloudOfferBody(
    String cloudTime,
    String cloudEarned,
    String localTime,
    String localEarned,
  ) {
    return 'Google Play Games has a save with more progress:\n• in the cloud: $cloudTime played, $cloudEarned Ticks earned\n• on this phone: $localTime played, $localEarned Ticks earned\nLoad the cloud save? This phone\'s progress will be replaced.';
  }

  @override
  String get cloudLoad => 'Load from the cloud';

  @override
  String get cloudKeep => 'Keep this phone\'s';

  @override
  String get settingsCloud => 'Cloud save (Google Play Games)';

  @override
  String get settingsCloudOn =>
      'Connected: the game saves to the cloud whenever you leave it.';

  @override
  String get settingsCloudOff =>
      'Keeps your progress when you change or reset your phone.';

  @override
  String get settingsCloudConnect => 'Connect Google Play Games';

  @override
  String get settingsCloudRestore => 'Load from the cloud';

  @override
  String get settingsCloudNothing =>
      'The cloud has no save with more progress than this phone.';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengesToday => 'Today';

  @override
  String get challengesWeek => 'This week';

  @override
  String get challengesRerollHint =>
      'Don\'t like one? ↻ swaps it — once a day.';

  @override
  String get challengesNewTomorrow => 'New ones at midnight.';

  @override
  String challengesDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String chGreat(int n) {
    return 'Hit GREAT or better $n times';
  }

  @override
  String chStreak(int n) {
    return '$n hits in a row';
  }

  @override
  String chJackpot(int n) {
    return 'Stop the watch at exactly 5.00 ($n×)';
  }

  @override
  String chPerfectWindow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n PERFECTs',
      one: '1 PERFECT',
    );
    return '$_temp0 within 10 rounds in a row';
  }

  @override
  String chHitEarnings(String amount) {
    return 'Earn $amount Ticks from hits';
  }

  @override
  String chBuyClocks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n clocks',
      one: '1 clock',
    );
    return 'Buy $_temp0';
  }

  @override
  String chMilestones(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n clock bonuses',
      one: 'a clock bonus',
    );
    return 'Earn $_temp0';
  }

  @override
  String chSkillLevels(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skill levels',
      one: '1 skill level',
    );
    return 'Buy $_temp0';
  }

  @override
  String chGolden(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Golden Seconds',
      one: 'a Golden Second',
    );
    return 'Catch $_temp0';
  }

  @override
  String chSpring(String hours) {
    return 'Wind the Mainspring $hours h with exact 5.00s';
  }

  @override
  String get challengeClaimed => 'Claimed';

  @override
  String get challengeReroll => 'Swap for another (once a day)';

  @override
  String challengeBonus(int done, int total) {
    return 'All three today: $done/$total';
  }

  @override
  String get challengeBonusDone => 'All three done today — well played!';

  @override
  String challengeBonusPaid(String amount) {
    return 'All three today! Bonus +$amount Ticks';
  }

  @override
  String get challengeDone => 'Challenge done!';

  @override
  String get challengeOpen => 'Claim';

  @override
  String challengeCarry(String what) {
    return 'Yesterday\'s finished challenges paid out: $what';
  }

  @override
  String challengeCarrySprings(int n) {
    return '+$n Mainspring';
  }

  @override
  String get tip_challenges =>
      'New: three challenges a day and one a week. Tap to see them!';

  @override
  String get help_challenges_t => 'Challenges';

  @override
  String get help_challenges =>
      'Every day three challenges, every week one more — the target shows on the badge at the top. Their numbers come from your own last taps, so they are a stretch whatever your aim, and a few minutes of play usually does it.\n• Each daily one pays 10 minutes of your clocks\' income, all three together another 30.\n• The weekly one pays 1 Mainspring (before the first paradox: an hour of income).\n• Don\'t like one? ↻ swaps a daily challenge, once a day.\n• Finished but not claimed? It is paid when the new ones come — nothing is lost.';

  @override
  String chPerfect(int n) {
    return 'Hit PERFECT $n times';
  }

  @override
  String get story_atomic_t => 'Atomic clock';

  @override
  String get story_atomic =>
      'grandpa: An atomic clock. Off by a second every hundred million years.\ngrandpa: Tomorrow I\'m in the kitchen at five sharp.\ngrandma: You said that about the cuckoo.\ngrandpa: The cuckoo was from a fair.\ngrandma: And the lateness?\ngrandpa: …Force of habit.';

  @override
  String get story_paradox_t => 'Backwards';

  @override
  String get story_paradox =>
      '*: Every clock in the garage spins backwards.\ngrandpa: It worked! We turned time back!\ngrandma (from the kitchen): Did you blow a fuse again?\nchronos (from very far away): Who\'s fiddling with my clocks?\ngrandpa (whispering, to you): We act like nothing happened.';

  @override
  String get story_timeMachine_t => 'Seventy-four';

  @override
  String get story_timeMachine =>
      'grandpa: A time machine. I\'d go back to seventy-four.\ngrandma: What for?\ngrandpa: To turn up for our first date on time.\ngrandma: You did turn up on time.\ngrandpa: I ran like mad. I was sure I\'d be late.\ngrandma (quietly): Someone helped you.';

  @override
  String get story_altar_t => 'The altar';

  @override
  String get story_altar =>
      'grandpa: The altar\'s ready. A few more Ticks and we summon Chronos.\ngrandma: Then at least comb your hair.\ngrandpa: What for?\ngrandma: You don\'t greet guests looking like that.\ngrandpa (whispering, to you): What guests?';

  @override
  String get storyNext => 'Next';

  @override
  String get storySkip => 'Skip';

  @override
  String get storyTapHint => 'Tap to continue';

  @override
  String get who_grandpa => 'Grandpa';

  @override
  String get who_grandma => 'Grandma';

  @override
  String get who_chronos => 'Chronos';

  @override
  String get welcomeLine_1 =>
      'grandpa: There you are! Grandma\'s set the table. One cup too many, as usual.';

  @override
  String get welcomeLine_2 =>
      'grandma: Sit down, dear. Grandpa\'s still in the garage. \"Calibrating\".';

  @override
  String get welcomeLine_3 =>
      'grandpa: The clocks worked all night. So did I. Grandma says it shows.';

  @override
  String get welcomeLine_4 =>
      'grandma: Cheesecake\'s here. The clock\'s here. Grandpa isn\'t. A normal day.';

  @override
  String get welcomeLine_5 =>
      'grandpa: I set every clock to five. Now they all chime at once. Grandma is not thrilled.';

  @override
  String get welcomeLine_6 =>
      'grandma: Leave that fourth cup alone. It\'s waiting for someone.';

  @override
  String get welcomeLine_7 =>
      'grandpa: Grandma has never once been late. Fifty years. It\'s not normal.';

  @override
  String get master_grandpa_5 => 'Retired Watchmaker';

  @override
  String get master_grandpa_5_desc =>
      'Fixes the neighbours\' watches. Free, with a lecture.';

  @override
  String get master_grandpa_10 => 'Grandpa Knows Best';

  @override
  String get master_grandpa_10_desc => 'And he\'s right. Sadly.';

  @override
  String get master_grandma_5 => 'The Perfect Egg';

  @override
  String get master_grandma_5_desc => 'Not a second too long. Not one.';

  @override
  String get master_grandma_10 => 'Turbo Grandma';

  @override
  String get master_grandma_10_desc => 'The egg timer is scared of her.';

  @override
  String get master_cuckoo_5 => 'Cuckoo with a Degree';

  @override
  String get master_cuckoo_5_desc =>
      'Cuckoos on time. Insists on being called Doctor.';

  @override
  String get master_cuckoo_10 => 'Celebrity Cuckoo';

  @override
  String get master_cuckoo_10_desc =>
      'Leaves the little house only for interviews.';

  @override
  String get master_metronome_5 => 'Tick Virtuoso';

  @override
  String get master_metronome_5_desc => 'Tick. Tock. Applause.';

  @override
  String get master_metronome_10 => 'Philharmonic Metronome';

  @override
  String get master_metronome_10_desc => 'Conducts the conductor.';

  @override
  String get master_watchmaker_5 => 'Golden Loupe';

  @override
  String get master_watchmaker_5_desc => 'Sees atoms. And the dust on them.';

  @override
  String get master_watchmaker_10 => 'Guild Master';

  @override
  String get master_watchmaker_10_desc =>
      'Even sundials come to him for advice.';

  @override
  String get master_sprintJudge_5 => 'Eagle-eyed Judge';

  @override
  String get master_sprintJudge_5_desc =>
      'Spots a false start before the runner thinks of it.';

  @override
  String get master_sprintJudge_10 => 'Olympic Judge';

  @override
  String get master_sprintJudge_10_desc =>
      'Gold-plated whistle. Patience not included.';

  @override
  String get master_stationClock_5 => 'Train on Time';

  @override
  String get master_stationClock_5_desc =>
      'Passengers don\'t believe it. They take photos.';

  @override
  String get master_stationClock_10 => 'Zero-delay Station';

  @override
  String get master_stationClock_10_desc =>
      '\"Subject to change\" is now in a museum.';

  @override
  String get master_quartz_5 => 'Flawless Crystal';

  @override
  String get master_quartz_5_desc =>
      'Vibrates exactly 32,768 times. We checked.';

  @override
  String get master_quartz_10 => 'Royal Quartz';

  @override
  String get master_quartz_10_desc => 'Worn at court instead of a crown.';

  @override
  String get master_atomic_5 => 'Atom of Calm';

  @override
  String get master_atomic_5_desc => 'Electrons tiptoe around it.';

  @override
  String get master_atomic_10 => 'The Standard Second';

  @override
  String get master_atomic_10_desc => 'A second lasts as long as it says.';

  @override
  String get master_gps_5 => 'Never-lost Satellite';

  @override
  String get master_gps_5_desc => 'Never says \"make a U-turn when possible\".';

  @override
  String get master_gps_10 => 'Lord of the Orbit';

  @override
  String get master_gps_10_desc => 'Other satellites set themselves by it.';

  @override
  String get master_pulsar_5 => 'Pulsar with Rhythm';

  @override
  String get master_pulsar_5_desc => 'The universe taps its foot along.';

  @override
  String get master_pulsar_10 => 'Lighthouse of the Galaxy';

  @override
  String get master_pulsar_10_desc => 'Alien ships set their watches by it.';

  @override
  String get master_timeMachine_5 => 'Return Ticket';

  @override
  String get master_timeMachine_5_desc => 'Back before it leaves. Never late.';

  @override
  String get master_timeMachine_10 => 'Perfect Loop';

  @override
  String get master_timeMachine_10_desc => 'Met itself. Both hit 5.00.';

  @override
  String get master_schrodinger_5 => 'Observed Cat';

  @override
  String get master_schrodinger_5_desc =>
      'Hits when you look. When you don\'t, too.';

  @override
  String get master_schrodinger_10 => 'Cat in Both Boxes';

  @override
  String get master_schrodinger_10_desc =>
      'Asleep and on target at once. Purrs in superposition.';

  @override
  String get master_chronos_5 => 'Chronos on Holiday';

  @override
  String get master_chronos_5_desc =>
      'Time flows on its own, and still on the dot.';

  @override
  String get master_chronos_10 => 'Lord of All Seconds';

  @override
  String get master_chronos_10_desc =>
      'Even the second that just passed was his.';

  @override
  String get trait_grandpa_1 => 'After-Lunch Nap';

  @override
  String trait_grandpa_1_desc(String a) {
    return 'Offline income limit +$a.';
  }

  @override
  String get trait_grandpa_2 => 'Snores in Time';

  @override
  String trait_grandpa_2_desc(String a) {
    return 'Offline income +$a.';
  }

  @override
  String get trait_grandma_1 => 'Grandma Remembers';

  @override
  String get trait_grandma_1_desc =>
      'A single missed day never breaks the daily bonus streak, not just once a week.';

  @override
  String get trait_grandma_2 => 'Sunday Dinner';

  @override
  String trait_grandma_2_desc(String a) {
    return 'Day 7 of the daily bonus gives $a Mainsprings instead of 1.';
  }

  @override
  String get trait_cuckoo_1 => 'Cuckoo on the Hour';

  @override
  String get trait_cuckoo_1_desc =>
      'On every full hour while you play, an extra Golden Second flies out.';

  @override
  String get trait_cuckoo_2 => 'Half-Past Cuckoo';

  @override
  String get trait_cuckoo_2_desc => 'The cuckoo also comes out at half past.';

  @override
  String get trait_metronome_1 => 'Steady Tempo';

  @override
  String trait_metronome_1_desc(String a) {
    return 'The winding reserve refills $a faster.';
  }

  @override
  String get trait_metronome_2 => 'Longer Bar';

  @override
  String trait_metronome_2_desc(String a) {
    return 'The winding reserve is $a bigger.';
  }

  @override
  String get trait_watchmaker_1 => 'Mr Henry\'s Discount';

  @override
  String trait_watchmaker_1_desc(String a) {
    return 'Perks cost $a less.';
  }

  @override
  String get trait_watchmaker_2 => 'Friend of the Trade';

  @override
  String trait_watchmaker_2_desc(String a) {
    return 'Perks cost $a less in all.';
  }

  @override
  String get trait_sprintJudge_1 => 'On Your Marks!';

  @override
  String trait_sprintJudge_1_desc(String a, String b, String c) {
    return 'After a break of $a or more, your first $b hits pay ×(1 + hours away), up to $c.';
  }

  @override
  String get trait_sprintJudge_2 => 'Long Sprint';

  @override
  String trait_sprintJudge_2_desc(String a) {
    return '“On Your Marks!” covers $a hits.';
  }

  @override
  String get trait_stationClock_1 => 'On Schedule';

  @override
  String trait_stationClock_1_desc(String a) {
    return 'Golden Seconds come $a more often.';
  }

  @override
  String get trait_stationClock_2 => 'Express';

  @override
  String trait_stationClock_2_desc(String a) {
    return 'Every ${a}th Golden Second you catch has double the effect.';
  }

  @override
  String get trait_quartz_1 => 'Quartz Accuracy';

  @override
  String trait_quartz_1_desc(String a) {
    return 'All clocks earn +$a.';
  }

  @override
  String get trait_quartz_2 => 'Synchronisation';

  @override
  String trait_quartz_2_desc(String a, String b) {
    return '+$a to all clocks for every clock at mastery tier 5 (now +$b).';
  }

  @override
  String get trait_atomic_1 => 'To the Second';

  @override
  String trait_atomic_1_desc(String a) {
    return 'A Mainspring winds in $a instead of 24 h.';
  }

  @override
  String get trait_atomic_2 => 'Half-Life';

  @override
  String trait_atomic_2_desc(String a) {
    return 'A Mainspring winds in $a.';
  }

  @override
  String get trait_gps_1 => 'Route Planned';

  @override
  String trait_gps_1_desc(String a) {
    return 'All three daily challenges wind $a of a Mainspring on top.';
  }

  @override
  String get trait_gps_2 => 'Destination Reached';

  @override
  String trait_gps_2_desc(String a) {
    return 'The weekly challenge gives +$a Mainspring.';
  }

  @override
  String get trait_pulsar_1 => 'Signal from Space';

  @override
  String trait_pulsar_1_desc(String a) {
    return 'Golden Second effects are $a stronger.';
  }

  @override
  String get trait_pulsar_2 => 'Long Pulse';

  @override
  String trait_pulsar_2_desc(String a) {
    return 'Frenzy lasts $a longer.';
  }

  @override
  String get trait_timeMachine_1 => 'Return Ticket';

  @override
  String trait_timeMachine_1_desc(String a) {
    return 'A new loop starts with $a Chronons and Shards.';
  }

  @override
  String get trait_timeMachine_2 => 'Hand Luggage';

  @override
  String trait_timeMachine_2_desc(String a) {
    return 'A new loop starts with $a Chronons and Shards.';
  }

  @override
  String get trait_schrodinger_1 => 'Alive or Not?';

  @override
  String trait_schrodinger_1_desc(String a, String b) {
    return 'At a paradox, a coin toss: $a chance of +$b Chronons.';
  }

  @override
  String get trait_schrodinger_2 => 'Nine Lives';

  @override
  String trait_schrodinger_2_desc(String a) {
    return 'A won toss gives +$a Chronons.';
  }

  @override
  String get trait_chronos_1 => 'Friends with Time';

  @override
  String trait_chronos_1_desc(String a, String b) {
    return 'The “Chronos” perk costs $a instead of $b Shards.';
  }

  @override
  String get trait_chronos_2 => 'Generous Time';

  @override
  String trait_chronos_2_desc(String a) {
    return 'Every Chronos bonus gives $a Mainsprings instead of 1.';
  }

  @override
  String get dial_classic => 'Classic';

  @override
  String get dial_classic_desc => 'White, clean, reliable.';

  @override
  String get dial_wood => 'Woodgrain';

  @override
  String get dial_wood_desc => 'Smells like Grandpa\'s workshop.';

  @override
  String get dial_porcelain => 'Grandma\'s Porcelain';

  @override
  String get dial_porcelain_desc => 'From the good china. Don\'t drop it.';

  @override
  String get dial_brass => 'Brass';

  @override
  String get dial_brass_desc => 'Shines like a town hall door handle.';

  @override
  String get dial_station => 'Station';

  @override
  String get dial_station_desc =>
      'Big, so you can see the delay from far away.';

  @override
  String get dial_swiss => 'Swiss';

  @override
  String get dial_swiss_desc => 'Red, precise and a little smug.';

  @override
  String get dial_quartz => 'Quartz LCD';

  @override
  String get dial_quartz_desc => 'Green digits, like an 80s alarm clock.';

  @override
  String get dial_atomic => 'Atomic';

  @override
  String get dial_atomic_desc =>
      'Glows faintly blue. Apparently that\'s normal.';

  @override
  String get dial_neon => 'Neon';

  @override
  String get dial_neon_desc => 'For playing after midnight.';

  @override
  String get dial_cosmic => 'Cosmic';

  @override
  String get dial_cosmic_desc => 'Stars behind, seconds in front.';

  @override
  String get dial_golden => 'Golden';

  @override
  String get dial_golden_desc => 'Solid gold. Well, almost.';

  @override
  String get dial_rift => 'Spacetime Rift';

  @override
  String get dial_rift_desc =>
      'Through the crack you can see yesterday\'s 5.00.';

  @override
  String traitTier(String level) {
    return 'Tier $level';
  }

  @override
  String traitHidden(String level) {
    return 'Revealed at tier $level';
  }

  @override
  String get traitActive => 'Active';

  @override
  String get traitsTitle => 'Clock traits';

  @override
  String traitToastNew(String clock) {
    return 'New trait · $clock';
  }

  @override
  String traitCuckooToast(String time) {
    return 'Cuckoo · $time';
  }

  @override
  String get traitCuckooTitle => 'Cuckoo! A Golden Second';

  @override
  String get traitWarmUpToast => 'On Your Marks! · Sprint Judge';

  @override
  String traitWarmUpTitle(int hits, String mult) {
    return 'Hits: $hits × $mult';
  }

  @override
  String get traitExpressToast => 'Express · Station Clock';

  @override
  String get traitExpressTitle => 'Double Golden Second!';

  @override
  String get traitLoopToast => 'Time Machine';

  @override
  String traitLoopTitle(int count) {
    return 'To start the loop: +$count ✦';
  }

  @override
  String traitExpressCount(int count, int every) {
    return 'Towards the Express: $count/$every';
  }

  @override
  String chipWarmUp(String mult, int hits) {
    return 'On Your Marks! $mult · $hits left';
  }

  @override
  String coinWon(int count) {
    return 'The cat lives! Toss won: +$count ✦';
  }

  @override
  String get coinLost => 'The cat… not this time. Toss lost.';

  @override
  String coinChance(String chance, String bonus) {
    return 'Schrödinger\'s Cat: $chance chance of +$bonus Chronons';
  }

  @override
  String traitGpsPaid(String time) {
    return 'Route Planned: Mainspring +$time';
  }

  @override
  String perkDiscount(String pct) {
    return 'Watchmaker: perks −$pct';
  }
}
