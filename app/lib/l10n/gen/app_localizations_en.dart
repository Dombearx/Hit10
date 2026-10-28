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
}
