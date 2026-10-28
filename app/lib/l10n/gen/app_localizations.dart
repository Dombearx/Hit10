import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// App name shown in the launcher and title bar
  ///
  /// In en, this message translates to:
  /// **'Hit10'**
  String get appTitle;

  /// One-line pitch on the start screen
  ///
  /// In en, this message translates to:
  /// **'Tap at exactly 10.00'**
  String get tagline;

  /// No description provided for @tikiLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticks'**
  String get tikiLabel;

  /// No description provided for @tierPerfect.
  ///
  /// In en, this message translates to:
  /// **'PERFECT!'**
  String get tierPerfect;

  /// No description provided for @tierGreat.
  ///
  /// In en, this message translates to:
  /// **'GREAT!'**
  String get tierGreat;

  /// No description provided for @tierGood.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get tierGood;

  /// No description provided for @missEarly.
  ///
  /// In en, this message translates to:
  /// **'TOO EARLY'**
  String get missEarly;

  /// No description provided for @missLate.
  ///
  /// In en, this message translates to:
  /// **'TOO LATE'**
  String get missLate;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// Decimal separator for numbers in this language (docs/04 U-16)
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get decimalSeparator;

  /// No description provided for @gen_grandpa.
  ///
  /// In en, this message translates to:
  /// **'Grandpa with a Pocket Watch'**
  String get gen_grandpa;

  /// No description provided for @gen_grandpa_desc.
  ///
  /// In en, this message translates to:
  /// **'“Back in my day a second lasted longer.”'**
  String get gen_grandpa_desc;

  /// No description provided for @gen_grandma.
  ///
  /// In en, this message translates to:
  /// **'Grandma with an Egg Timer'**
  String get gen_grandma;

  /// No description provided for @gen_grandma_desc.
  ///
  /// In en, this message translates to:
  /// **'Soft-boiled eggs since 1974. Ten seconds? Child\'s play.'**
  String get gen_grandma_desc;

  /// No description provided for @gen_cuckoo.
  ///
  /// In en, this message translates to:
  /// **'Cuckoo'**
  String get gen_cuckoo;

  /// No description provided for @gen_cuckoo_desc.
  ///
  /// In en, this message translates to:
  /// **'Cuckoos every ten seconds. Usually.'**
  String get gen_cuckoo_desc;

  /// No description provided for @gen_metronome.
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get gen_metronome;

  /// No description provided for @gen_metronome_desc.
  ///
  /// In en, this message translates to:
  /// **'Tick. Tock. Tick. Tock. Never gets bored.'**
  String get gen_metronome_desc;

  /// No description provided for @gen_watchmaker.
  ///
  /// In en, this message translates to:
  /// **'Watchmaker'**
  String get gen_watchmaker;

  /// No description provided for @gen_watchmaker_desc.
  ///
  /// In en, this message translates to:
  /// **'Loupe in the eye, peace in the soul.'**
  String get gen_watchmaker_desc;

  /// No description provided for @gen_sprintJudge.
  ///
  /// In en, this message translates to:
  /// **'Sprint Judge'**
  String get gen_sprintJudge;

  /// No description provided for @gen_sprintJudge_desc.
  ///
  /// In en, this message translates to:
  /// **'False start! Then a perfect 10.00.'**
  String get gen_sprintJudge_desc;

  /// No description provided for @gen_stationClock.
  ///
  /// In en, this message translates to:
  /// **'Station Clock'**
  String get gen_stationClock;

  /// No description provided for @gen_stationClock_desc.
  ///
  /// In en, this message translates to:
  /// **'Delays may vary. Still tries a lot.'**
  String get gen_stationClock_desc;

  /// No description provided for @gen_quartz.
  ///
  /// In en, this message translates to:
  /// **'Quartz Clock'**
  String get gen_quartz;

  /// No description provided for @gen_quartz_desc.
  ///
  /// In en, this message translates to:
  /// **'32,768 wiggles a second, not one too many.'**
  String get gen_quartz_desc;

  /// No description provided for @gen_atomic.
  ///
  /// In en, this message translates to:
  /// **'Atomic Clock'**
  String get gen_atomic;

  /// No description provided for @gen_atomic_desc.
  ///
  /// In en, this message translates to:
  /// **'Off by a second every hundred million years.'**
  String get gen_atomic_desc;

  /// No description provided for @gen_gps.
  ///
  /// In en, this message translates to:
  /// **'GPS Satellite'**
  String get gen_gps;

  /// No description provided for @gen_gps_desc.
  ///
  /// In en, this message translates to:
  /// **'Knows where you are. And exactly what time it is.'**
  String get gen_gps_desc;

  /// No description provided for @gen_pulsar.
  ///
  /// In en, this message translates to:
  /// **'Pulsar'**
  String get gen_pulsar;

  /// No description provided for @gen_pulsar_desc.
  ///
  /// In en, this message translates to:
  /// **'A neutron star that ticks like clockwork.'**
  String get gen_pulsar_desc;

  /// No description provided for @gen_timeMachine.
  ///
  /// In en, this message translates to:
  /// **'Time Machine'**
  String get gen_timeMachine;

  /// No description provided for @gen_timeMachine_desc.
  ///
  /// In en, this message translates to:
  /// **'Hits before it taps.'**
  String get gen_timeMachine_desc;

  /// No description provided for @gen_schrodinger.
  ///
  /// In en, this message translates to:
  /// **'Schrödinger\'s Cat'**
  String get gen_schrodinger;

  /// No description provided for @gen_schrodinger_desc.
  ///
  /// In en, this message translates to:
  /// **'Hit and missed. Until you open the box.'**
  String get gen_schrodinger_desc;

  /// No description provided for @gen_chronos.
  ///
  /// In en, this message translates to:
  /// **'Chronos'**
  String get gen_chronos;

  /// No description provided for @gen_chronos_desc.
  ///
  /// In en, this message translates to:
  /// **'God of time. Never misses. Ever.'**
  String get gen_chronos_desc;

  /// No description provided for @syn_grandparents.
  ///
  /// In en, this message translates to:
  /// **'Grandparents\' Date Night'**
  String get syn_grandparents;

  /// No description provided for @syn_birdRhythm.
  ///
  /// In en, this message translates to:
  /// **'Bird Rhythm'**
  String get syn_birdRhythm;

  /// No description provided for @syn_craftsmanship.
  ///
  /// In en, this message translates to:
  /// **'Craft Meets Quartz'**
  String get syn_craftsmanship;

  /// No description provided for @syn_photoFinish.
  ///
  /// In en, this message translates to:
  /// **'Photo Finish'**
  String get syn_photoFinish;

  /// No description provided for @syn_cosmicBeat.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Beat'**
  String get syn_cosmicBeat;

  /// No description provided for @syn_delayedTrain.
  ///
  /// In en, this message translates to:
  /// **'Train from the Future'**
  String get syn_delayedTrain;

  /// No description provided for @perSecond.
  ///
  /// In en, this message translates to:
  /// **'{value}/s'**
  String perSecond(String value);

  /// No description provided for @tabClocks.
  ///
  /// In en, this message translates to:
  /// **'Clocks'**
  String get tabClocks;

  /// No description provided for @tabSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get tabSkills;

  /// No description provided for @buyAmountMax.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get buyAmountMax;

  /// No description provided for @ownedCount.
  ///
  /// In en, this message translates to:
  /// **'×{count}'**
  String ownedCount(int count);

  /// No description provided for @unitRate.
  ///
  /// In en, this message translates to:
  /// **'{value}/s each'**
  String unitRate(String value);

  /// No description provided for @incomeShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of income'**
  String incomeShare(String percent);

  /// No description provided for @windowBonus.
  ///
  /// In en, this message translates to:
  /// **'windows ×{value}'**
  String windowBonus(String value);

  /// No description provided for @lockedName.
  ///
  /// In en, this message translates to:
  /// **'???'**
  String get lockedName;

  /// No description provided for @lockedHint.
  ///
  /// In en, this message translates to:
  /// **'Buy the previous clock to reveal'**
  String get lockedHint;

  /// No description provided for @upgradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrades'**
  String get upgradesTitle;

  /// No description provided for @upgradeName.
  ///
  /// In en, this message translates to:
  /// **'{generator} {level}'**
  String upgradeName(String generator, String level);

  /// No description provided for @upgradeEffect.
  ///
  /// In en, this message translates to:
  /// **'{generator} earn ×2'**
  String upgradeEffect(String generator);

  /// No description provided for @upgradeRequires.
  ///
  /// In en, this message translates to:
  /// **'Needs {count} owned'**
  String upgradeRequires(int count);

  /// No description provided for @synergyEffect.
  ///
  /// In en, this message translates to:
  /// **'{a} +{aPct}% per {b} · {b} +{bPct}% per {a}'**
  String synergyEffect(String a, String b, String aPct, String bPct);

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost: {value}'**
  String cost(String value);

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'While you were away…'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Your clocks kept ticking for {duration}.'**
  String offlineBody(String duration);

  /// No description provided for @offlineCapped.
  ///
  /// In en, this message translates to:
  /// **'(counted up to {duration})'**
  String offlineCapped(String duration);

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @durationHm.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHm(int hours, int minutes);

  /// No description provided for @durationM.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationM(int minutes);

  /// No description provided for @saveCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Your save could not be read, so the game started fresh.'**
  String get saveCorrupt;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @skill_power.
  ///
  /// In en, this message translates to:
  /// **'Strike Power'**
  String get skill_power;

  /// No description provided for @skill_power_desc.
  ///
  /// In en, this message translates to:
  /// **'Every hit pays more.'**
  String get skill_power_desc;

  /// No description provided for @skill_power_label.
  ///
  /// In en, this message translates to:
  /// **'Hit reward'**
  String get skill_power_label;

  /// No description provided for @skill_fastForward.
  ///
  /// In en, this message translates to:
  /// **'Fast Forward'**
  String get skill_fastForward;

  /// No description provided for @skill_fastForward_desc.
  ///
  /// In en, this message translates to:
  /// **'The start of a round flies by. More rounds per minute.'**
  String get skill_fastForward_desc;

  /// No description provided for @skill_fastForward_label.
  ///
  /// In en, this message translates to:
  /// **'Speed up to 9.00'**
  String get skill_fastForward_label;

  /// No description provided for @skill_ticking.
  ///
  /// In en, this message translates to:
  /// **'Ticking'**
  String get skill_ticking;

  /// No description provided for @skill_ticking_desc.
  ///
  /// In en, this message translates to:
  /// **'A tick in the last second helps you find the beat.'**
  String get skill_ticking_desc;

  /// No description provided for @skill_ticking_label.
  ///
  /// In en, this message translates to:
  /// **'Ticking'**
  String get skill_ticking_label;

  /// No description provided for @skill_wideEye.
  ///
  /// In en, this message translates to:
  /// **'Hawk Eye'**
  String get skill_wideEye;

  /// No description provided for @skill_wideEye_desc.
  ///
  /// In en, this message translates to:
  /// **'Wider GREAT and GOOD windows. For you and your clocks.'**
  String get skill_wideEye_desc;

  /// No description provided for @skill_wideEye_label.
  ///
  /// In en, this message translates to:
  /// **'GREAT window'**
  String get skill_wideEye_label;

  /// No description provided for @skill_combo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get skill_combo;

  /// No description provided for @skill_combo_desc.
  ///
  /// In en, this message translates to:
  /// **'A higher streak cap; the streak multiplies the whole payout.'**
  String get skill_combo_desc;

  /// No description provided for @skill_combo_label.
  ///
  /// In en, this message translates to:
  /// **'Streak cap'**
  String get skill_combo_label;

  /// No description provided for @skill_magnet.
  ///
  /// In en, this message translates to:
  /// **'Magnet'**
  String get skill_magnet;

  /// No description provided for @skill_magnet_desc.
  ///
  /// In en, this message translates to:
  /// **'A wider PERFECT window. The digits stick to 10.00.'**
  String get skill_magnet_desc;

  /// No description provided for @skill_magnet_label.
  ///
  /// In en, this message translates to:
  /// **'PERFECT window'**
  String get skill_magnet_label;

  /// No description provided for @skill_echo.
  ///
  /// In en, this message translates to:
  /// **'Echo'**
  String get skill_echo;

  /// No description provided for @skill_echo_desc.
  ///
  /// In en, this message translates to:
  /// **'Hits also pay seconds of your clocks\' income.'**
  String get skill_echo_desc;

  /// No description provided for @skill_echo_label.
  ///
  /// In en, this message translates to:
  /// **'Echo'**
  String get skill_echo_label;

  /// No description provided for @skill_bulletTime.
  ///
  /// In en, this message translates to:
  /// **'Bullet Time'**
  String get skill_bulletTime;

  /// No description provided for @skill_bulletTime_desc.
  ///
  /// In en, this message translates to:
  /// **'Time slows down around 10.00. Easier to hit.'**
  String get skill_bulletTime_desc;

  /// No description provided for @skill_bulletTime_label.
  ///
  /// In en, this message translates to:
  /// **'Speed near 10.00'**
  String get skill_bulletTime_label;

  /// No description provided for @skill_luck.
  ///
  /// In en, this message translates to:
  /// **'Luck'**
  String get skill_luck;

  /// No description provided for @skill_luck_desc.
  ///
  /// In en, this message translates to:
  /// **'A chance that a hit jumps one tier up.'**
  String get skill_luck_desc;

  /// No description provided for @skill_luck_label.
  ///
  /// In en, this message translates to:
  /// **'Chance'**
  String get skill_luck_label;

  /// No description provided for @skill_shield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get skill_shield;

  /// No description provided for @skill_shield_desc.
  ///
  /// In en, this message translates to:
  /// **'A miss uses a charge instead of breaking the streak.'**
  String get skill_shield_desc;

  /// No description provided for @skill_shield_label.
  ///
  /// In en, this message translates to:
  /// **'Charges'**
  String get skill_shield_label;

  /// No description provided for @skill_goldenTouch.
  ///
  /// In en, this message translates to:
  /// **'Golden Touch'**
  String get skill_goldenTouch;

  /// No description provided for @skill_goldenTouch_desc.
  ///
  /// In en, this message translates to:
  /// **'Golden seconds come more often and hit harder.'**
  String get skill_goldenTouch_desc;

  /// No description provided for @skill_goldenTouch_label.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get skill_goldenTouch_label;

  /// No description provided for @skillLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}/{max}'**
  String skillLevel(int level, int max);

  /// No description provided for @skillEffect.
  ///
  /// In en, this message translates to:
  /// **'{label}: {now} → {next}'**
  String skillEffect(String label, String now, String next);

  /// No description provided for @skillEffectMax.
  ///
  /// In en, this message translates to:
  /// **'{label}: {now}'**
  String skillEffectMax(String label, String now);

  /// No description provided for @skillMaxed.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get skillMaxed;

  /// No description provided for @skillLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Revealed at {price} Ticks'**
  String skillLockedHint(String price);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @goldenRound.
  ///
  /// In en, this message translates to:
  /// **'GOLDEN ROUND!'**
  String get goldenRound;

  /// No description provided for @goldenEscaped.
  ///
  /// In en, this message translates to:
  /// **'It escaped!'**
  String get goldenEscaped;

  /// No description provided for @goldenFrenzy.
  ///
  /// In en, this message translates to:
  /// **'FRENZY ×{mult}!'**
  String goldenFrenzy(String mult);

  /// No description provided for @goldenLucky.
  ///
  /// In en, this message translates to:
  /// **'LUCKY! +{amount}'**
  String goldenLucky(String amount);

  /// No description provided for @goldenHotHand.
  ///
  /// In en, this message translates to:
  /// **'HOT HAND!'**
  String get goldenHotHand;

  /// No description provided for @chipFrenzy.
  ///
  /// In en, this message translates to:
  /// **'Frenzy ×{mult}'**
  String chipFrenzy(String mult);

  /// No description provided for @chipHotHand.
  ///
  /// In en, this message translates to:
  /// **'Hot hand'**
  String get chipHotHand;

  /// No description provided for @comboLabel.
  ///
  /// In en, this message translates to:
  /// **'COMBO'**
  String get comboLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'streak {count}'**
  String streakLabel(int count);

  /// No description provided for @luckyBump.
  ///
  /// In en, this message translates to:
  /// **'LUCKY!'**
  String get luckyBump;

  /// No description provided for @shieldSaved.
  ///
  /// In en, this message translates to:
  /// **'SHIELD!'**
  String get shieldSaved;

  /// No description provided for @ach_earned.
  ///
  /// In en, this message translates to:
  /// **'Earned {amount}'**
  String ach_earned(String amount);

  /// No description provided for @ach_earned_desc.
  ///
  /// In en, this message translates to:
  /// **'Earn {amount} Ticks in total'**
  String ach_earned_desc(String amount);

  /// No description provided for @ach_owned.
  ///
  /// In en, this message translates to:
  /// **'{generator} ×{count}'**
  String ach_owned(String generator, String count);

  /// No description provided for @ach_owned_desc.
  ///
  /// In en, this message translates to:
  /// **'Own {count} × {generator}'**
  String ach_owned_desc(String generator, String count);

  /// No description provided for @ach_perfects.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist {count}'**
  String ach_perfects(String count);

  /// No description provided for @ach_perfects_desc.
  ///
  /// In en, this message translates to:
  /// **'Hit PERFECT {count} times'**
  String ach_perfects_desc(String count);

  /// No description provided for @ach_perfectStreak.
  ///
  /// In en, this message translates to:
  /// **'Flawless {count}'**
  String ach_perfectStreak(String count);

  /// No description provided for @ach_perfectStreak_desc.
  ///
  /// In en, this message translates to:
  /// **'{count} PERFECTs in a row'**
  String ach_perfectStreak_desc(String count);

  /// No description provided for @ach_combo.
  ///
  /// In en, this message translates to:
  /// **'Combo {count}'**
  String ach_combo(String count);

  /// No description provided for @ach_combo_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a streak of {count}'**
  String ach_combo_desc(String count);

  /// No description provided for @ach_golden.
  ///
  /// In en, this message translates to:
  /// **'Gold digger {count}'**
  String ach_golden(String count);

  /// No description provided for @ach_golden_desc.
  ///
  /// In en, this message translates to:
  /// **'Catch {count} golden seconds'**
  String ach_golden_desc(String count);

  /// No description provided for @ach_prestige.
  ///
  /// In en, this message translates to:
  /// **'Time traveller {count}'**
  String ach_prestige(String count);

  /// No description provided for @ach_prestige_desc.
  ///
  /// In en, this message translates to:
  /// **'Prestige {count} times'**
  String ach_prestige_desc(String count);

  /// No description provided for @ach_mode_blind.
  ///
  /// In en, this message translates to:
  /// **'Blindfolded'**
  String get ach_mode_blind;

  /// No description provided for @ach_mode_blind_desc.
  ///
  /// In en, this message translates to:
  /// **'PERFECT in blind mode'**
  String get ach_mode_blind_desc;

  /// No description provided for @ach_mode_fast.
  ///
  /// In en, this message translates to:
  /// **'Quick hands'**
  String get ach_mode_fast;

  /// No description provided for @ach_mode_fast_desc.
  ///
  /// In en, this message translates to:
  /// **'PERFECT on the fast clock'**
  String get ach_mode_fast_desc;

  /// No description provided for @ach_mode_both.
  ///
  /// In en, this message translates to:
  /// **'Madman'**
  String get ach_mode_both;

  /// No description provided for @ach_mode_both_desc.
  ///
  /// In en, this message translates to:
  /// **'PERFECT with both modes on'**
  String get ach_mode_both_desc;

  /// No description provided for @ach_hidden_impatient.
  ///
  /// In en, this message translates to:
  /// **'Impatient'**
  String get ach_hidden_impatient;

  /// No description provided for @ach_hidden_impatient_desc.
  ///
  /// In en, this message translates to:
  /// **'TOO EARLY 100 times'**
  String get ach_hidden_impatient_desc;

  /// No description provided for @ach_hidden_nap.
  ///
  /// In en, this message translates to:
  /// **'Nap time'**
  String get ach_hidden_nap;

  /// No description provided for @ach_hidden_nap_desc.
  ///
  /// In en, this message translates to:
  /// **'10 rounds in a row without a tap'**
  String get ach_hidden_nap_desc;

  /// No description provided for @ach_hidden_almost.
  ///
  /// In en, this message translates to:
  /// **'So close'**
  String get ach_hidden_almost;

  /// No description provided for @ach_hidden_almost_desc.
  ///
  /// In en, this message translates to:
  /// **'9.99, then 10.01'**
  String get ach_hidden_almost_desc;

  /// No description provided for @ach_hidden_punctual.
  ///
  /// In en, this message translates to:
  /// **'Punctual'**
  String get ach_hidden_punctual;

  /// No description provided for @ach_hidden_punctual_desc.
  ///
  /// In en, this message translates to:
  /// **'PERFECT at 10:00 in the morning'**
  String get ach_hidden_punctual_desc;

  /// No description provided for @ach_hidden_tenth.
  ///
  /// In en, this message translates to:
  /// **'Ten out of ten'**
  String get ach_hidden_tenth;

  /// No description provided for @ach_hidden_tenth_desc.
  ///
  /// In en, this message translates to:
  /// **'10 PERFECTs on the 10th of a month'**
  String get ach_hidden_tenth_desc;

  /// No description provided for @ach_hidden_fullCollection.
  ///
  /// In en, this message translates to:
  /// **'Full collection'**
  String get ach_hidden_fullCollection;

  /// No description provided for @ach_hidden_fullCollection_desc.
  ///
  /// In en, this message translates to:
  /// **'Every skill maxed out'**
  String get ach_hidden_fullCollection_desc;

  /// No description provided for @ach_hidden_museum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get ach_hidden_museum;

  /// No description provided for @ach_hidden_museum_desc.
  ///
  /// In en, this message translates to:
  /// **'One of every clock'**
  String get ach_hidden_museum_desc;

  /// No description provided for @ach_hidden_boiledEgg.
  ///
  /// In en, this message translates to:
  /// **'Soft-boiled'**
  String get ach_hidden_boiledEgg;

  /// No description provided for @ach_hidden_boiledEgg_desc.
  ///
  /// In en, this message translates to:
  /// **'100 grandmas'**
  String get ach_hidden_boiledEgg_desc;

  /// No description provided for @perk_headStart.
  ///
  /// In en, this message translates to:
  /// **'Head start'**
  String get perk_headStart;

  /// No description provided for @perk_headStart_desc.
  ///
  /// In en, this message translates to:
  /// **'Start each run with 10 grandpas and 1K Ticks'**
  String get perk_headStart_desc;

  /// No description provided for @perk_muscleMemory1.
  ///
  /// In en, this message translates to:
  /// **'Muscle memory I'**
  String get perk_muscleMemory1;

  /// No description provided for @perk_muscleMemory1_desc.
  ///
  /// In en, this message translates to:
  /// **'Fast Forward survives the paradox'**
  String get perk_muscleMemory1_desc;

  /// No description provided for @perk_muscleMemory2.
  ///
  /// In en, this message translates to:
  /// **'Muscle memory II'**
  String get perk_muscleMemory2;

  /// No description provided for @perk_muscleMemory2_desc.
  ///
  /// In en, this message translates to:
  /// **'Hawk Eye and Magnet survive too'**
  String get perk_muscleMemory2_desc;

  /// No description provided for @perk_muscleMemory3.
  ///
  /// In en, this message translates to:
  /// **'Muscle memory III'**
  String get perk_muscleMemory3;

  /// No description provided for @perk_muscleMemory3_desc.
  ///
  /// In en, this message translates to:
  /// **'Other skills keep half their level'**
  String get perk_muscleMemory3_desc;

  /// No description provided for @perk_longNap1.
  ///
  /// In en, this message translates to:
  /// **'Long nap I'**
  String get perk_longNap1;

  /// No description provided for @perk_longNap1_desc.
  ///
  /// In en, this message translates to:
  /// **'Offline limit 12 h'**
  String get perk_longNap1_desc;

  /// No description provided for @perk_longNap2.
  ///
  /// In en, this message translates to:
  /// **'Long nap II'**
  String get perk_longNap2;

  /// No description provided for @perk_longNap2_desc.
  ///
  /// In en, this message translates to:
  /// **'Offline limit 24 h'**
  String get perk_longNap2_desc;

  /// No description provided for @perk_deepSleep1.
  ///
  /// In en, this message translates to:
  /// **'Deep sleep I'**
  String get perk_deepSleep1;

  /// No description provided for @perk_deepSleep1_desc.
  ///
  /// In en, this message translates to:
  /// **'Offline at 75 %'**
  String get perk_deepSleep1_desc;

  /// No description provided for @perk_deepSleep2.
  ///
  /// In en, this message translates to:
  /// **'Deep sleep II'**
  String get perk_deepSleep2;

  /// No description provided for @perk_deepSleep2_desc.
  ///
  /// In en, this message translates to:
  /// **'Offline at 100 %'**
  String get perk_deepSleep2_desc;

  /// No description provided for @perk_goldRush.
  ///
  /// In en, this message translates to:
  /// **'Gold rush'**
  String get perk_goldRush;

  /// No description provided for @perk_goldRush_desc.
  ///
  /// In en, this message translates to:
  /// **'Golden seconds 15 % more often'**
  String get perk_goldRush_desc;

  /// No description provided for @perk_startShield.
  ///
  /// In en, this message translates to:
  /// **'Shield at start'**
  String get perk_startShield;

  /// No description provided for @perk_startShield_desc.
  ///
  /// In en, this message translates to:
  /// **'One shield charge, even without the skill'**
  String get perk_startShield_desc;

  /// No description provided for @perk_comboFloor.
  ///
  /// In en, this message translates to:
  /// **'Soft landing'**
  String get perk_comboFloor;

  /// No description provided for @perk_comboFloor_desc.
  ///
  /// In en, this message translates to:
  /// **'A miss drops the streak to 5, not 0'**
  String get perk_comboFloor_desc;

  /// No description provided for @perk_autoBuyer.
  ///
  /// In en, this message translates to:
  /// **'Auto buyer'**
  String get perk_autoBuyer;

  /// No description provided for @perk_autoBuyer_desc.
  ///
  /// In en, this message translates to:
  /// **'A switch that buys the cheapest clock every 5 s'**
  String get perk_autoBuyer_desc;

  /// No description provided for @perk_earlyModes.
  ///
  /// In en, this message translates to:
  /// **'Daredevil'**
  String get perk_earlyModes;

  /// No description provided for @perk_earlyModes_desc.
  ///
  /// In en, this message translates to:
  /// **'Risk modes unlocked from the start'**
  String get perk_earlyModes_desc;

  /// No description provided for @perk_unlockSchrodinger.
  ///
  /// In en, this message translates to:
  /// **'The box'**
  String get perk_unlockSchrodinger;

  /// No description provided for @perk_unlockSchrodinger_desc.
  ///
  /// In en, this message translates to:
  /// **'Unlocks Schrödinger\'s Cat'**
  String get perk_unlockSchrodinger_desc;

  /// No description provided for @perk_secondClock.
  ///
  /// In en, this message translates to:
  /// **'Second clock'**
  String get perk_secondClock;

  /// No description provided for @perk_secondClock_desc.
  ///
  /// In en, this message translates to:
  /// **'Play two stopwatches at once'**
  String get perk_secondClock_desc;

  /// No description provided for @perk_unlockChronos.
  ///
  /// In en, this message translates to:
  /// **'Altar of Chronos'**
  String get perk_unlockChronos;

  /// No description provided for @perk_unlockChronos_desc.
  ///
  /// In en, this message translates to:
  /// **'Unlocks Chronos'**
  String get perk_unlockChronos_desc;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} · +{percent}% income'**
  String achievementsSummary(int count, int total, String percent);

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} achievements unlocked!'**
  String achievementsUnlocked(int count);

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @hiddenAchievement.
  ///
  /// In en, this message translates to:
  /// **'Hidden achievement'**
  String get hiddenAchievement;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statEarnedRun.
  ///
  /// In en, this message translates to:
  /// **'Earned this run'**
  String get statEarnedRun;

  /// No description provided for @statEarnedTotal.
  ///
  /// In en, this message translates to:
  /// **'Earned in total'**
  String get statEarnedTotal;

  /// No description provided for @statRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get statRounds;

  /// No description provided for @statTiers.
  ///
  /// In en, this message translates to:
  /// **'Hits'**
  String get statTiers;

  /// No description provided for @statMeanError.
  ///
  /// In en, this message translates to:
  /// **'Average error'**
  String get statMeanError;

  /// No description provided for @statSpread.
  ///
  /// In en, this message translates to:
  /// **'Spread'**
  String get statSpread;

  /// No description provided for @statMeanHint.
  ///
  /// In en, this message translates to:
  /// **'negative = you tap early'**
  String get statMeanHint;

  /// No description provided for @statBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best PERFECT streak'**
  String get statBestStreak;

  /// No description provided for @statBestCombo.
  ///
  /// In en, this message translates to:
  /// **'Highest combo'**
  String get statBestCombo;

  /// No description provided for @statGolden.
  ///
  /// In en, this message translates to:
  /// **'Golden seconds caught'**
  String get statGolden;

  /// No description provided for @statPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get statPlayTime;

  /// No description provided for @statPrestiges.
  ///
  /// In en, this message translates to:
  /// **'Prestiges'**
  String get statPrestiges;

  /// No description provided for @statChronons.
  ///
  /// In en, this message translates to:
  /// **'Chronons'**
  String get statChronons;

  /// No description provided for @ms.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String ms(String value);

  /// No description provided for @prestigeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time paradox'**
  String get prestigeTitle;

  /// No description provided for @prestigeChronons.
  ///
  /// In en, this message translates to:
  /// **'Chronons: {count} (+{percent}% forever)'**
  String prestigeChronons(int count, String percent);

  /// No description provided for @prestigeShards.
  ///
  /// In en, this message translates to:
  /// **'Time shards: {count}'**
  String prestigeShards(int count);

  /// No description provided for @prestigeGain.
  ///
  /// In en, this message translates to:
  /// **'Rewind now for +{count} Chronons'**
  String prestigeGain(int count);

  /// No description provided for @prestigeNext.
  ///
  /// In en, this message translates to:
  /// **'{amount} more Ticks for the next Chronon'**
  String prestigeNext(String amount);

  /// No description provided for @prestigeButton.
  ///
  /// In en, this message translates to:
  /// **'Rewind time'**
  String get prestigeButton;

  /// No description provided for @prestigeConfirm1.
  ///
  /// In en, this message translates to:
  /// **'You lose your clocks, skills and Ticks. Chronons, perks and achievements stay. Continue?'**
  String get prestigeConfirm1;

  /// No description provided for @prestigeConfirm2.
  ///
  /// In en, this message translates to:
  /// **'Really? Time will rewind.'**
  String get prestigeConfirm2;

  /// No description provided for @perksTitle.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get perksTitle;

  /// No description provided for @perkRequires.
  ///
  /// In en, this message translates to:
  /// **'Needs: {name}'**
  String perkRequires(String name);

  /// No description provided for @perkOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get perkOwned;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @modeBlind.
  ///
  /// In en, this message translates to:
  /// **'Blind ×3'**
  String get modeBlind;

  /// No description provided for @modeFast.
  ///
  /// In en, this message translates to:
  /// **'Fast clock ×2'**
  String get modeFast;

  /// No description provided for @modeSecond.
  ///
  /// In en, this message translates to:
  /// **'Second clock'**
  String get modeSecond;

  /// No description provided for @modeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto buyer'**
  String get modeAuto;

  /// No description provided for @adTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo ×2'**
  String get adTurbo;

  /// No description provided for @adTurboLeft.
  ///
  /// In en, this message translates to:
  /// **'×2 · {time}'**
  String adTurboLeft(String time);

  /// No description provided for @adGolden.
  ///
  /// In en, this message translates to:
  /// **'Golden second'**
  String get adGolden;

  /// No description provided for @adBag.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} min'**
  String adBag(int minutes);

  /// No description provided for @adRescue.
  ///
  /// In en, this message translates to:
  /// **'Streak {count} lost! Restore'**
  String adRescue(int count);

  /// No description provided for @adDouble.
  ///
  /// In en, this message translates to:
  /// **'Double it'**
  String get adDouble;

  /// No description provided for @adUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No ad right now'**
  String get adUnavailable;

  /// No description provided for @adCooldown.
  ///
  /// In en, this message translates to:
  /// **'in {time}'**
  String adCooldown(String time);

  /// No description provided for @adFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get adFull;

  /// No description provided for @tutorialAim.
  ///
  /// In en, this message translates to:
  /// **'Tap when the clock shows exactly 10.00'**
  String get tutorialAim;

  /// No description provided for @tutorialBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy a grandpa: he will try for you!'**
  String get tutorialBuy;

  /// No description provided for @tutorialInfo.
  ///
  /// In en, this message translates to:
  /// **'Grandpa tries every 10 seconds. More clocks, more Ticks!'**
  String get tutorialInfo;

  /// No description provided for @tutorialGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get tutorialGotIt;

  /// No description provided for @tip_skills.
  ///
  /// In en, this message translates to:
  /// **'New skill! Check the Skills tab.'**
  String get tip_skills;

  /// No description provided for @tip_golden.
  ///
  /// In en, this message translates to:
  /// **'A golden second! Catch the flying clock: the next round turns golden.'**
  String get tip_golden;

  /// No description provided for @tip_combo.
  ///
  /// In en, this message translates to:
  /// **'A streak! GREAT and PERFECT hits keep raising the multiplier.'**
  String get tip_combo;

  /// No description provided for @tip_prestige.
  ///
  /// In en, this message translates to:
  /// **'You can rewind time: a prestige gives Chronons, a permanent bonus.'**
  String get tip_prestige;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your clocks collected {amount} Ticks! Come back for more.'**
  String notificationTitle(String amount);

  /// No description provided for @notificationAsk.
  ///
  /// In en, this message translates to:
  /// **'Shall we tell you when your clocks are full?'**
  String get notificationAsk;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
