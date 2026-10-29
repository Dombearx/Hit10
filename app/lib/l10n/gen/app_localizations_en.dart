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
  String get missClose => 'CLOSE!';

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
  String get skill_fastForward => 'Late Start';

  @override
  String get skill_fastForward_desc =>
      'The stopwatch starts later, at the same pace. Shorter rounds, more of them per minute.';

  @override
  String get skill_fastForward_label => 'Starts at';

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
  String get skill_bulletTime => 'Cold Blood';

  @override
  String get skill_bulletTime_desc =>
      'A steadier hand at 10.00: wider hit windows, the clock stays the same.';

  @override
  String get skill_bulletTime_label => 'Hit windows';

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
  String get ach_hidden_nap_desc =>
      'Put the phone down until the stopwatch stops by itself';

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
  String get perk_muscleMemory1_desc => 'Late Start survives the paradox';

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

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sound effects';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsNotifications => 'Tell me when the clocks are full';

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
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint =>
      'No shakes or flashes, fewer particles';

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
  String get settingsImportBad => 'That doesn\'t look like a Hit10 save.';

  @override
  String get settingsReset => 'Start over';

  @override
  String get settingsResetConfirm1 =>
      'Sure? You lose everything: Tiki, clocks, Chronons and achievements. Settings stay.';

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
      'Art: Microsoft Fluent Emoji (MIT).\nFonts: Paytone One and Nunito (SIL Open Font License 1.1).\nSounds and music: our own, synthesised in code.';

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
  String get upg_grandpa_4_desc => 'Solved in exactly 10.00 s.';

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
  String get upg_grandma_5 => '“Ten-Second Recipes”';

  @override
  String get upg_grandma_5_desc => 'Quick dishes only.';

  @override
  String get upg_grandma_6 => 'Induction Hob';

  @override
  String get upg_grandma_6_desc => 'Boils before you think.';

  @override
  String get upg_grandma_7 => 'Influencer Granddaughter';

  @override
  String get upg_grandma_7_desc => 'Films every perfect 10.00.';

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
  String get upg_watchmaker_3_desc => 'Learns on your Tiki.';

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
  String get upg_stationClock_3_desc => '“The 10.00 will arrive on time.”';

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
  String get upg_quartz_7_desc => 'Counts Tiki on the fly.';

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
      'Practises the same ten seconds forever.';

  @override
  String get upg_timeMachine_5 => 'Spare Timeline';

  @override
  String get upg_timeMachine_5_desc => 'Just in case.';

  @override
  String get upg_timeMachine_6 => 'Tours to 10.00';

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
  String get upg_schrodinger_7_desc => 'In one of them it\'s always 10.00.';

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
  String get upg_chronos_8_desc => '10.00. Always was, always will be.';

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
  String dailyHint(int total) {
    return 'Come back every day — the bonus grows for $total days. Missing one starts over.';
  }
}
