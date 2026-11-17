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
  /// **'Hit5'**
  String get appTitle;

  /// One-line pitch on the start screen
  ///
  /// In en, this message translates to:
  /// **'Tap at exactly 5.00'**
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

  /// No description provided for @missClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE!'**
  String get missClose;

  /// No description provided for @arenaLabel.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch. Stop it at exactly 5.00.'**
  String get arenaLabel;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// No description provided for @pausedTapToPlay.
  ///
  /// In en, this message translates to:
  /// **'Paused · tap to play'**
  String get pausedTapToPlay;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get resume;

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
  /// **'Soft-boiled eggs since 1974. Five seconds? Child\'s play.'**
  String get gen_grandma_desc;

  /// No description provided for @gen_cuckoo.
  ///
  /// In en, this message translates to:
  /// **'Cuckoo'**
  String get gen_cuckoo;

  /// No description provided for @gen_cuckoo_desc.
  ///
  /// In en, this message translates to:
  /// **'Cuckoos every five seconds. Usually.'**
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
  /// **'False start! Then a perfect 5.00.'**
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

  /// No description provided for @upgradeRequires.
  ///
  /// In en, this message translates to:
  /// **'Needs {count} owned'**
  String upgradeRequires(int count);

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

  /// No description provided for @durationH.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationH(int hours);

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
  /// **'More Ticks for every hit.'**
  String get skill_power_desc;

  /// No description provided for @skill_power_label.
  ///
  /// In en, this message translates to:
  /// **'Ticks per PERFECT'**
  String get skill_power_label;

  /// No description provided for @skill_fastForward.
  ///
  /// In en, this message translates to:
  /// **'Late Start'**
  String get skill_fastForward;

  /// No description provided for @skill_fastForward_desc.
  ///
  /// In en, this message translates to:
  /// **'The stopwatch starts from a higher value, so a round is shorter.'**
  String get skill_fastForward_desc;

  /// No description provided for @skill_fastForward_label.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch starts at'**
  String get skill_fastForward_label;

  /// No description provided for @skill_ticking.
  ///
  /// In en, this message translates to:
  /// **'Ticking'**
  String get skill_ticking;

  /// No description provided for @skill_ticking_desc.
  ///
  /// In en, this message translates to:
  /// **'Ticking in the last second before the target.'**
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
  /// **'Wider GREAT and GOOD windows. Yours and your clocks\'.'**
  String get skill_wideEye_desc;

  /// No description provided for @skill_wideEye_label.
  ///
  /// In en, this message translates to:
  /// **'GREAT / GOOD'**
  String get skill_wideEye_label;

  /// No description provided for @skill_combo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get skill_combo;

  /// No description provided for @skill_combo_desc.
  ///
  /// In en, this message translates to:
  /// **'A higher cap on the streak multiplier.'**
  String get skill_combo_desc;

  /// No description provided for @skill_combo_label.
  ///
  /// In en, this message translates to:
  /// **'Streak multiplies up to'**
  String get skill_combo_label;

  /// No description provided for @skill_magnet.
  ///
  /// In en, this message translates to:
  /// **'Magnet'**
  String get skill_magnet;

  /// No description provided for @skill_magnet_desc.
  ///
  /// In en, this message translates to:
  /// **'A wider PERFECT window. Yours and your clocks\'.'**
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
  /// **'A hit adds the Ticks your clocks make in a fraction of a second.'**
  String get skill_echo_desc;

  /// No description provided for @skill_echo_label.
  ///
  /// In en, this message translates to:
  /// **'PERFECT adds clock time'**
  String get skill_echo_label;

  /// No description provided for @skill_bulletTime.
  ///
  /// In en, this message translates to:
  /// **'Cold Blood'**
  String get skill_bulletTime;

  /// No description provided for @skill_bulletTime_desc.
  ///
  /// In en, this message translates to:
  /// **'All your windows wider. Doesn\'t work on clocks.'**
  String get skill_bulletTime_desc;

  /// No description provided for @skill_bulletTime_label.
  ///
  /// In en, this message translates to:
  /// **'Your GOOD window'**
  String get skill_bulletTime_label;

  /// No description provided for @skill_luck.
  ///
  /// In en, this message translates to:
  /// **'Luck'**
  String get skill_luck;

  /// No description provided for @skill_luck_desc.
  ///
  /// In en, this message translates to:
  /// **'Some hits land a tier higher.'**
  String get skill_luck_desc;

  /// No description provided for @skill_luck_label.
  ///
  /// In en, this message translates to:
  /// **'Hits bumped a tier up'**
  String get skill_luck_label;

  /// No description provided for @skill_shield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get skill_shield;

  /// No description provided for @skill_shield_desc.
  ///
  /// In en, this message translates to:
  /// **'A miss uses a charge instead of resetting the streak.'**
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
  /// **'Golden Second more often, with a stronger effect.'**
  String get skill_goldenTouch_desc;

  /// No description provided for @skill_goldenTouch_label.
  ///
  /// In en, this message translates to:
  /// **'Golden Second every'**
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

  /// No description provided for @skillKeptInfo.
  ///
  /// In en, this message translates to:
  /// **'After a paradox {kept} levels stay (Muscle memory: {share}% of levels, rounded).'**
  String skillKeptInfo(String kept, String share);

  /// No description provided for @skillKeptNone.
  ///
  /// In en, this message translates to:
  /// **'After a paradox skills go back to zero. The Muscle memory perk keeps part of the levels, and a Habit keeps a chosen skill whole — what you buy now gives the next run a better start.'**
  String get skillKeptNone;

  /// No description provided for @prestigeHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit {used}/{slots}: which skills keep every level?'**
  String prestigeHabitTitle(String used, String slots);

  /// No description provided for @skillKeptHabit.
  ///
  /// In en, this message translates to:
  /// **'In a Habit slot: after a paradox every level stays.'**
  String get skillKeptHabit;

  /// No description provided for @skillHabitRemove.
  ///
  /// In en, this message translates to:
  /// **'Take out of the Habit'**
  String get skillHabitRemove;

  /// No description provided for @skillHabitAdd.
  ///
  /// In en, this message translates to:
  /// **'Keep it whole (Habit {used}/{slots})'**
  String skillHabitAdd(String used, String slots);

  /// No description provided for @skillHabitMove.
  ///
  /// In en, this message translates to:
  /// **'Keep it whole instead of {skill}'**
  String skillHabitMove(String skill);

  /// No description provided for @inHundred.
  ///
  /// In en, this message translates to:
  /// **'{n}%'**
  String inHundred(String n);

  /// No description provided for @oddsPerfect.
  ///
  /// In en, this message translates to:
  /// **'PERFECTs'**
  String get oddsPerfect;

  /// No description provided for @oddsGreatOrBetter.
  ///
  /// In en, this message translates to:
  /// **'GREAT or better'**
  String get oddsGreatOrBetter;

  /// No description provided for @oddsHits.
  ///
  /// In en, this message translates to:
  /// **'hits'**
  String get oddsHits;

  /// No description provided for @skillOdds.
  ///
  /// In en, this message translates to:
  /// **'Your {tier}: about {now}% → {next}% of rounds'**
  String skillOdds(String tier, String now, String next);

  /// No description provided for @skillOddsMax.
  ///
  /// In en, this message translates to:
  /// **'Your {tier}: about {now}% of rounds'**
  String skillOddsMax(String tier, String now);

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
  /// **'Rewind time {count} times'**
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
  /// **'Feel the beat'**
  String get ach_mode_fast;

  /// No description provided for @ach_mode_fast_desc.
  ///
  /// In en, this message translates to:
  /// **'PERFECT in Blind mode on a 10+ streak'**
  String get ach_mode_fast_desc;

  /// No description provided for @ach_mode_both.
  ///
  /// In en, this message translates to:
  /// **'Metronome inside'**
  String get ach_mode_both;

  /// No description provided for @ach_mode_both_desc.
  ///
  /// In en, this message translates to:
  /// **'PERFECT in Blind mode on a 25+ streak'**
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
  /// **'Put the phone down until the stopwatch stops by itself'**
  String get ach_hidden_nap_desc;

  /// No description provided for @ach_hidden_almost.
  ///
  /// In en, this message translates to:
  /// **'So close'**
  String get ach_hidden_almost;

  /// No description provided for @ach_hidden_almost_desc.
  ///
  /// In en, this message translates to:
  /// **'4.99, then 5.01'**
  String get ach_hidden_almost_desc;

  /// No description provided for @ach_hidden_punctual.
  ///
  /// In en, this message translates to:
  /// **'Punctual'**
  String get ach_hidden_punctual;

  /// No description provided for @ach_hidden_punctual_desc.
  ///
  /// In en, this message translates to:
  /// **'A PERFECT at 5:00 or 17:00'**
  String get ach_hidden_punctual_desc;

  /// No description provided for @ach_hidden_tenth.
  ///
  /// In en, this message translates to:
  /// **'High five'**
  String get ach_hidden_tenth;

  /// No description provided for @ach_hidden_tenth_desc.
  ///
  /// In en, this message translates to:
  /// **'10 PERFECTs on the 5th of a month'**
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

  /// No description provided for @ach_exact.
  ///
  /// In en, this message translates to:
  /// **'Spot on {count}'**
  String ach_exact(String count);

  /// No description provided for @ach_exact_desc.
  ///
  /// In en, this message translates to:
  /// **'Stop the dial at exactly 5.00 {count} times'**
  String ach_exact_desc(String count);

  /// No description provided for @ach_rounds.
  ///
  /// In en, this message translates to:
  /// **'Persistent {count}'**
  String ach_rounds(String count);

  /// No description provided for @ach_rounds_desc.
  ///
  /// In en, this message translates to:
  /// **'Play {count} rounds'**
  String ach_rounds_desc(String count);

  /// No description provided for @ach_income.
  ///
  /// In en, this message translates to:
  /// **'Time factory {count}/s'**
  String ach_income(String count);

  /// No description provided for @ach_income_desc.
  ///
  /// In en, this message translates to:
  /// **'Your clocks earn {count} Ticks a second (without Frenzy and Turbo)'**
  String ach_income_desc(String count);

  /// No description provided for @ach_clocks.
  ///
  /// In en, this message translates to:
  /// **'Clockmaker {count}'**
  String ach_clocks(String count);

  /// No description provided for @ach_clocks_desc.
  ///
  /// In en, this message translates to:
  /// **'Own {count} clocks in total'**
  String ach_clocks_desc(String count);

  /// No description provided for @ach_skillLevels.
  ///
  /// In en, this message translates to:
  /// **'Practice {count}'**
  String ach_skillLevels(String count);

  /// No description provided for @ach_skillLevels_desc.
  ///
  /// In en, this message translates to:
  /// **'Have {count} skill levels in total'**
  String ach_skillLevels_desc(String count);

  /// No description provided for @ach_blindPerfects.
  ///
  /// In en, this message translates to:
  /// **'Bat {count}'**
  String ach_blindPerfects(String count);

  /// No description provided for @ach_blindPerfects_desc.
  ///
  /// In en, this message translates to:
  /// **'{count} blind PERFECTs'**
  String ach_blindPerfects_desc(String count);

  /// No description provided for @ach_playHours.
  ///
  /// In en, this message translates to:
  /// **'Regular {count} h'**
  String ach_playHours(String count);

  /// No description provided for @ach_playHours_desc.
  ///
  /// In en, this message translates to:
  /// **'Play {count} h in total'**
  String ach_playHours_desc(String count);

  /// No description provided for @ach_achievements.
  ///
  /// In en, this message translates to:
  /// **'Collector {count}'**
  String ach_achievements(String count);

  /// No description provided for @ach_achievements_desc.
  ///
  /// In en, this message translates to:
  /// **'Earn {count} achievements'**
  String ach_achievements_desc(String count);

  /// No description provided for @ach_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily ritual {count}'**
  String ach_daily(String count);

  /// No description provided for @ach_daily_desc.
  ///
  /// In en, this message translates to:
  /// **'Collect the daily bonus {count} times'**
  String ach_daily_desc(String count);

  /// No description provided for @ach_shield.
  ///
  /// In en, this message translates to:
  /// **'Armored {count}'**
  String ach_shield(String count);

  /// No description provided for @ach_shield_desc.
  ///
  /// In en, this message translates to:
  /// **'Your Shield saved the combo {count} times'**
  String ach_shield_desc(String count);

  /// No description provided for @ach_feat_goldenFast.
  ///
  /// In en, this message translates to:
  /// **'Reflexes'**
  String get ach_feat_goldenFast;

  /// No description provided for @ach_feat_goldenFast_desc.
  ///
  /// In en, this message translates to:
  /// **'Catch a Golden Second within a second of it appearing'**
  String get ach_feat_goldenFast_desc;

  /// No description provided for @ach_feat_goldenFrenzy.
  ///
  /// In en, this message translates to:
  /// **'Gold on gold'**
  String get ach_feat_goldenFrenzy;

  /// No description provided for @ach_feat_goldenFrenzy_desc.
  ///
  /// In en, this message translates to:
  /// **'Catch a Golden Second during a Frenzy'**
  String get ach_feat_goldenFrenzy_desc;

  /// No description provided for @ach_feat_dailyWeek.
  ///
  /// In en, this message translates to:
  /// **'Full week'**
  String get ach_feat_dailyWeek;

  /// No description provided for @ach_feat_dailyWeek_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach day 7 of the daily bonus'**
  String get ach_feat_dailyWeek_desc;

  /// No description provided for @ach_feat_offlineFull.
  ///
  /// In en, this message translates to:
  /// **'Hibernation'**
  String get ach_feat_offlineFull;

  /// No description provided for @ach_feat_offlineFull_desc.
  ///
  /// In en, this message translates to:
  /// **'Come back after a break longer than the offline limit'**
  String get ach_feat_offlineFull_desc;

  /// No description provided for @ach_feat_bothClocks.
  ///
  /// In en, this message translates to:
  /// **'Both hands'**
  String get ach_feat_bothClocks;

  /// No description provided for @ach_feat_bothClocks_desc.
  ///
  /// In en, this message translates to:
  /// **'A PERFECT on one clock right after a PERFECT on the other'**
  String get ach_feat_bothClocks_desc;

  /// No description provided for @ach_feat_allPerks.
  ///
  /// In en, this message translates to:
  /// **'Master of time'**
  String get ach_feat_allPerks;

  /// No description provided for @ach_feat_allPerks_desc.
  ///
  /// In en, this message translates to:
  /// **'Buy every perk'**
  String get ach_feat_allPerks_desc;

  /// No description provided for @ach_feat_noHands.
  ///
  /// In en, this message translates to:
  /// **'No hands'**
  String get ach_feat_noHands;

  /// No description provided for @ach_feat_noHands_desc.
  ///
  /// In en, this message translates to:
  /// **'Earn 1M Ticks in one run with at most 15 taps'**
  String get ach_feat_noHands_desc;

  /// No description provided for @ach_hidden_midnight.
  ///
  /// In en, this message translates to:
  /// **'Cinderella'**
  String get ach_hidden_midnight;

  /// No description provided for @ach_hidden_midnight_desc.
  ///
  /// In en, this message translates to:
  /// **'A PERFECT at midnight'**
  String get ach_hidden_midnight_desc;

  /// No description provided for @ach_hidden_stubborn.
  ///
  /// In en, this message translates to:
  /// **'Stubborn'**
  String get ach_hidden_stubborn;

  /// No description provided for @ach_hidden_stubborn_desc.
  ///
  /// In en, this message translates to:
  /// **'1000 misses'**
  String get ach_hidden_stubborn_desc;

  /// No description provided for @ach_hidden_atomic.
  ///
  /// In en, this message translates to:
  /// **'Atomic clock'**
  String get ach_hidden_atomic;

  /// No description provided for @ach_hidden_atomic_desc.
  ///
  /// In en, this message translates to:
  /// **'Half of your last 100 taps within 15 ms'**
  String get ach_hidden_atomic_desc;

  /// No description provided for @perk_headStart.
  ///
  /// In en, this message translates to:
  /// **'Head start'**
  String get perk_headStart;

  /// No description provided for @perk_headStart_desc.
  ///
  /// In en, this message translates to:
  /// **'After each paradox start with 10 Grandpas and 1K Ticks'**
  String get perk_headStart_desc;

  /// No description provided for @perk_muscleMemory1.
  ///
  /// In en, this message translates to:
  /// **'Muscle memory I'**
  String get perk_muscleMemory1;

  /// No description provided for @perk_muscleMemory1_desc.
  ///
  /// In en, this message translates to:
  /// **'After a paradox every skill keeps 50% of its levels'**
  String get perk_muscleMemory1_desc;

  /// No description provided for @perk_muscleMemory2.
  ///
  /// In en, this message translates to:
  /// **'Muscle memory II'**
  String get perk_muscleMemory2;

  /// No description provided for @perk_muscleMemory2_desc.
  ///
  /// In en, this message translates to:
  /// **'…65% of its levels'**
  String get perk_muscleMemory2_desc;

  /// No description provided for @perk_muscleMemory3.
  ///
  /// In en, this message translates to:
  /// **'Muscle memory III'**
  String get perk_muscleMemory3;

  /// No description provided for @perk_muscleMemory3_desc.
  ///
  /// In en, this message translates to:
  /// **'…80% of its levels'**
  String get perk_muscleMemory3_desc;

  /// No description provided for @perk_habit1.
  ///
  /// In en, this message translates to:
  /// **'Habit I'**
  String get perk_habit1;

  /// No description provided for @perk_habit1_desc.
  ///
  /// In en, this message translates to:
  /// **'One skill you choose keeps all its levels after a paradox (choose in the skill details)'**
  String get perk_habit1_desc;

  /// No description provided for @perk_habit2.
  ///
  /// In en, this message translates to:
  /// **'Habit II'**
  String get perk_habit2;

  /// No description provided for @perk_habit2_desc.
  ///
  /// In en, this message translates to:
  /// **'…and a second one'**
  String get perk_habit2_desc;

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

  /// No description provided for @perk_shieldRecharge.
  ///
  /// In en, this message translates to:
  /// **'Quick shield'**
  String get perk_shieldRecharge;

  /// No description provided for @perk_shieldRecharge_desc.
  ///
  /// In en, this message translates to:
  /// **'A Shield charge every 7 streak steps instead of 10'**
  String get perk_shieldRecharge_desc;

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

  /// No description provided for @perk_daredevil.
  ///
  /// In en, this message translates to:
  /// **'Daredevil'**
  String get perk_daredevil;

  /// No description provided for @perk_daredevil_desc.
  ///
  /// In en, this message translates to:
  /// **'Blind mode pays ×4 instead of ×3'**
  String get perk_daredevil_desc;

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

  /// No description provided for @undiscoveredAchievement.
  ///
  /// In en, this message translates to:
  /// **'Discover more clocks to see this achievement'**
  String get undiscoveredAchievement;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statEarnedRun.
  ///
  /// In en, this message translates to:
  /// **'Earned since the last paradox'**
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

  /// No description provided for @statTypical.
  ///
  /// In en, this message translates to:
  /// **'Typical error'**
  String get statTypical;

  /// No description provided for @statTypicalHint.
  ///
  /// In en, this message translates to:
  /// **'half your taps land closer'**
  String get statTypicalHint;

  /// No description provided for @statAccidental.
  ///
  /// In en, this message translates to:
  /// **'Stray taps (ignored)'**
  String get statAccidental;

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
  /// **'Paradoxes'**
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
  /// **'Chronons: {count} · income {mult}'**
  String prestigeChronons(int count, String mult);

  /// No description provided for @prestigeGainMult.
  ///
  /// In en, this message translates to:
  /// **'Income {from} → {to}'**
  String prestigeGainMult(String from, String to);

  /// No description provided for @prestigeShards.
  ///
  /// In en, this message translates to:
  /// **'Time shards: {count} ✦'**
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

  /// No description provided for @prestigePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Time rewound: +{count} ✦'**
  String prestigePendingTitle(int count);

  /// No description provided for @prestigePendingBody.
  ///
  /// In en, this message translates to:
  /// **'Spend your Shards on perks now: Muscle memory and Head start already work in the new run.'**
  String get prestigePendingBody;

  /// No description provided for @prestigeStartRun.
  ///
  /// In en, this message translates to:
  /// **'Start the new run'**
  String get prestigeStartRun;

  /// No description provided for @prestigeConfirm1.
  ///
  /// In en, this message translates to:
  /// **'You lose your clocks, skills and Ticks. Chronons, Shards ✦, perks and achievements stay. Before the new run starts you can spend Shards on perks. Continue?'**
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
  /// **'Blind ×{mult}'**
  String modeBlind(int mult);

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
  /// **'Streak {count} lost! ▶ Restore for an ad'**
  String adRescue(int count);

  /// No description provided for @adDouble.
  ///
  /// In en, this message translates to:
  /// **'▶ ×2 for an ad'**
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

  /// No description provided for @tip_golden.
  ///
  /// In en, this message translates to:
  /// **'Catch the golden clock for a golden round!'**
  String get tip_golden;

  /// No description provided for @tip_combo.
  ///
  /// In en, this message translates to:
  /// **'A streak! Keep hitting to grow the multiplier.'**
  String get tip_combo;

  /// No description provided for @tip_prestige.
  ///
  /// In en, this message translates to:
  /// **'You can turn back time! You start over, but with Chronons that permanently speed up your income. Shards ✦ buy perks that stay through every reset. The swirl up top: you choose when.'**
  String get tip_prestige;

  /// No description provided for @tip_milestone.
  ///
  /// In en, this message translates to:
  /// **'The bar under the name: at {need} owned, the clock earns ×2!'**
  String tip_milestone(String need);

  /// No description provided for @milestoneProgress.
  ///
  /// In en, this message translates to:
  /// **'{owned}/{next} → ×{mult}'**
  String milestoneProgress(String owned, String next, String mult);

  /// No description provided for @milestoneMax.
  ///
  /// In en, this message translates to:
  /// **'All bonuses reached'**
  String get milestoneMax;

  /// No description provided for @milestoneToast.
  ///
  /// In en, this message translates to:
  /// **'New bonus · {name}'**
  String milestoneToast(String name);

  /// No description provided for @milestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{generator} ×{mult}'**
  String milestoneTitle(String generator, String mult);

  /// No description provided for @synergyToast.
  ///
  /// In en, this message translates to:
  /// **'Synergy!'**
  String get synergyToast;

  /// No description provided for @tutorialAim.
  ///
  /// In en, this message translates to:
  /// **'Tap when the gold ring meets the clock — at 5.00!'**
  String get tutorialAim;

  /// No description provided for @tutorialEarned.
  ///
  /// In en, this message translates to:
  /// **'These are your Ticks. Collect {cost} for your first clock!'**
  String tutorialEarned(String cost);

  /// No description provided for @tutorialBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy Grandpa — he\'ll play for you!'**
  String get tutorialBuy;

  /// No description provided for @tutorialInfo.
  ///
  /// In en, this message translates to:
  /// **'Grandpa adds Ticks on his own: +{rate} a second, even while you\'re away.'**
  String tutorialInfo(String rate);

  /// No description provided for @tutorialEarnedReplay.
  ///
  /// In en, this message translates to:
  /// **'These are your Ticks. You spend them on clocks.'**
  String get tutorialEarnedReplay;

  /// No description provided for @goalBonus.
  ///
  /// In en, this message translates to:
  /// **'Goal: {name} {have}/{need} → ×{mult}'**
  String goalBonus(String name, String have, String need, String mult);

  /// No description provided for @goalNewClock.
  ///
  /// In en, this message translates to:
  /// **'Goal: a new clock — {name}'**
  String goalNewClock(String name);

  /// No description provided for @goalPrestigeDouble.
  ///
  /// In en, this message translates to:
  /// **'Goal: turn back time — it doubles your Chronons'**
  String get goalPrestigeDouble;

  /// No description provided for @goalPrestigePerk.
  ///
  /// In en, this message translates to:
  /// **'Goal: turn back time — enough for {name}'**
  String goalPrestigePerk(String name);

  /// No description provided for @goalPerk.
  ///
  /// In en, this message translates to:
  /// **'Goal: perk {name} — {have}/{need} shards'**
  String goalPerk(String name, String have, String need);

  /// No description provided for @goalPerkBuy.
  ///
  /// In en, this message translates to:
  /// **'Goal: buy the perk — {name}'**
  String goalPerkBuy(String name);

  /// No description provided for @statMultTitle.
  ///
  /// In en, this message translates to:
  /// **'Income multipliers'**
  String get statMultTitle;

  /// No description provided for @statMultChronons.
  ///
  /// In en, this message translates to:
  /// **'Chronons ({count})'**
  String statMultChronons(int count);

  /// No description provided for @statMultAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements ({count})'**
  String statMultAchievements(int count);

  /// No description provided for @statMultLevels.
  ///
  /// In en, this message translates to:
  /// **'Clock mastery'**
  String get statMultLevels;

  /// No description provided for @statMultTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get statMultTurbo;

  /// No description provided for @statMultTotal.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get statMultTotal;

  /// No description provided for @tutorialGotIt.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get tutorialGotIt;

  /// No description provided for @tutorialAutoStart.
  ///
  /// In en, this message translates to:
  /// **'From now on the stopwatch starts by itself: right after each result, the next round begins.'**
  String get tutorialAutoStart;

  /// No description provided for @tip_springs.
  ///
  /// In en, this message translates to:
  /// **'Mainsprings! They wind by themselves, one a day. Spend them on clock mastery: it stays forever.'**
  String get tip_springs;

  /// No description provided for @tip_loop.
  ///
  /// In en, this message translates to:
  /// **'A new loop: everything from zero, but Mainsprings and mastery stay.'**
  String get tip_loop;

  /// No description provided for @tip_loopRule.
  ///
  /// In en, this message translates to:
  /// **'A new loop: everything from zero, but Mainsprings and mastery stay. Chronos\' rule: {rule}.'**
  String tip_loopRule(String rule);

  /// No description provided for @tip_skills.
  ///
  /// In en, this message translates to:
  /// **'Skills boost your own hits.'**
  String get tip_skills;

  /// No description provided for @tip_modes.
  ///
  /// In en, this message translates to:
  /// **'A new mode! Tap to switch it on.'**
  String get tip_modes;

  /// No description provided for @skillBuyLevel.
  ///
  /// In en, this message translates to:
  /// **'Buy Lv {level}'**
  String skillBuyLevel(String level);

  /// No description provided for @generatorEarnsEach.
  ///
  /// In en, this message translates to:
  /// **'+{value}/s each'**
  String generatorEarnsEach(String value);

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpTitle;

  /// No description provided for @helpReplay.
  ///
  /// In en, this message translates to:
  /// **'Show the tutorial again'**
  String get helpReplay;

  /// No description provided for @help_goal_t.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get help_goal_t;

  /// No description provided for @help_goal.
  ///
  /// In en, this message translates to:
  /// **'The stopwatch counts seconds. Tap the screen when it shows 5.00 — the closer, the better:\n• 5.00 (±0.010 s): a PERFECT plus a bonus — seconds of your clocks\' work\n• PERFECT (±0.015 s): 6 Ticks, streak +3\n• GREAT (±0.030 s): 3 Ticks, streak +2\n• GOOD (±0.050 s): 1 Tick, streak +1\n• CLOSE (±0.150 s): a small consolation, the streak breaks\nAnything further is a miss. A tap over a second before the target counts as a slip and is ignored. Skills widen the windows (except 5.00).'**
  String get help_goal;

  /// No description provided for @help_tiki_t.
  ///
  /// In en, this message translates to:
  /// **'Ticks'**
  String get help_tiki_t;

  /// No description provided for @help_tiki.
  ///
  /// In en, this message translates to:
  /// **'Ticks are the game\'s money. The big counter at the top shows how many you have, the smaller one below it how much you earn per second. You spend them in the shop at the bottom.'**
  String get help_tiki;

  /// No description provided for @help_clocks_t.
  ///
  /// In en, this message translates to:
  /// **'Clocks'**
  String get help_clocks_t;

  /// No description provided for @help_clocks.
  ///
  /// In en, this message translates to:
  /// **'Clocks (the Clocks tab) play for you and add Ticks every second — even while the game is closed. Grandpa comes first; buying a clock reveals the next, stronger one. The number on the icon is how many you own. ×1, ×10, ×100 and MAX set how many you buy at once.'**
  String get help_clocks;

  /// No description provided for @help_upgrades_t.
  ///
  /// In en, this message translates to:
  /// **'Clock bonuses'**
  String get help_upgrades_t;

  /// No description provided for @help_upgrades.
  ///
  /// In en, this message translates to:
  /// **'Each clock has a bar. Once you own as many as it shows (10, 20, 40… for Grandpa), all clocks of that kind earn more — free, on their own. The first clocks get ×2; pricier ones have lower counts and a smaller multiplier. Own 25 each of two clocks that go together (like Grandpa and Grandma) and a synergy switches on: they boost each other.'**
  String get help_upgrades;

  /// No description provided for @help_skills_t.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get help_skills_t;

  /// No description provided for @help_skills.
  ///
  /// In en, this message translates to:
  /// **'Skills (the Skills tab) boost your own hits: bigger rewards, wider windows, longer streaks. They have levels — \"Level 2/10\" means the second of ten. Tap a card to read the details.'**
  String get help_skills;

  /// No description provided for @help_combo_t.
  ///
  /// In en, this message translates to:
  /// **'Streak (combo)'**
  String get help_combo_t;

  /// No description provided for @help_combo.
  ///
  /// In en, this message translates to:
  /// **'Hits in a row build a streak, and the streak multiplies every payout (the COMBO bar under the clock). A miss resets it, unless you have a Shield.'**
  String get help_combo;

  /// No description provided for @help_golden_t.
  ///
  /// In en, this message translates to:
  /// **'Golden Second'**
  String get help_golden_t;

  /// No description provided for @help_golden.
  ///
  /// In en, this message translates to:
  /// **'Every so often (10 minutes on average) a golden clock flies across the screen. Tap it and the next round turns golden. Hit that round and you get one of the bonuses; the better the hit, the stronger it is (PERFECT in full, GREAT 60%, GOOD 30%, a miss nothing):\n• Frenzy (45% chance): all income — clocks and hits — ×7 for 77 s\n• Lucky (45%): Ticks at once — 10 minutes of your clocks\' work\n• Hot hand (10%): for 60 s every hit counts as a PERFECT and pays ×10'**
  String get help_golden;

  /// No description provided for @help_modes_t.
  ///
  /// In en, this message translates to:
  /// **'Toggles'**
  String get help_modes_t;

  /// No description provided for @help_modes.
  ///
  /// In en, this message translates to:
  /// **'Later, toggles appear above the shop: \"Blind\" (from 4.00 the stopwatch and its ring disappear, but hits pay ×3, ×4 with the Daredevil perk), \"Second clock\" (two stopwatches, each half of the screen is one) and \"Auto buyer\" (buys clocks for you).'**
  String get help_modes;

  /// No description provided for @help_season_t.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get help_season_t;

  /// No description provided for @help_season.
  ///
  /// In en, this message translates to:
  /// **'On holidays the golden clock changes its look. The badge at the top shows your progress: how many holiday clocks you caught (e.g. 0/5) and how many hits you made (e.g. 0/50). Finishing pays a reward.'**
  String get help_season;

  /// No description provided for @help_prestige_t.
  ///
  /// In en, this message translates to:
  /// **'Time paradox'**
  String get help_prestige_t;

  /// No description provided for @help_prestige.
  ///
  /// In en, this message translates to:
  /// **'Once you\'ve collected a lot, the swirl at the top lights up. You can then rewind time: you start over but get Chronons — a permanent bonus to everything, so the next run goes much faster — and as many Time shards ✦. Spend the Shards on perks right after rewinding, before the new run starts, or later on the paradox screen.'**
  String get help_prestige;

  /// No description provided for @help_icons_t.
  ///
  /// In en, this message translates to:
  /// **'Icons at the top'**
  String get help_icons_t;

  /// No description provided for @help_icons.
  ///
  /// In en, this message translates to:
  /// **'Trophy — achievements (each gives +1% income). Chart — statistics. Dial — the stopwatch look. Gear — settings. Swirl — time paradox. Question mark — this help. Gold spiral — Mainsprings (after your first rewind).'**
  String get help_icons;

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

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSound;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Tell me when the clocks are full'**
  String get settingsNotifications;

  /// No description provided for @settingsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Send game statistics'**
  String get settingsAnalytics;

  /// No description provided for @settingsAnalyticsHint.
  ///
  /// In en, this message translates to:
  /// **'Helps us balance the game. No account, no name, no ad ID.'**
  String get settingsAnalyticsHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsNotation.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get settingsNotation;

  /// No description provided for @notationShort.
  ///
  /// In en, this message translates to:
  /// **'Short (12.4M)'**
  String get notationShort;

  /// No description provided for @notationScientific.
  ///
  /// In en, this message translates to:
  /// **'Scientific (1.24e7)'**
  String get notationScientific;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In en, this message translates to:
  /// **'No shakes or flashes, fewer particles'**
  String get settingsReduceMotionHint;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExport;

  /// No description provided for @settingsExportDone.
  ///
  /// In en, this message translates to:
  /// **'Save copied to the clipboard. Keep it somewhere safe.'**
  String get settingsExportDone;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImport;

  /// No description provided for @settingsImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the save text here'**
  String get settingsImportHint;

  /// No description provided for @settingsImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace the current game with this save?'**
  String get settingsImportConfirm;

  /// No description provided for @settingsImportBad.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a Hit5 save.'**
  String get settingsImportBad;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get settingsReset;

  /// No description provided for @settingsResetConfirm1.
  ///
  /// In en, this message translates to:
  /// **'Sure? You lose everything: Ticks, clocks, Chronons, Shards, perks and achievements. Settings stay.'**
  String get settingsResetConfirm1;

  /// No description provided for @settingsResetConfirm2.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm.'**
  String settingsResetConfirm2(String word);

  /// No description provided for @resetWord.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get resetWord;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits and licences'**
  String get settingsCredits;

  /// No description provided for @creditsLegalese.
  ///
  /// In en, this message translates to:
  /// **'Art: our own, generated with Qwen-Image (Apache 2.0).\nFonts: Paytone One and Nunito (SIL Open Font License 1.1).\nSounds and music: our own, synthesised in code.'**
  String get creditsLegalese;

  /// No description provided for @settingsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get settingsOther;

  /// No description provided for @upg_grandpa_1.
  ///
  /// In en, this message translates to:
  /// **'Reading Glasses'**
  String get upg_grandpa_1;

  /// No description provided for @upg_grandpa_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Finally sees the hands.'**
  String get upg_grandpa_1_desc;

  /// No description provided for @upg_grandpa_2.
  ///
  /// In en, this message translates to:
  /// **'New Battery'**
  String get upg_grandpa_2;

  /// No description provided for @upg_grandpa_2_desc.
  ///
  /// In en, this message translates to:
  /// **'First one since cassette tapes.'**
  String get upg_grandpa_2_desc;

  /// No description provided for @upg_grandpa_3.
  ///
  /// In en, this message translates to:
  /// **'Non-slip Slippers'**
  String get upg_grandpa_3;

  /// No description provided for @upg_grandpa_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Steady feet, steady thumb.'**
  String get upg_grandpa_3_desc;

  /// No description provided for @upg_grandpa_4.
  ///
  /// In en, this message translates to:
  /// **'Crossword: TIME'**
  String get upg_grandpa_4;

  /// No description provided for @upg_grandpa_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Solved in exactly 5.00 s.'**
  String get upg_grandpa_4_desc;

  /// No description provided for @upg_grandpa_5.
  ///
  /// In en, this message translates to:
  /// **'Spa Retreat'**
  String get upg_grandpa_5;

  /// No description provided for @upg_grandpa_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Comes back rested and twice as sharp.'**
  String get upg_grandpa_5_desc;

  /// No description provided for @upg_grandpa_6.
  ///
  /// In en, this message translates to:
  /// **'Tech-savvy Grandson'**
  String get upg_grandpa_6;

  /// No description provided for @upg_grandpa_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Synced his watch to an atomic server.'**
  String get upg_grandpa_6_desc;

  /// No description provided for @upg_grandpa_7.
  ///
  /// In en, this message translates to:
  /// **'Punctuality Medal'**
  String get upg_grandpa_7;

  /// No description provided for @upg_grandpa_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Pinned proudly to the waistcoat.'**
  String get upg_grandpa_7_desc;

  /// No description provided for @upg_grandpa_8.
  ///
  /// In en, this message translates to:
  /// **'Great-grandpa\'s Watch'**
  String get upg_grandpa_8;

  /// No description provided for @upg_grandpa_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Ticking in the family for three generations.'**
  String get upg_grandpa_8_desc;

  /// No description provided for @upg_grandma_1.
  ///
  /// In en, this message translates to:
  /// **'Happy Hen Eggs'**
  String get upg_grandma_1;

  /// No description provided for @upg_grandma_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Happy hens, happy timers.'**
  String get upg_grandma_1_desc;

  /// No description provided for @upg_grandma_2.
  ///
  /// In en, this message translates to:
  /// **'Polka-dot Apron'**
  String get upg_grandma_2;

  /// No description provided for @upg_grandma_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Aerodynamic.'**
  String get upg_grandma_2_desc;

  /// No description provided for @upg_grandma_3.
  ///
  /// In en, this message translates to:
  /// **'A Second Timer'**
  String get upg_grandma_3;

  /// No description provided for @upg_grandma_3_desc.
  ///
  /// In en, this message translates to:
  /// **'One for the eggs, one for the soup.'**
  String get upg_grandma_3_desc;

  /// No description provided for @upg_grandma_4.
  ///
  /// In en, this message translates to:
  /// **'Baking Club'**
  String get upg_grandma_4;

  /// No description provided for @upg_grandma_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Precision training. With cake.'**
  String get upg_grandma_4_desc;

  /// No description provided for @upg_grandma_5.
  ///
  /// In en, this message translates to:
  /// **'“Five-Second Recipes”'**
  String get upg_grandma_5;

  /// No description provided for @upg_grandma_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Quick dishes only.'**
  String get upg_grandma_5_desc;

  /// No description provided for @upg_grandma_6.
  ///
  /// In en, this message translates to:
  /// **'Induction Hob'**
  String get upg_grandma_6;

  /// No description provided for @upg_grandma_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Boils before you think.'**
  String get upg_grandma_6_desc;

  /// No description provided for @upg_grandma_7.
  ///
  /// In en, this message translates to:
  /// **'Influencer Granddaughter'**
  String get upg_grandma_7;

  /// No description provided for @upg_grandma_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Films every perfect 5.00.'**
  String get upg_grandma_7_desc;

  /// No description provided for @upg_grandma_8.
  ///
  /// In en, this message translates to:
  /// **'Golden Rolling Pin'**
  String get upg_grandma_8;

  /// No description provided for @upg_grandma_8_desc.
  ///
  /// In en, this message translates to:
  /// **'A neighbourhood legend.'**
  String get upg_grandma_8_desc;

  /// No description provided for @upg_cuckoo_1.
  ///
  /// In en, this message translates to:
  /// **'Diction Lessons'**
  String get upg_cuckoo_1;

  /// No description provided for @upg_cuckoo_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Cuck-oo. Crisp and on time.'**
  String get upg_cuckoo_1_desc;

  /// No description provided for @upg_cuckoo_2.
  ///
  /// In en, this message translates to:
  /// **'Fresh Springs'**
  String get upg_cuckoo_2;

  /// No description provided for @upg_cuckoo_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Pops out like a slingshot.'**
  String get upg_cuckoo_2_desc;

  /// No description provided for @upg_cuckoo_3.
  ///
  /// In en, this message translates to:
  /// **'Nest with a View'**
  String get upg_cuckoo_3;

  /// No description provided for @upg_cuckoo_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Better view, better cuckoos.'**
  String get upg_cuckoo_3_desc;

  /// No description provided for @upg_cuckoo_4.
  ///
  /// In en, this message translates to:
  /// **'Cuckoo Choir'**
  String get upg_cuckoo_4;

  /// No description provided for @upg_cuckoo_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Cuckooing in canon.'**
  String get upg_cuckoo_4_desc;

  /// No description provided for @upg_cuckoo_5.
  ///
  /// In en, this message translates to:
  /// **'Swiss Master Class'**
  String get upg_cuckoo_5;

  /// No description provided for @upg_cuckoo_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Precision straight from the Alps.'**
  String get upg_cuckoo_5_desc;

  /// No description provided for @upg_cuckoo_6.
  ///
  /// In en, this message translates to:
  /// **'Espresso Beans'**
  String get upg_cuckoo_6;

  /// No description provided for @upg_cuckoo_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Cuckoos faster than it means to.'**
  String get upg_cuckoo_6_desc;

  /// No description provided for @upg_cuckoo_7.
  ///
  /// In en, this message translates to:
  /// **'A Proper Agent'**
  String get upg_cuckoo_7;

  /// No description provided for @upg_cuckoo_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Signed for a world tour.'**
  String get upg_cuckoo_7_desc;

  /// No description provided for @upg_cuckoo_8.
  ///
  /// In en, this message translates to:
  /// **'Black Forest Original'**
  String get upg_cuckoo_8;

  /// No description provided for @upg_cuckoo_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Certified, with a pedigree.'**
  String get upg_cuckoo_8_desc;

  /// No description provided for @upg_metronome_1.
  ///
  /// In en, this message translates to:
  /// **'New Weight'**
  String get upg_metronome_1;

  /// No description provided for @upg_metronome_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Less wobble, more hits.'**
  String get upg_metronome_1_desc;

  /// No description provided for @upg_metronome_2.
  ///
  /// In en, this message translates to:
  /// **'Pendulum Oil'**
  String get upg_metronome_2;

  /// No description provided for @upg_metronome_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Silence. Just tick-tock.'**
  String get upg_metronome_2_desc;

  /// No description provided for @upg_metronome_3.
  ///
  /// In en, this message translates to:
  /// **'Six-Eight Time'**
  String get upg_metronome_3;

  /// No description provided for @upg_metronome_3_desc.
  ///
  /// In en, this message translates to:
  /// **'For a change.'**
  String get upg_metronome_3_desc;

  /// No description provided for @upg_metronome_4.
  ///
  /// In en, this message translates to:
  /// **'Orchestra Gig'**
  String get upg_metronome_4;

  /// No description provided for @upg_metronome_4_desc.
  ///
  /// In en, this message translates to:
  /// **'A hundred violins watch only him.'**
  String get upg_metronome_4_desc;

  /// No description provided for @upg_metronome_5.
  ///
  /// In en, this message translates to:
  /// **'Techno Mode'**
  String get upg_metronome_5;

  /// No description provided for @upg_metronome_5_desc.
  ///
  /// In en, this message translates to:
  /// **'140 beats a minute, not one off.'**
  String get upg_metronome_5_desc;

  /// No description provided for @upg_metronome_6.
  ///
  /// In en, this message translates to:
  /// **'Digital Twin'**
  String get upg_metronome_6;

  /// No description provided for @upg_metronome_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Sibling rivalry.'**
  String get upg_metronome_6_desc;

  /// No description provided for @upg_metronome_7.
  ///
  /// In en, this message translates to:
  /// **'Jazz Quartet Tour'**
  String get upg_metronome_7;

  /// No description provided for @upg_metronome_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Swings, never late.'**
  String get upg_metronome_7_desc;

  /// No description provided for @upg_metronome_8.
  ///
  /// In en, this message translates to:
  /// **'Golden Pendulum'**
  String get upg_metronome_8;

  /// No description provided for @upg_metronome_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Perfect rhythm.'**
  String get upg_metronome_8_desc;

  /// No description provided for @upg_watchmaker_1.
  ///
  /// In en, this message translates to:
  /// **'New Loupe'**
  String get upg_watchmaker_1;

  /// No description provided for @upg_watchmaker_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Sees every gear. Even the mental ones.'**
  String get upg_watchmaker_1_desc;

  /// No description provided for @upg_watchmaker_2.
  ///
  /// In en, this message translates to:
  /// **'Screwdriver Set'**
  String get upg_watchmaker_2;

  /// No description provided for @upg_watchmaker_2_desc.
  ///
  /// In en, this message translates to:
  /// **'48 sizes, all of them tiny.'**
  String get upg_watchmaker_2_desc;

  /// No description provided for @upg_watchmaker_3.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get upg_watchmaker_3;

  /// No description provided for @upg_watchmaker_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Learns on your Ticks.'**
  String get upg_watchmaker_3_desc;

  /// No description provided for @upg_watchmaker_4.
  ///
  /// In en, this message translates to:
  /// **'Window Workbench'**
  String get upg_watchmaker_4;

  /// No description provided for @upg_watchmaker_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Daylight, daylight precision.'**
  String get upg_watchmaker_4_desc;

  /// No description provided for @upg_watchmaker_5.
  ///
  /// In en, this message translates to:
  /// **'Swiss Movement'**
  String get upg_watchmaker_5;

  /// No description provided for @upg_watchmaker_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Delivered in a padlocked case.'**
  String get upg_watchmaker_5_desc;

  /// No description provided for @upg_watchmaker_6.
  ///
  /// In en, this message translates to:
  /// **'Tourbillon'**
  String get upg_watchmaker_6;

  /// No description provided for @upg_watchmaker_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Spins so it never errs.'**
  String get upg_watchmaker_6_desc;

  /// No description provided for @upg_watchmaker_7.
  ///
  /// In en, this message translates to:
  /// **'Watchmakers\' Guild'**
  String get upg_watchmaker_7;

  /// No description provided for @upg_watchmaker_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Secret knowledge, passed on in whispers.'**
  String get upg_watchmaker_7_desc;

  /// No description provided for @upg_watchmaker_8.
  ///
  /// In en, this message translates to:
  /// **'Grand Complication'**
  String get upg_watchmaker_8;

  /// No description provided for @upg_watchmaker_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Nobody knows what it does. It works.'**
  String get upg_watchmaker_8_desc;

  /// No description provided for @upg_sprintJudge_1.
  ///
  /// In en, this message translates to:
  /// **'New Whistle'**
  String get upg_sprintJudge_1;

  /// No description provided for @upg_sprintJudge_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Tweet! Right on time.'**
  String get upg_sprintJudge_1_desc;

  /// No description provided for @upg_sprintJudge_2.
  ///
  /// In en, this message translates to:
  /// **'Photo Finish'**
  String get upg_sprintJudge_2;

  /// No description provided for @upg_sprintJudge_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Sees one hundredth of a second.'**
  String get upg_sprintJudge_2_desc;

  /// No description provided for @upg_sprintJudge_3.
  ///
  /// In en, this message translates to:
  /// **'Starter Pistol'**
  String get upg_sprintJudge_3;

  /// No description provided for @upg_sprintJudge_3_desc.
  ///
  /// In en, this message translates to:
  /// **'No bullets, all timing.'**
  String get upg_sprintJudge_3_desc;

  /// No description provided for @upg_sprintJudge_4.
  ///
  /// In en, this message translates to:
  /// **'Umpire\'s Chair'**
  String get upg_sprintJudge_4;

  /// No description provided for @upg_sprintJudge_4_desc.
  ///
  /// In en, this message translates to:
  /// **'With a view straight down the line.'**
  String get upg_sprintJudge_4_desc;

  /// No description provided for @upg_sprintJudge_5.
  ///
  /// In en, this message translates to:
  /// **'Olympic Licence'**
  String get upg_sprintJudge_5;

  /// No description provided for @upg_sprintJudge_5_desc.
  ///
  /// In en, this message translates to:
  /// **'It\'s official now.'**
  String get upg_sprintJudge_5_desc;

  /// No description provided for @upg_sprintJudge_6.
  ///
  /// In en, this message translates to:
  /// **'Video Replay'**
  String get upg_sprintJudge_6;

  /// No description provided for @upg_sprintJudge_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Frame by frame.'**
  String get upg_sprintJudge_6_desc;

  /// No description provided for @upg_sprintJudge_7.
  ///
  /// In en, this message translates to:
  /// **'World-record Judging'**
  String get upg_sprintJudge_7;

  /// No description provided for @upg_sprintJudge_7_desc.
  ///
  /// In en, this message translates to:
  /// **'9.58 s? Too slow.'**
  String get upg_sprintJudge_7_desc;

  /// No description provided for @upg_sprintJudge_8.
  ///
  /// In en, this message translates to:
  /// **'Golden Stopwatch'**
  String get upg_sprintJudge_8;

  /// No description provided for @upg_sprintJudge_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Times as if it invented time.'**
  String get upg_sprintJudge_8_desc;

  /// No description provided for @upg_stationClock_1.
  ///
  /// In en, this message translates to:
  /// **'New Timetable'**
  String get upg_stationClock_1;

  /// No description provided for @upg_stationClock_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Now accounts for reality.'**
  String get upg_stationClock_1_desc;

  /// No description provided for @upg_stationClock_2.
  ///
  /// In en, this message translates to:
  /// **'Polished Face'**
  String get upg_stationClock_2;

  /// No description provided for @upg_stationClock_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Visible from platform five.'**
  String get upg_stationClock_2_desc;

  /// No description provided for @upg_stationClock_3.
  ///
  /// In en, this message translates to:
  /// **'PA Announcement'**
  String get upg_stationClock_3;

  /// No description provided for @upg_stationClock_3_desc.
  ///
  /// In en, this message translates to:
  /// **'“The 5.00 will arrive on time.”'**
  String get upg_stationClock_3_desc;

  /// No description provided for @upg_stationClock_4.
  ///
  /// In en, this message translates to:
  /// **'Stationmaster'**
  String get upg_stationClock_4;

  /// No description provided for @upg_stationClock_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Peaked cap, dead serious.'**
  String get upg_stationClock_4_desc;

  /// No description provided for @upg_stationClock_5.
  ///
  /// In en, this message translates to:
  /// **'High-speed Rail'**
  String get upg_stationClock_5;

  /// No description provided for @upg_stationClock_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Fewer delays, more hits.'**
  String get upg_stationClock_5_desc;

  /// No description provided for @upg_stationClock_6.
  ///
  /// In en, this message translates to:
  /// **'Radio-controlled'**
  String get upg_stationClock_6;

  /// No description provided for @upg_stationClock_6_desc.
  ///
  /// In en, this message translates to:
  /// **'The radio knows the time.'**
  String get upg_stationClock_6_desc;

  /// No description provided for @upg_stationClock_7.
  ///
  /// In en, this message translates to:
  /// **'Grand Central'**
  String get upg_stationClock_7;

  /// No description provided for @upg_stationClock_7_desc.
  ///
  /// In en, this message translates to:
  /// **'A thousand commuters, one clock.'**
  String get upg_stationClock_7_desc;

  /// No description provided for @upg_stationClock_8.
  ///
  /// In en, this message translates to:
  /// **'The Train That Was On Time'**
  String get upg_stationClock_8;

  /// No description provided for @upg_stationClock_8_desc.
  ///
  /// In en, this message translates to:
  /// **'A legend nobody believed.'**
  String get upg_stationClock_8_desc;

  /// No description provided for @upg_quartz_1.
  ///
  /// In en, this message translates to:
  /// **'Fresh Crystal'**
  String get upg_quartz_1;

  /// No description provided for @upg_quartz_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Vibrates like new.'**
  String get upg_quartz_1_desc;

  /// No description provided for @upg_quartz_2.
  ///
  /// In en, this message translates to:
  /// **'Proper Soldering'**
  String get upg_quartz_2;

  /// No description provided for @upg_quartz_2_desc.
  ///
  /// In en, this message translates to:
  /// **'No cold joints, no excuses.'**
  String get upg_quartz_2_desc;

  /// No description provided for @upg_quartz_3.
  ///
  /// In en, this message translates to:
  /// **'LCD Display'**
  String get upg_quartz_3;

  /// No description provided for @upg_quartz_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Digits straight from the 80s.'**
  String get upg_quartz_3_desc;

  /// No description provided for @upg_quartz_4.
  ///
  /// In en, this message translates to:
  /// **'Temperature Compensation'**
  String get upg_quartz_4;

  /// No description provided for @upg_quartz_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t care about the weather.'**
  String get upg_quartz_4_desc;

  /// No description provided for @upg_quartz_5.
  ///
  /// In en, this message translates to:
  /// **'Dual Oscillator'**
  String get upg_quartz_5;

  /// No description provided for @upg_quartz_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Two times 32,768.'**
  String get upg_quartz_5_desc;

  /// No description provided for @upg_quartz_6.
  ///
  /// In en, this message translates to:
  /// **'Swiss Factory'**
  String get upg_quartz_6;

  /// No description provided for @upg_quartz_6_desc.
  ///
  /// In en, this message translates to:
  /// **'The irony.'**
  String get upg_quartz_6_desc;

  /// No description provided for @upg_quartz_7.
  ///
  /// In en, this message translates to:
  /// **'Built-in Calculator'**
  String get upg_quartz_7;

  /// No description provided for @upg_quartz_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Counts Ticks on the fly.'**
  String get upg_quartz_7_desc;

  /// No description provided for @upg_quartz_8.
  ///
  /// In en, this message translates to:
  /// **'Rock Crystal'**
  String get upg_quartz_8;

  /// No description provided for @upg_quartz_8_desc.
  ///
  /// In en, this message translates to:
  /// **'The one from the legends.'**
  String get upg_quartz_8_desc;

  /// No description provided for @upg_atomic_1.
  ///
  /// In en, this message translates to:
  /// **'Laser Cooling'**
  String get upg_atomic_1;

  /// No description provided for @upg_atomic_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Atoms almost stand still. Almost.'**
  String get upg_atomic_1_desc;

  /// No description provided for @upg_atomic_2.
  ///
  /// In en, this message translates to:
  /// **'Purer Caesium'**
  String get upg_atomic_2;

  /// No description provided for @upg_atomic_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Caesium-133, no additives.'**
  String get upg_atomic_2_desc;

  /// No description provided for @upg_atomic_3.
  ///
  /// In en, this message translates to:
  /// **'Atomic Fountain'**
  String get upg_atomic_3;

  /// No description provided for @upg_atomic_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Atoms bounce to the beat.'**
  String get upg_atomic_3_desc;

  /// No description provided for @upg_atomic_4.
  ///
  /// In en, this message translates to:
  /// **'Optical Clock'**
  String get upg_atomic_4;

  /// No description provided for @upg_atomic_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Measures time with light.'**
  String get upg_atomic_4_desc;

  /// No description provided for @upg_atomic_5.
  ///
  /// In en, this message translates to:
  /// **'Ion Trap'**
  String get upg_atomic_5;

  /// No description provided for @upg_atomic_5_desc.
  ///
  /// In en, this message translates to:
  /// **'One ion, zero excuses.'**
  String get upg_atomic_5_desc;

  /// No description provided for @upg_atomic_6.
  ///
  /// In en, this message translates to:
  /// **'Lab Network'**
  String get upg_atomic_6;

  /// No description provided for @upg_atomic_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Every second is put to a vote.'**
  String get upg_atomic_6_desc;

  /// No description provided for @upg_atomic_7.
  ///
  /// In en, this message translates to:
  /// **'Leap Second'**
  String get upg_atomic_7;

  /// No description provided for @upg_atomic_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Added while nobody was looking.'**
  String get upg_atomic_7_desc;

  /// No description provided for @upg_atomic_8.
  ///
  /// In en, this message translates to:
  /// **'Nuclear Clock'**
  String get upg_atomic_8;

  /// No description provided for @upg_atomic_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Thorium-229 doesn\'t do jokes.'**
  String get upg_atomic_8_desc;

  /// No description provided for @upg_gps_1.
  ///
  /// In en, this message translates to:
  /// **'Better Antenna'**
  String get upg_gps_1;

  /// No description provided for @upg_gps_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Hears Earth more clearly.'**
  String get upg_gps_1_desc;

  /// No description provided for @upg_gps_2.
  ///
  /// In en, this message translates to:
  /// **'Relativity Fix'**
  String get upg_gps_2;

  /// No description provided for @upg_gps_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Einstein would be proud.'**
  String get upg_gps_2_desc;

  /// No description provided for @upg_gps_3.
  ///
  /// In en, this message translates to:
  /// **'Bigger Solar Panel'**
  String get upg_gps_3;

  /// No description provided for @upg_gps_3_desc.
  ///
  /// In en, this message translates to:
  /// **'More power, more ticks.'**
  String get upg_gps_3_desc;

  /// No description provided for @upg_gps_4.
  ///
  /// In en, this message translates to:
  /// **'Constellation'**
  String get upg_gps_4;

  /// No description provided for @upg_gps_4_desc.
  ///
  /// In en, this message translates to:
  /// **'31 friends in orbit.'**
  String get upg_gps_4_desc;

  /// No description provided for @upg_gps_5.
  ///
  /// In en, this message translates to:
  /// **'Ionosphere Correction'**
  String get upg_gps_5;

  /// No description provided for @upg_gps_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Through clouds and storms.'**
  String get upg_gps_5_desc;

  /// No description provided for @upg_gps_6.
  ///
  /// In en, this message translates to:
  /// **'Ground Station'**
  String get upg_gps_6;

  /// No description provided for @upg_gps_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Someone keeps watch from below.'**
  String get upg_gps_6_desc;

  /// No description provided for @upg_gps_7.
  ///
  /// In en, this message translates to:
  /// **'Laser Link'**
  String get upg_gps_7;

  /// No description provided for @upg_gps_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Satellites whispering in light.'**
  String get upg_gps_7_desc;

  /// No description provided for @upg_gps_8.
  ///
  /// In en, this message translates to:
  /// **'Geostationary Orbit'**
  String get upg_gps_8;

  /// No description provided for @upg_gps_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Always in the same place. Always on time.'**
  String get upg_gps_8_desc;

  /// No description provided for @upg_pulsar_1.
  ///
  /// In en, this message translates to:
  /// **'Bigger Dish'**
  String get upg_pulsar_1;

  /// No description provided for @upg_pulsar_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Hears every pulse.'**
  String get upg_pulsar_1_desc;

  /// No description provided for @upg_pulsar_2.
  ///
  /// In en, this message translates to:
  /// **'Millisecond Pulsar'**
  String get upg_pulsar_2;

  /// No description provided for @upg_pulsar_2_desc.
  ///
  /// In en, this message translates to:
  /// **'700 spins a second.'**
  String get upg_pulsar_2_desc;

  /// No description provided for @upg_pulsar_3.
  ///
  /// In en, this message translates to:
  /// **'Sky Map'**
  String get upg_pulsar_3;

  /// No description provided for @upg_pulsar_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Finally we know where to look.'**
  String get upg_pulsar_3_desc;

  /// No description provided for @upg_pulsar_4.
  ///
  /// In en, this message translates to:
  /// **'Pulsar Timing Array'**
  String get upg_pulsar_4;

  /// No description provided for @upg_pulsar_4_desc.
  ///
  /// In en, this message translates to:
  /// **'A cosmic metronome choir.'**
  String get upg_pulsar_4_desc;

  /// No description provided for @upg_pulsar_5.
  ///
  /// In en, this message translates to:
  /// **'Gravitational Waves'**
  String get upg_pulsar_5;

  /// No description provided for @upg_pulsar_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Spacetime wobbles on the beat.'**
  String get upg_pulsar_5_desc;

  /// No description provided for @upg_pulsar_6.
  ///
  /// In en, this message translates to:
  /// **'Magnetar'**
  String get upg_pulsar_6;

  /// No description provided for @upg_pulsar_6_desc.
  ///
  /// In en, this message translates to:
  /// **'A pulsar with attitude.'**
  String get upg_pulsar_6_desc;

  /// No description provided for @upg_pulsar_7.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Lighthouse'**
  String get upg_pulsar_7;

  /// No description provided for @upg_pulsar_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Guides ships home. On time.'**
  String get upg_pulsar_7_desc;

  /// No description provided for @upg_pulsar_8.
  ///
  /// In en, this message translates to:
  /// **'Heart of the Galaxy'**
  String get upg_pulsar_8;

  /// No description provided for @upg_pulsar_8_desc.
  ///
  /// In en, this message translates to:
  /// **'The whole Milky Way ticks along.'**
  String get upg_pulsar_8_desc;

  /// No description provided for @upg_timeMachine_1.
  ///
  /// In en, this message translates to:
  /// **'Flux Capacitor'**
  String get upg_timeMachine_1;

  /// No description provided for @upg_timeMachine_1_desc.
  ///
  /// In en, this message translates to:
  /// **'1.21 gigawatts, not a watt less.'**
  String get upg_timeMachine_1_desc;

  /// No description provided for @upg_timeMachine_2.
  ///
  /// In en, this message translates to:
  /// **'Seat Belts'**
  String get upg_timeMachine_2;

  /// No description provided for @upg_timeMachine_2_desc.
  ///
  /// In en, this message translates to:
  /// **'In case of paradox.'**
  String get upg_timeMachine_2_desc;

  /// No description provided for @upg_timeMachine_3.
  ///
  /// In en, this message translates to:
  /// **'Note from the Future'**
  String get upg_timeMachine_3;

  /// No description provided for @upg_timeMachine_3_desc.
  ///
  /// In en, this message translates to:
  /// **'“Tap now.”'**
  String get upg_timeMachine_3_desc;

  /// No description provided for @upg_timeMachine_4.
  ///
  /// In en, this message translates to:
  /// **'Time Loop'**
  String get upg_timeMachine_4;

  /// No description provided for @upg_timeMachine_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Practises the same five seconds forever.'**
  String get upg_timeMachine_4_desc;

  /// No description provided for @upg_timeMachine_5.
  ///
  /// In en, this message translates to:
  /// **'Spare Timeline'**
  String get upg_timeMachine_5;

  /// No description provided for @upg_timeMachine_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Just in case.'**
  String get upg_timeMachine_5_desc;

  /// No description provided for @upg_timeMachine_6.
  ///
  /// In en, this message translates to:
  /// **'Tours to 5.00'**
  String get upg_timeMachine_6;

  /// No description provided for @upg_timeMachine_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Guided, of course.'**
  String get upg_timeMachine_6_desc;

  /// No description provided for @upg_timeMachine_7.
  ///
  /// In en, this message translates to:
  /// **'Meeting Yourself'**
  String get upg_timeMachine_7;

  /// No description provided for @upg_timeMachine_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Polite, but weird.'**
  String get upg_timeMachine_7_desc;

  /// No description provided for @upg_timeMachine_8.
  ///
  /// In en, this message translates to:
  /// **'End of Time'**
  String get upg_timeMachine_8;

  /// No description provided for @upg_timeMachine_8_desc.
  ///
  /// In en, this message translates to:
  /// **'One-way ticket.'**
  String get upg_timeMachine_8_desc;

  /// No description provided for @upg_schrodinger_1.
  ///
  /// In en, this message translates to:
  /// **'Bigger Box'**
  String get upg_schrodinger_1;

  /// No description provided for @upg_schrodinger_1_desc.
  ///
  /// In en, this message translates to:
  /// **'More room for uncertainty.'**
  String get upg_schrodinger_1_desc;

  /// No description provided for @upg_schrodinger_2.
  ///
  /// In en, this message translates to:
  /// **'Quantum Kibble'**
  String get upg_schrodinger_2;

  /// No description provided for @upg_schrodinger_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Eaten and not eaten.'**
  String get upg_schrodinger_2_desc;

  /// No description provided for @upg_schrodinger_3.
  ///
  /// In en, this message translates to:
  /// **'Entangled Yarn'**
  String get upg_schrodinger_3;

  /// No description provided for @upg_schrodinger_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Entanglement on demand.'**
  String get upg_schrodinger_3_desc;

  /// No description provided for @upg_schrodinger_4.
  ///
  /// In en, this message translates to:
  /// **'Superposition Catnip'**
  String get upg_schrodinger_4;

  /// No description provided for @upg_schrodinger_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Purrs in two states at once.'**
  String get upg_schrodinger_4_desc;

  /// No description provided for @upg_schrodinger_5.
  ///
  /// In en, this message translates to:
  /// **'Observer on Holiday'**
  String get upg_schrodinger_5;

  /// No description provided for @upg_schrodinger_5_desc.
  ///
  /// In en, this message translates to:
  /// **'No one looks, everything hits.'**
  String get upg_schrodinger_5_desc;

  /// No description provided for @upg_schrodinger_6.
  ///
  /// In en, this message translates to:
  /// **'A Second Cat'**
  String get upg_schrodinger_6;

  /// No description provided for @upg_schrodinger_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Now there are four states.'**
  String get upg_schrodinger_6_desc;

  /// No description provided for @upg_schrodinger_7.
  ///
  /// In en, this message translates to:
  /// **'Many Worlds'**
  String get upg_schrodinger_7;

  /// No description provided for @upg_schrodinger_7_desc.
  ///
  /// In en, this message translates to:
  /// **'In one of them it\'s always 5.00.'**
  String get upg_schrodinger_7_desc;

  /// No description provided for @upg_schrodinger_8.
  ///
  /// In en, this message translates to:
  /// **'Box Opened'**
  String get upg_schrodinger_8;

  /// No description provided for @upg_schrodinger_8_desc.
  ///
  /// In en, this message translates to:
  /// **'It hit. Definitely hit.'**
  String get upg_schrodinger_8_desc;

  /// No description provided for @upg_chronos_1.
  ///
  /// In en, this message translates to:
  /// **'Sharpened Scythe'**
  String get upg_chronos_1;

  /// No description provided for @upg_chronos_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Slices seconds into hundredths.'**
  String get upg_chronos_1_desc;

  /// No description provided for @upg_chronos_2.
  ///
  /// In en, this message translates to:
  /// **'Olympian Hourglass'**
  String get upg_chronos_2;

  /// No description provided for @upg_chronos_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Sand straight from the gods.'**
  String get upg_chronos_2_desc;

  /// No description provided for @upg_chronos_3.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get upg_chronos_3;

  /// No description provided for @upg_chronos_3_desc.
  ///
  /// In en, this message translates to:
  /// **'The faithful bring watches.'**
  String get upg_chronos_3_desc;

  /// No description provided for @upg_chronos_4.
  ///
  /// In en, this message translates to:
  /// **'A Word with Kairos'**
  String get upg_chronos_4;

  /// No description provided for @upg_chronos_4_desc.
  ///
  /// In en, this message translates to:
  /// **'About the right moment.'**
  String get upg_chronos_4_desc;

  /// No description provided for @upg_chronos_5.
  ///
  /// In en, this message translates to:
  /// **'Throne of Gears'**
  String get upg_chronos_5;

  /// No description provided for @upg_chronos_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Comfy, if a bit ticky.'**
  String get upg_chronos_5_desc;

  /// No description provided for @upg_chronos_6.
  ///
  /// In en, this message translates to:
  /// **'Pantheon of Punctuality'**
  String get upg_chronos_6;

  /// No description provided for @upg_chronos_6_desc.
  ///
  /// In en, this message translates to:
  /// **'Gods who are never late.'**
  String get upg_chronos_6_desc;

  /// No description provided for @upg_chronos_7.
  ///
  /// In en, this message translates to:
  /// **'Eternity'**
  String get upg_chronos_7;

  /// No description provided for @upg_chronos_7_desc.
  ///
  /// In en, this message translates to:
  /// **'Has time. Literally.'**
  String get upg_chronos_7_desc;

  /// No description provided for @upg_chronos_8.
  ///
  /// In en, this message translates to:
  /// **'The Absolute Second'**
  String get upg_chronos_8;

  /// No description provided for @upg_chronos_8_desc.
  ///
  /// In en, this message translates to:
  /// **'5.00. Always was, always will be.'**
  String get upg_chronos_8_desc;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAdPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get settingsAdPrivacy;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus'**
  String get dailyTitle;

  /// No description provided for @dailyDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String dailyDay(int day, int total);

  /// No description provided for @dailyHint.
  ///
  /// In en, this message translates to:
  /// **'Come back every day — the bonus grows for {total} days. Missing one starts over.'**
  String dailyHint(int total);

  /// No description provided for @adOfferHow.
  ///
  /// In en, this message translates to:
  /// **'A short video ad. The reward comes after it ends.'**
  String get adOfferHow;

  /// No description provided for @adWatch.
  ///
  /// In en, this message translates to:
  /// **'▶ Watch'**
  String get adWatch;

  /// No description provided for @adNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get adNotNow;

  /// No description provided for @adOfferTurboTitle.
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get adOfferTurboTitle;

  /// No description provided for @adOfferTurboReward.
  ///
  /// In en, this message translates to:
  /// **'×{mult} Ticks for {minutes} min'**
  String adOfferTurboReward(int mult, int minutes);

  /// No description provided for @adOfferTurboDetail.
  ///
  /// In en, this message translates to:
  /// **'All earnings — clocks and your hits — are doubled. Turbo time runs only while you play; stock up to {hours} h.'**
  String adOfferTurboDetail(int hours);

  /// No description provided for @adOfferTurboStock.
  ///
  /// In en, this message translates to:
  /// **'You still have {time} — the ad adds another 30 min.'**
  String adOfferTurboStock(String time);

  /// No description provided for @adOfferGoldenTitle.
  ///
  /// In en, this message translates to:
  /// **'Golden Second'**
  String get adOfferGoldenTitle;

  /// No description provided for @adOfferGoldenReward.
  ///
  /// In en, this message translates to:
  /// **'A golden clock right away'**
  String get adOfferGoldenReward;

  /// No description provided for @adOfferGoldenDetail.
  ///
  /// In en, this message translates to:
  /// **'After the ad a golden clock flies in. Catch it and the next round gives a random bonus: Frenzy, Lucky or Hot Hand.'**
  String get adOfferGoldenDetail;

  /// No description provided for @adOfferBagTitle.
  ///
  /// In en, this message translates to:
  /// **'Bag of Ticks'**
  String get adOfferBagTitle;

  /// No description provided for @adOfferBagDetail.
  ///
  /// In en, this message translates to:
  /// **'Right away, as much as your clocks earn in {minutes} min.'**
  String adOfferBagDetail(int minutes);

  /// No description provided for @adNoReward.
  ///
  /// In en, this message translates to:
  /// **'The ad didn\'t finish — no reward. You can try again.'**
  String get adNoReward;

  /// No description provided for @adDoneTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo on! ×2 for {time}.'**
  String adDoneTurbo(String time);

  /// No description provided for @adDoneGolden.
  ///
  /// In en, this message translates to:
  /// **'The golden clock is coming — catch it!'**
  String get adDoneGolden;

  /// No description provided for @adDoneBag.
  ///
  /// In en, this message translates to:
  /// **'Bag of Ticks collected!'**
  String get adDoneBag;

  /// No description provided for @adDoneRescue.
  ///
  /// In en, this message translates to:
  /// **'Streak restored!'**
  String get adDoneRescue;

  /// No description provided for @adDoneOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline income doubled!'**
  String get adDoneOffline;

  /// No description provided for @season_valentine.
  ///
  /// In en, this message translates to:
  /// **'Valentine\'s'**
  String get season_valentine;

  /// No description provided for @season_valentine_items.
  ///
  /// In en, this message translates to:
  /// **'Hearts'**
  String get season_valentine_items;

  /// No description provided for @season_easter.
  ///
  /// In en, this message translates to:
  /// **'Easter'**
  String get season_easter;

  /// No description provided for @season_easter_items.
  ///
  /// In en, this message translates to:
  /// **'Chicks'**
  String get season_easter_items;

  /// No description provided for @season_summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get season_summer;

  /// No description provided for @season_summer_items.
  ///
  /// In en, this message translates to:
  /// **'Suns'**
  String get season_summer_items;

  /// No description provided for @season_halloween.
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get season_halloween;

  /// No description provided for @season_halloween_items.
  ///
  /// In en, this message translates to:
  /// **'Pumpkins'**
  String get season_halloween_items;

  /// No description provided for @season_christmas.
  ///
  /// In en, this message translates to:
  /// **'Christmas'**
  String get season_christmas;

  /// No description provided for @season_christmas_items.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get season_christmas_items;

  /// No description provided for @season_newYear.
  ///
  /// In en, this message translates to:
  /// **'New Year'**
  String get season_newYear;

  /// No description provided for @season_newYear_items.
  ///
  /// In en, this message translates to:
  /// **'Party poppers'**
  String get season_newYear_items;

  /// No description provided for @seasonUntil.
  ///
  /// In en, this message translates to:
  /// **'Event until {date}'**
  String seasonUntil(String date);

  /// No description provided for @seasonHow.
  ///
  /// In en, this message translates to:
  /// **'The golden clock dresses up for the occasion. Catch it and hit (GOOD or better) to earn the reward.'**
  String get seasonHow;

  /// No description provided for @seasonHits.
  ///
  /// In en, this message translates to:
  /// **'Hits'**
  String get seasonHits;

  /// No description provided for @seasonReward.
  ///
  /// In en, this message translates to:
  /// **'Reward: +{amount} Ticks, the “{name}” theme for good and an achievement (+1%).'**
  String seasonReward(String amount, String name);

  /// No description provided for @seasonDone.
  ///
  /// In en, this message translates to:
  /// **'Done! Pick the “{name}” theme in Settings.'**
  String seasonDone(String name);

  /// No description provided for @seasonCompleted.
  ///
  /// In en, this message translates to:
  /// **'{name} complete! +{amount} Ticks'**
  String seasonCompleted(String name, String amount);

  /// No description provided for @seasonStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get seasonStart;

  /// No description provided for @ach_season.
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String ach_season(String name);

  /// No description provided for @ach_season_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete the “{name}” event'**
  String ach_season_desc(String name);

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get themeAuto;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeClassic;

  /// No description provided for @themeHint.
  ///
  /// In en, this message translates to:
  /// **'“Seasonal” follows the events. Themes from completed events are yours for good.'**
  String get themeHint;

  /// No description provided for @diagSeason.
  ///
  /// In en, this message translates to:
  /// **'Event preview'**
  String get diagSeason;

  /// No description provided for @diagSeasonNone.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get diagSeasonNone;

  /// No description provided for @perfectNow.
  ///
  /// In en, this message translates to:
  /// **'PERFECT now: +{amount}'**
  String perfectNow(String amount);

  /// No description provided for @perfectNowSeconds.
  ///
  /// In en, this message translates to:
  /// **'PERFECT now: +{amount} (≈ {seconds} s of clock income)'**
  String perfectNowSeconds(String amount, String seconds);

  /// No description provided for @jackpotPrice.
  ///
  /// In en, this message translates to:
  /// **'{target} = +{amount}'**
  String jackpotPrice(String target, String amount);

  /// No description provided for @generatorTotal.
  ///
  /// In en, this message translates to:
  /// **'{perSecond} in total'**
  String generatorTotal(String perSecond);

  /// No description provided for @generatorBonuses.
  ///
  /// In en, this message translates to:
  /// **'Bonuses'**
  String get generatorBonuses;

  /// No description provided for @generatorBonusLine.
  ///
  /// In en, this message translates to:
  /// **'{count} pcs · {name} · ×{mult}'**
  String generatorBonusLine(String count, String name, String mult);

  /// No description provided for @generatorSynergies.
  ///
  /// In en, this message translates to:
  /// **'Synergies'**
  String get generatorSynergies;

  /// No description provided for @generatorSynergyOn.
  ///
  /// In en, this message translates to:
  /// **'{name} ✓ active'**
  String generatorSynergyOn(String name);

  /// No description provided for @generatorSynergyEffect.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% for each {other}'**
  String generatorSynergyEffect(String pct, String other);

  /// No description provided for @generatorSynergyNeeds.
  ///
  /// In en, this message translates to:
  /// **'Turns on at {need} of both: {a} {aOwned}/{need}, {b} {bOwned}/{need}'**
  String generatorSynergyNeeds(
    String need,
    String a,
    String aOwned,
    String b,
    String bOwned,
  );

  /// No description provided for @season_fiveDay.
  ///
  /// In en, this message translates to:
  /// **'Five Day'**
  String get season_fiveDay;

  /// No description provided for @season_fiveDay_items.
  ///
  /// In en, this message translates to:
  /// **'Fives'**
  String get season_fiveDay_items;

  /// No description provided for @skill_power_info.
  ///
  /// In en, this message translates to:
  /// **'A hit pays a fixed number of Ticks: PERFECT 6, GREAT 3, GOOD 1. Each level adds 150% of that (PERFECT: 6 → 15 → 24…).'**
  String get skill_power_info;

  /// No description provided for @skill_fastForward_info.
  ///
  /// In en, this message translates to:
  /// **'Each level moves the stopwatch\'s start by about 0.13 s, up to 2.00 s at the top level. The stopwatch runs at normal speed and the target is still 5.00.'**
  String get skill_fastForward_info;

  /// No description provided for @skill_ticking_info.
  ///
  /// In en, this message translates to:
  /// **'From 4.00 to 5.00 you hear a tick every 0.1 s (with vibration if it\'s on).'**
  String get skill_ticking_info;

  /// No description provided for @skill_wideEye_info.
  ///
  /// In en, this message translates to:
  /// **'The GREAT (±30 ms) and GOOD (±50 ms) windows grow by about 5% a level, up to ×1.8 at the top level (±54 and ±90 ms). Works on clocks too.'**
  String get skill_wideEye_info;

  /// No description provided for @skill_combo_info.
  ///
  /// In en, this message translates to:
  /// **'Every hit without a miss raises the streak multiplier: PERFECT by 0.15, GREAT by 0.10, GOOD by 0.05. Without upgrades it stops at ×1.25; each level raises that cap by 0.10. It multiplies the whole payout for a hit, 5.00 and Echo included.'**
  String get skill_combo_info;

  /// No description provided for @skill_magnet_info.
  ///
  /// In en, this message translates to:
  /// **'The PERFECT window (±15 ms) grows by about 0.7 ms a level, up to ±25 ms. The 5.00 window (±10 ms) stays. Works on clocks too.'**
  String get skill_magnet_info;

  /// No description provided for @skill_echo_info.
  ///
  /// In en, this message translates to:
  /// **'A hit adds as many Ticks as your clocks make in the given time. Per level: PERFECT 0.2 s, GREAT about 0.11 s, GOOD about 0.03 s.'**
  String get skill_echo_info;

  /// No description provided for @skill_bulletTime_info.
  ///
  /// In en, this message translates to:
  /// **'The PERFECT, GREAT, GOOD and CLOSE windows grow up to ×2.5 at the top level (e.g. GOOD: ±50 → ±125 ms). The 5.00 window stays. Near the target the screen pulses and you hear a heartbeat. Doesn\'t work on clocks.'**
  String get skill_bulletTime_info;

  /// No description provided for @skill_luck_info.
  ///
  /// In en, this message translates to:
  /// **'At each level 2 hits in 100 jump a tier: GREAT → PERFECT, GOOD → GREAT. A PERFECT never becomes a 5.00.'**
  String get skill_luck_info;

  /// No description provided for @skill_shield_info.
  ///
  /// In en, this message translates to:
  /// **'Each level is one charge. A miss uses a charge and the streak stays. Used charges come back one per 10 streak steps.'**
  String get skill_shield_info;

  /// No description provided for @skill_goldenTouch_info.
  ///
  /// In en, this message translates to:
  /// **'A Golden Second appears every 10 minutes on average. Each level cuts that by 30 s and makes its effects (Frenzy, Lucky, Hot hand) 5% stronger.'**
  String get skill_goldenTouch_info;

  /// No description provided for @master_grandpa_5.
  ///
  /// In en, this message translates to:
  /// **'Retired Watchmaker'**
  String get master_grandpa_5;

  /// No description provided for @master_grandpa_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Fixes the neighbours\' watches. Free, with a lecture.'**
  String get master_grandpa_5_desc;

  /// No description provided for @master_grandpa_10.
  ///
  /// In en, this message translates to:
  /// **'Grandpa Knows Best'**
  String get master_grandpa_10;

  /// No description provided for @master_grandpa_10_desc.
  ///
  /// In en, this message translates to:
  /// **'And he\'s right. Sadly.'**
  String get master_grandpa_10_desc;

  /// No description provided for @master_grandma_5.
  ///
  /// In en, this message translates to:
  /// **'The Perfect Egg'**
  String get master_grandma_5;

  /// No description provided for @master_grandma_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Not a second too long. Not one.'**
  String get master_grandma_5_desc;

  /// No description provided for @master_grandma_10.
  ///
  /// In en, this message translates to:
  /// **'Turbo Grandma'**
  String get master_grandma_10;

  /// No description provided for @master_grandma_10_desc.
  ///
  /// In en, this message translates to:
  /// **'The egg timer is scared of her.'**
  String get master_grandma_10_desc;

  /// No description provided for @master_cuckoo_5.
  ///
  /// In en, this message translates to:
  /// **'Cuckoo with a Degree'**
  String get master_cuckoo_5;

  /// No description provided for @master_cuckoo_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Cuckoos on time. Insists on being called Doctor.'**
  String get master_cuckoo_5_desc;

  /// No description provided for @master_cuckoo_10.
  ///
  /// In en, this message translates to:
  /// **'Celebrity Cuckoo'**
  String get master_cuckoo_10;

  /// No description provided for @master_cuckoo_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Leaves the little house only for interviews.'**
  String get master_cuckoo_10_desc;

  /// No description provided for @master_metronome_5.
  ///
  /// In en, this message translates to:
  /// **'Tick Virtuoso'**
  String get master_metronome_5;

  /// No description provided for @master_metronome_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Tick. Tock. Applause.'**
  String get master_metronome_5_desc;

  /// No description provided for @master_metronome_10.
  ///
  /// In en, this message translates to:
  /// **'Philharmonic Metronome'**
  String get master_metronome_10;

  /// No description provided for @master_metronome_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Conducts the conductor.'**
  String get master_metronome_10_desc;

  /// No description provided for @master_watchmaker_5.
  ///
  /// In en, this message translates to:
  /// **'Golden Loupe'**
  String get master_watchmaker_5;

  /// No description provided for @master_watchmaker_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Sees atoms. And the dust on them.'**
  String get master_watchmaker_5_desc;

  /// No description provided for @master_watchmaker_10.
  ///
  /// In en, this message translates to:
  /// **'Guild Master'**
  String get master_watchmaker_10;

  /// No description provided for @master_watchmaker_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Even sundials come to him for advice.'**
  String get master_watchmaker_10_desc;

  /// No description provided for @master_sprintJudge_5.
  ///
  /// In en, this message translates to:
  /// **'Eagle-eyed Judge'**
  String get master_sprintJudge_5;

  /// No description provided for @master_sprintJudge_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Spots a false start before the runner thinks of it.'**
  String get master_sprintJudge_5_desc;

  /// No description provided for @master_sprintJudge_10.
  ///
  /// In en, this message translates to:
  /// **'Olympic Judge'**
  String get master_sprintJudge_10;

  /// No description provided for @master_sprintJudge_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Gold-plated whistle. Patience not included.'**
  String get master_sprintJudge_10_desc;

  /// No description provided for @master_stationClock_5.
  ///
  /// In en, this message translates to:
  /// **'Train on Time'**
  String get master_stationClock_5;

  /// No description provided for @master_stationClock_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Passengers don\'t believe it. They take photos.'**
  String get master_stationClock_5_desc;

  /// No description provided for @master_stationClock_10.
  ///
  /// In en, this message translates to:
  /// **'Zero-delay Station'**
  String get master_stationClock_10;

  /// No description provided for @master_stationClock_10_desc.
  ///
  /// In en, this message translates to:
  /// **'\"Subject to change\" is now in a museum.'**
  String get master_stationClock_10_desc;

  /// No description provided for @master_quartz_5.
  ///
  /// In en, this message translates to:
  /// **'Flawless Crystal'**
  String get master_quartz_5;

  /// No description provided for @master_quartz_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Vibrates exactly 32,768 times. We checked.'**
  String get master_quartz_5_desc;

  /// No description provided for @master_quartz_10.
  ///
  /// In en, this message translates to:
  /// **'Royal Quartz'**
  String get master_quartz_10;

  /// No description provided for @master_quartz_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Worn at court instead of a crown.'**
  String get master_quartz_10_desc;

  /// No description provided for @master_atomic_5.
  ///
  /// In en, this message translates to:
  /// **'Atom of Calm'**
  String get master_atomic_5;

  /// No description provided for @master_atomic_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Electrons tiptoe around it.'**
  String get master_atomic_5_desc;

  /// No description provided for @master_atomic_10.
  ///
  /// In en, this message translates to:
  /// **'The Standard Second'**
  String get master_atomic_10;

  /// No description provided for @master_atomic_10_desc.
  ///
  /// In en, this message translates to:
  /// **'A second lasts as long as it says.'**
  String get master_atomic_10_desc;

  /// No description provided for @master_gps_5.
  ///
  /// In en, this message translates to:
  /// **'Never-lost Satellite'**
  String get master_gps_5;

  /// No description provided for @master_gps_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Never says \"make a U-turn when possible\".'**
  String get master_gps_5_desc;

  /// No description provided for @master_gps_10.
  ///
  /// In en, this message translates to:
  /// **'Lord of the Orbit'**
  String get master_gps_10;

  /// No description provided for @master_gps_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Other satellites set themselves by it.'**
  String get master_gps_10_desc;

  /// No description provided for @master_pulsar_5.
  ///
  /// In en, this message translates to:
  /// **'Pulsar with Rhythm'**
  String get master_pulsar_5;

  /// No description provided for @master_pulsar_5_desc.
  ///
  /// In en, this message translates to:
  /// **'The universe taps its foot along.'**
  String get master_pulsar_5_desc;

  /// No description provided for @master_pulsar_10.
  ///
  /// In en, this message translates to:
  /// **'Lighthouse of the Galaxy'**
  String get master_pulsar_10;

  /// No description provided for @master_pulsar_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Alien ships set their watches by it.'**
  String get master_pulsar_10_desc;

  /// No description provided for @master_timeMachine_5.
  ///
  /// In en, this message translates to:
  /// **'Return Ticket'**
  String get master_timeMachine_5;

  /// No description provided for @master_timeMachine_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Back before it leaves. Never late.'**
  String get master_timeMachine_5_desc;

  /// No description provided for @master_timeMachine_10.
  ///
  /// In en, this message translates to:
  /// **'Perfect Loop'**
  String get master_timeMachine_10;

  /// No description provided for @master_timeMachine_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Met itself. Both hit 5.00.'**
  String get master_timeMachine_10_desc;

  /// No description provided for @master_schrodinger_5.
  ///
  /// In en, this message translates to:
  /// **'Observed Cat'**
  String get master_schrodinger_5;

  /// No description provided for @master_schrodinger_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Hits when you look. When you don\'t, too.'**
  String get master_schrodinger_5_desc;

  /// No description provided for @master_schrodinger_10.
  ///
  /// In en, this message translates to:
  /// **'Cat in Both Boxes'**
  String get master_schrodinger_10;

  /// No description provided for @master_schrodinger_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Asleep and on target at once. Purrs in superposition.'**
  String get master_schrodinger_10_desc;

  /// No description provided for @master_chronos_5.
  ///
  /// In en, this message translates to:
  /// **'Chronos on Holiday'**
  String get master_chronos_5;

  /// No description provided for @master_chronos_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Time flows on its own, and still on the dot.'**
  String get master_chronos_5_desc;

  /// No description provided for @master_chronos_10.
  ///
  /// In en, this message translates to:
  /// **'Lord of All Seconds'**
  String get master_chronos_10;

  /// No description provided for @master_chronos_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Even the second that just passed was his.'**
  String get master_chronos_10_desc;

  /// No description provided for @dial_classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get dial_classic;

  /// No description provided for @dial_classic_desc.
  ///
  /// In en, this message translates to:
  /// **'White, clean, reliable.'**
  String get dial_classic_desc;

  /// No description provided for @dial_wood.
  ///
  /// In en, this message translates to:
  /// **'Woodgrain'**
  String get dial_wood;

  /// No description provided for @dial_wood_desc.
  ///
  /// In en, this message translates to:
  /// **'Smells like Grandpa\'s workshop.'**
  String get dial_wood_desc;

  /// No description provided for @dial_porcelain.
  ///
  /// In en, this message translates to:
  /// **'Grandma\'s Porcelain'**
  String get dial_porcelain;

  /// No description provided for @dial_porcelain_desc.
  ///
  /// In en, this message translates to:
  /// **'From the good china. Don\'t drop it.'**
  String get dial_porcelain_desc;

  /// No description provided for @dial_brass.
  ///
  /// In en, this message translates to:
  /// **'Brass'**
  String get dial_brass;

  /// No description provided for @dial_brass_desc.
  ///
  /// In en, this message translates to:
  /// **'Shines like a town hall door handle.'**
  String get dial_brass_desc;

  /// No description provided for @dial_station.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get dial_station;

  /// No description provided for @dial_station_desc.
  ///
  /// In en, this message translates to:
  /// **'Big, so you can see the delay from far away.'**
  String get dial_station_desc;

  /// No description provided for @dial_swiss.
  ///
  /// In en, this message translates to:
  /// **'Swiss'**
  String get dial_swiss;

  /// No description provided for @dial_swiss_desc.
  ///
  /// In en, this message translates to:
  /// **'Red, precise and a little smug.'**
  String get dial_swiss_desc;

  /// No description provided for @dial_quartz.
  ///
  /// In en, this message translates to:
  /// **'Quartz LCD'**
  String get dial_quartz;

  /// No description provided for @dial_quartz_desc.
  ///
  /// In en, this message translates to:
  /// **'Green digits, like an 80s alarm clock.'**
  String get dial_quartz_desc;

  /// No description provided for @dial_atomic.
  ///
  /// In en, this message translates to:
  /// **'Atomic'**
  String get dial_atomic;

  /// No description provided for @dial_atomic_desc.
  ///
  /// In en, this message translates to:
  /// **'Glows faintly blue. Apparently that\'s normal.'**
  String get dial_atomic_desc;

  /// No description provided for @dial_neon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get dial_neon;

  /// No description provided for @dial_neon_desc.
  ///
  /// In en, this message translates to:
  /// **'For playing after midnight.'**
  String get dial_neon_desc;

  /// No description provided for @dial_cosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic'**
  String get dial_cosmic;

  /// No description provided for @dial_cosmic_desc.
  ///
  /// In en, this message translates to:
  /// **'Stars behind, seconds in front.'**
  String get dial_cosmic_desc;

  /// No description provided for @dial_golden.
  ///
  /// In en, this message translates to:
  /// **'Golden'**
  String get dial_golden;

  /// No description provided for @dial_golden_desc.
  ///
  /// In en, this message translates to:
  /// **'Solid gold. Well, almost.'**
  String get dial_golden_desc;

  /// No description provided for @dial_rift.
  ///
  /// In en, this message translates to:
  /// **'Spacetime Rift'**
  String get dial_rift;

  /// No description provided for @dial_rift_desc.
  ///
  /// In en, this message translates to:
  /// **'Through the crack you can see yesterday\'s 5.00.'**
  String get dial_rift_desc;

  /// No description provided for @springWound.
  ///
  /// In en, this message translates to:
  /// **'Mainspring +{minutes} min'**
  String springWound(String minutes);

  /// No description provided for @springsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mainsprings'**
  String get springsTitle;

  /// No description provided for @springsBadge.
  ///
  /// In en, this message translates to:
  /// **'Mainsprings: {count}'**
  String springsBadge(String count);

  /// No description provided for @springsIntro.
  ///
  /// In en, this message translates to:
  /// **'A Mainspring winds itself: one a day, even while you\'re away. Every exact 5.00 winds it faster. Spend Mainsprings on clock mastery: every tier multiplies that clock\'s income by {mult}, for good — nothing takes it back.'**
  String springsIntro(String mult);

  /// No description provided for @springsNext.
  ///
  /// In en, this message translates to:
  /// **'Next one in {time}'**
  String springsNext(String time);

  /// No description provided for @springsFull.
  ///
  /// In en, this message translates to:
  /// **'Storage full ({max}). Spend some to keep winding.'**
  String springsFull(String max);

  /// No description provided for @springsReserveTitle.
  ///
  /// In en, this message translates to:
  /// **'Winding reserve'**
  String get springsReserveTitle;

  /// No description provided for @springsReserve.
  ///
  /// In en, this message translates to:
  /// **'{left} of {max}'**
  String springsReserve(String left, String max);

  /// No description provided for @springsReserveHow.
  ///
  /// In en, this message translates to:
  /// **'Every exact 5.00 winds {time} out of the reserve. The reserve comes back by itself in {refill}.'**
  String springsReserveHow(String time, String refill);

  /// No description provided for @springsReserveFirst.
  ///
  /// In en, this message translates to:
  /// **'Your next exact 5.00 winds a whole {time}: the first one after a break of {after}.'**
  String springsReserveFirst(String time, String after);

  /// No description provided for @springsReserveEmpty.
  ///
  /// In en, this message translates to:
  /// **'The reserve is empty: hits wind nothing now. Full again in {time}.'**
  String springsReserveEmpty(String time);

  /// No description provided for @springEmpty.
  ///
  /// In en, this message translates to:
  /// **'Winding reserve empty'**
  String get springEmpty;

  /// No description provided for @adSpring.
  ///
  /// In en, this message translates to:
  /// **'▶ Refill for an ad'**
  String get adSpring;

  /// No description provided for @adSpringLeft.
  ///
  /// In en, this message translates to:
  /// **'Ads today: {left} of {max}'**
  String adSpringLeft(int left, int max);

  /// No description provided for @adDoneSpring.
  ///
  /// In en, this message translates to:
  /// **'The reserve is full — hit 5.00!'**
  String get adDoneSpring;

  /// No description provided for @springsNoClocks.
  ///
  /// In en, this message translates to:
  /// **'Buy a clock to raise its mastery.'**
  String get springsNoClocks;

  /// No description provided for @clockLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Clock mastery'**
  String get clockLevelTitle;

  /// No description provided for @clockLevelLine.
  ///
  /// In en, this message translates to:
  /// **'Tier {level}/{max} · {mult}'**
  String clockLevelLine(String level, String max, String mult);

  /// No description provided for @clockLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up · {cost}'**
  String clockLevelUp(String cost);

  /// No description provided for @clockLevelMax.
  ///
  /// In en, this message translates to:
  /// **'Full mastery'**
  String get clockLevelMax;

  /// No description provided for @clockLevelTitleAt.
  ///
  /// In en, this message translates to:
  /// **'Tier {level}: {title}'**
  String clockLevelTitleAt(String level, String title);

  /// No description provided for @clockLevelLocked.
  ///
  /// In en, this message translates to:
  /// **'Mainsprings arrive with the first paradox.'**
  String get clockLevelLocked;

  /// No description provided for @ach_mastery_desc.
  ///
  /// In en, this message translates to:
  /// **'{generator}: mastery tier {level}'**
  String ach_mastery_desc(String generator, String level);

  /// No description provided for @dialTitle.
  ///
  /// In en, this message translates to:
  /// **'Dial face'**
  String get dialTitle;

  /// No description provided for @dialHint.
  ///
  /// In en, this message translates to:
  /// **'The first faces unlock as you earn Ticks. The last six are trophies: one for each Time Loop you finish.'**
  String get dialHint;

  /// No description provided for @dialLocked.
  ///
  /// In en, this message translates to:
  /// **'Earn {amount}'**
  String dialLocked(String amount);

  /// No description provided for @dialToast.
  ///
  /// In en, this message translates to:
  /// **'New dial face'**
  String get dialToast;

  /// No description provided for @dialProgress.
  ///
  /// In en, this message translates to:
  /// **'Earned in total: {have} of {need}'**
  String dialProgress(String have, String need);

  /// No description provided for @updateReady.
  ///
  /// In en, this message translates to:
  /// **'A new version is ready'**
  String get updateReady;

  /// No description provided for @updateRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get updateRestart;

  /// No description provided for @help_springs_t.
  ///
  /// In en, this message translates to:
  /// **'Mainsprings and clock mastery'**
  String get help_springs_t;

  /// No description provided for @help_springs.
  ///
  /// In en, this message translates to:
  /// **'After your first rewind a spiral appears at the top — your Mainsprings. They wind themselves: one a day, even while you\'re away, and every exact 5.00 winds 15 more minutes out of a reserve. The reserve holds 2 hours and comes back by itself in 4, so it pays to return a few times a day. The first exact 5.00 after an hour\'s break winds a whole hour. You can hold up to 10 Mainsprings. Tap the spiral to raise a clock\'s mastery: tier 1 costs 1 Mainspring, tier 2 costs 2, up to tier 5. Each tier multiplies that clock\'s income by 1.5, for good: it survives the rewind and a new Time Loop. At tiers 3 and 5 a clock earns a master title.'**
  String get help_springs;

  /// No description provided for @help_dials_t.
  ///
  /// In en, this message translates to:
  /// **'Dial faces'**
  String get help_dials_t;

  /// No description provided for @help_dials.
  ///
  /// In en, this message translates to:
  /// **'The more Ticks you earn, the more dial faces you unlock; the last six are trophies for finished Time Loops. Pick one with the dial button at the top, next to the stats. They only change the look, not the results.'**
  String get help_dials;

  /// No description provided for @springsRefund.
  ///
  /// In en, this message translates to:
  /// **'Clock levels are now 5 mastery tiers, each worth more. The {count} Mainsprings you had spent are back — spend them again.'**
  String springsRefund(int count);

  /// No description provided for @dialLockedSeal.
  ///
  /// In en, this message translates to:
  /// **'Loop trophy'**
  String get dialLockedSeal;

  /// No description provided for @loopNumber.
  ///
  /// In en, this message translates to:
  /// **'Loop {n}'**
  String loopNumber(int n);

  /// No description provided for @loopTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Loop'**
  String get loopTitle;

  /// No description provided for @loopGoal.
  ///
  /// In en, this message translates to:
  /// **'Loop goal: buy Chronos'**
  String get loopGoal;

  /// No description provided for @loopGoalDone.
  ///
  /// In en, this message translates to:
  /// **'Goal reached: Chronos is yours'**
  String get loopGoalDone;

  /// No description provided for @loopNoRule.
  ///
  /// In en, this message translates to:
  /// **'No changed rule'**
  String get loopNoRule;

  /// No description provided for @loopRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Chronos\' rule'**
  String get loopRuleLabel;

  /// No description provided for @loopEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Time is beaten!'**
  String get loopEndTitle;

  /// No description provided for @loopEndStats.
  ///
  /// In en, this message translates to:
  /// **'Play time: {time} · Paradoxes: {count}'**
  String loopEndStats(String time, int count);

  /// No description provided for @loopRewardChapter.
  ///
  /// In en, this message translates to:
  /// **'A new chapter of the Chronicle'**
  String get loopRewardChapter;

  /// No description provided for @loopRewardSeal.
  ///
  /// In en, this message translates to:
  /// **'Seal won — it holds for good'**
  String get loopRewardSeal;

  /// No description provided for @loopRewardDial.
  ///
  /// In en, this message translates to:
  /// **'Dial face: {name}'**
  String loopRewardDial(String name);

  /// No description provided for @loopNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Next loop'**
  String get loopNextTitle;

  /// No description provided for @loopNextSeal.
  ///
  /// In en, this message translates to:
  /// **'Seal for beating it: ???'**
  String get loopNextSeal;

  /// No description provided for @loopNextFree.
  ///
  /// In en, this message translates to:
  /// **'The story is told. From now on you pick the rules of every loop yourself — in the Chronicle.'**
  String get loopNextFree;

  /// No description provided for @loopStay.
  ///
  /// In en, this message translates to:
  /// **'Stay a while'**
  String get loopStay;

  /// No description provided for @loopStayHint.
  ///
  /// In en, this message translates to:
  /// **'Every bonus of Chronos in this loop pays +1 Mainspring ({left} left).'**
  String loopStayHint(int left);

  /// No description provided for @loopStart.
  ///
  /// In en, this message translates to:
  /// **'New loop'**
  String get loopStart;

  /// No description provided for @loopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new loop?'**
  String get loopConfirmTitle;

  /// No description provided for @loopConfirmResets.
  ///
  /// In en, this message translates to:
  /// **'Starts from zero: Ticks, clocks, skills, Chronons, shards and perks.'**
  String get loopConfirmResets;

  /// No description provided for @loopConfirmKeeps.
  ///
  /// In en, this message translates to:
  /// **'Stays: Mainsprings, clock mastery, seals, achievements, dial faces and statistics.'**
  String get loopConfirmKeeps;

  /// No description provided for @loopConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Start from zero'**
  String get loopConfirmYes;

  /// No description provided for @loopConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get loopConfirmNo;

  /// No description provided for @loopBonusToast.
  ///
  /// In en, this message translates to:
  /// **'Chronos bonus'**
  String get loopBonusToast;

  /// No description provided for @loopBonusToastBody.
  ///
  /// In en, this message translates to:
  /// **'Mainsprings: +{count} for the next loops'**
  String loopBonusToastBody(int count);

  /// No description provided for @chronicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Chronicle'**
  String get chronicleTitle;

  /// No description provided for @chronicleOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the Chronicle'**
  String get chronicleOpen;

  /// No description provided for @chronicleChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chronicleChapters;

  /// No description provided for @chronicleSeals.
  ///
  /// In en, this message translates to:
  /// **'Seals'**
  String get chronicleSeals;

  /// No description provided for @chronicleChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter {n}'**
  String chronicleChapter(int n);

  /// No description provided for @chronicleChapterLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish loop {n}'**
  String chronicleChapterLocked(int n);

  /// No description provided for @chronicleSealLocked.
  ///
  /// In en, this message translates to:
  /// **'Beat this rule to win its seal'**
  String get chronicleSealLocked;

  /// No description provided for @chronicleBest.
  ///
  /// In en, this message translates to:
  /// **'Best: {time} of play'**
  String chronicleBest(String time);

  /// No description provided for @chroniclePick.
  ///
  /// In en, this message translates to:
  /// **'Rules of the next loop'**
  String get chroniclePick;

  /// No description provided for @chroniclePickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick any, several at once, or none.'**
  String get chroniclePickHint;

  /// No description provided for @chronicleLoopTime.
  ///
  /// In en, this message translates to:
  /// **'In this loop: {time} of play, {count} paradoxes'**
  String chronicleLoopTime(String time, int count);

  /// No description provided for @goalLoopBonus.
  ///
  /// In en, this message translates to:
  /// **'Goal: {name} {have}/{need} → +1 Mainspring'**
  String goalLoopBonus(String name, String have, String need);

  /// No description provided for @adBlockedRule.
  ///
  /// In en, this message translates to:
  /// **'loop rule'**
  String get adBlockedRule;

  /// No description provided for @statLoop.
  ///
  /// In en, this message translates to:
  /// **'Time Loop'**
  String get statLoop;

  /// No description provided for @help_loop_t.
  ///
  /// In en, this message translates to:
  /// **'Time Loop and the Chronicle'**
  String get help_loop_t;

  /// No description provided for @help_loop.
  ///
  /// In en, this message translates to:
  /// **'The goal of the game is to buy Chronos, the last clock. When you do, the loop is finished: you get a chapter of the story and may start a new loop. A new loop starts everything from zero — Chronons and perks too — and Chronos changes one rule in it. Your Mainsprings, clock mastery, achievements and dial faces stay, so every loop goes faster. Finishing a loop with a changed rule wins its seal: a small bonus that holds for good, and a dial face. Every bonus of Chronos you reach before leaving pays +1 Mainspring. Seven loops tell the whole story; after that you pick the rules yourself. Everything is in the Chronicle, on the Time paradox screen.'**
  String get help_loop;

  /// No description provided for @rule_blindfold.
  ///
  /// In en, this message translates to:
  /// **'Broken Stopwatch'**
  String get rule_blindfold;

  /// No description provided for @rule_blindfold_desc.
  ///
  /// In en, this message translates to:
  /// **'Blind mode is always on: the digits vanish for the last second. It pays as usual.'**
  String get rule_blindfold_desc;

  /// No description provided for @rule_blindfold_quote.
  ///
  /// In en, this message translates to:
  /// **'“I\'m taking your digits. Let\'s see what you can do without peeking.”'**
  String get rule_blindfold_quote;

  /// No description provided for @seal_blindfold.
  ///
  /// In en, this message translates to:
  /// **'A Feel for It'**
  String get seal_blindfold;

  /// No description provided for @seal_blindfold_desc.
  ///
  /// In en, this message translates to:
  /// **'Blind mode pays one more (×4, ×5 with Daredevil).'**
  String get seal_blindfold_desc;

  /// No description provided for @rule_inflation.
  ///
  /// In en, this message translates to:
  /// **'Price Hike'**
  String get rule_inflation;

  /// No description provided for @rule_inflation_desc.
  ///
  /// In en, this message translates to:
  /// **'Each clock raises the price of the next one by 20% instead of 15%.'**
  String get rule_inflation_desc;

  /// No description provided for @rule_inflation_quote.
  ///
  /// In en, this message translates to:
  /// **'“Time is money. And money just lost its value.”'**
  String get rule_inflation_quote;

  /// No description provided for @seal_inflation.
  ///
  /// In en, this message translates to:
  /// **'Regular Customer'**
  String get seal_inflation;

  /// No description provided for @seal_inflation_desc.
  ///
  /// In en, this message translates to:
  /// **'The first 10 of every clock cost half.'**
  String get seal_inflation_desc;

  /// No description provided for @rule_noGold.
  ///
  /// In en, this message translates to:
  /// **'Cloudy Day'**
  String get rule_noGold;

  /// No description provided for @rule_noGold_desc.
  ///
  /// In en, this message translates to:
  /// **'No Golden Second flies in (seasonal events still do).'**
  String get rule_noGold_desc;

  /// No description provided for @rule_noGold_quote.
  ///
  /// In en, this message translates to:
  /// **'“I\'m covering the sun. No golden seconds.”'**
  String get rule_noGold_quote;

  /// No description provided for @seal_noGold.
  ///
  /// In en, this message translates to:
  /// **'Ray of Sun'**
  String get seal_noGold;

  /// No description provided for @seal_noGold_desc.
  ///
  /// In en, this message translates to:
  /// **'Back after an hour or more: a Golden Second flies in within 30 seconds.'**
  String get seal_noGold_desc;

  /// No description provided for @rule_shortFuse.
  ///
  /// In en, this message translates to:
  /// **'Short Fuse'**
  String get rule_shortFuse;

  /// No description provided for @rule_shortFuse_desc.
  ///
  /// In en, this message translates to:
  /// **'The combo counts up to 5 at most, and there is no Shield.'**
  String get rule_shortFuse_desc;

  /// No description provided for @rule_shortFuse_quote.
  ///
  /// In en, this message translates to:
  /// **'“No more long streaks. And hand over that Shield.”'**
  String get rule_shortFuse_quote;

  /// No description provided for @seal_shortFuse.
  ///
  /// In en, this message translates to:
  /// **'Spare Shield'**
  String get seal_shortFuse;

  /// No description provided for @seal_shortFuse_desc.
  ///
  /// In en, this message translates to:
  /// **'+1 Shield charge from the start of every run.'**
  String get seal_shortFuse_desc;

  /// No description provided for @rule_precision.
  ///
  /// In en, this message translates to:
  /// **'Swiss Precision'**
  String get rule_precision;

  /// No description provided for @rule_precision_desc.
  ///
  /// In en, this message translates to:
  /// **'A GOOD pays you nothing. Only GREAT and PERFECT count.'**
  String get rule_precision_desc;

  /// No description provided for @rule_precision_quote.
  ///
  /// In en, this message translates to:
  /// **'“From now on only a proper hit counts.”'**
  String get rule_precision_quote;

  /// No description provided for @seal_precision.
  ///
  /// In en, this message translates to:
  /// **'Steady Hand'**
  String get seal_precision;

  /// No description provided for @seal_precision_desc.
  ///
  /// In en, this message translates to:
  /// **'The PERFECT window is 0.001 s wider.'**
  String get seal_precision_desc;

  /// No description provided for @rule_insomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get rule_insomnia;

  /// No description provided for @rule_insomnia_desc.
  ///
  /// In en, this message translates to:
  /// **'While you\'re away the clocks earn only 25%.'**
  String get rule_insomnia_desc;

  /// No description provided for @rule_insomnia_quote.
  ///
  /// In en, this message translates to:
  /// **'“Those who sleep run late. Clocks too.”'**
  String get rule_insomnia_quote;

  /// No description provided for @seal_insomnia.
  ///
  /// In en, this message translates to:
  /// **'Sound Sleep'**
  String get seal_insomnia;

  /// No description provided for @seal_insomnia_desc.
  ///
  /// In en, this message translates to:
  /// **'Offline income counts for 12 more hours.'**
  String get seal_insomnia_desc;

  /// No description provided for @chapter_1_t.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get chapter_1_t;

  /// No description provided for @chapter_1.
  ///
  /// In en, this message translates to:
  /// **'“You bought me? ME? The god of time, for Ticks?” Chronos straightened his toga and counted to five. “Fine. I\'m rewinding everything. And I\'m taking your digits.”\n“Don\'t mind him,” Grandpa muttered. “He\'s always like this before five.”'**
  String get chapter_1;

  /// No description provided for @chapter_2_t.
  ///
  /// In en, this message translates to:
  /// **'Blind'**
  String get chapter_2_t;

  /// No description provided for @chapter_2.
  ///
  /// In en, this message translates to:
  /// **'You hit 5.00 without looking. Chronos pretended not to see.\n“Luck,” he grumbled, and handed over a seal. “Let\'s see if you can afford time when time gets expensive.”\nGrandpa only shrugged: in his day a second cost a penny.'**
  String get chapter_2;

  /// No description provided for @chapter_3_t.
  ///
  /// In en, this message translates to:
  /// **'Price Hike'**
  String get chapter_3_t;

  /// No description provided for @chapter_3.
  ///
  /// In en, this message translates to:
  /// **'“Everything got dearer and you still bought me,” Chronos sighed.\n“Grandma says it\'s the eggs,” said Grandpa.\nChronos flinched at the word “Grandma” and quickly changed the subject: “I\'m covering the sun. No golden seconds.”'**
  String get chapter_3;

  /// No description provided for @chapter_4_t.
  ///
  /// In en, this message translates to:
  /// **'Overcast'**
  String get chapter_4_t;

  /// No description provided for @chapter_4.
  ///
  /// In en, this message translates to:
  /// **'You managed without gold, too. Chronos kept glancing at the watch he doesn\'t wear.\n“In a hurry?” asked Grandpa.\n“Me? Never. I have all the time in the world.” And, more quietly: “Just not after five.”'**
  String get chapter_4;

  /// No description provided for @chapter_5_t.
  ///
  /// In en, this message translates to:
  /// **'Short Fuse'**
  String get chapter_5_t;

  /// No description provided for @chapter_5.
  ///
  /// In en, this message translates to:
  /// **'“No streaks, no Shield, and you\'re still here.” For the first time Chronos smiled. “I\'ll tell you something. I was late once in my life. Once!”\n“For what?”\n“None of your business. From now on only perfect counts.”'**
  String get chapter_5;

  /// No description provided for @chapter_6_t.
  ///
  /// In en, this message translates to:
  /// **'To the Second'**
  String get chapter_6_t;

  /// No description provided for @chapter_6.
  ///
  /// In en, this message translates to:
  /// **'“He was late for tea,” Grandpa let slip. “At Grandma\'s. At five. We\'d already eaten the cheesecake.”\nChronos turned red. “One loop. The last one. And no sleeping: those who sleep run late.”'**
  String get chapter_6;

  /// No description provided for @chapter_7_t.
  ///
  /// In en, this message translates to:
  /// **'Five Sharp'**
  String get chapter_7_t;

  /// No description provided for @chapter_7.
  ///
  /// In en, this message translates to:
  /// **'5.00 sharp. Chronos stands at Grandma\'s door, on time for the first time in ages.\n“Come in, watchmaker,” he says to you. “The cheesecake is for two, but Grandma always cuts it in five. From today you set the rules. I\'m off to tea.”'**
  String get chapter_7;
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
