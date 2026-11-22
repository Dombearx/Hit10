import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/ui/notifications.dart';

Balance loadBalance() =>
    Balance.fromJsonString(File('assets/balance.json').readAsStringSync());

/// Reminder texts for tests: the kind and the numbers, no language.
final testReminderTexts = ReminderTexts(
  offlineTitle: (a) => 'offline $a',
  offlineBody: 'offline body',
  dailyTitle: (d, n) => 'daily $d/$n',
  dailyBody: 'daily body',
  reserveTitle: 'reserve',
  reserveBody: (f) => 'reserve $f',
);

/// The rare story scenes of the first loop, all seen: for tests about
/// something else, so a scene's window does not cover the screen.
const storyScenesSeen = [
  'story_atomic',
  'story_paradox',
  'story_timeMachine',
  'story_altar',
];
