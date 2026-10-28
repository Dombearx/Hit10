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
