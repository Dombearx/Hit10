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
