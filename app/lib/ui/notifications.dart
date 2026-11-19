/// Local reminders when the player leaves (R-OFF-4, R-POW-1…3): at most
/// two per absence, chosen by [NotificationPlan].
library;

import '../engine/notification_plan.dart';

export 'notifications_stub.dart'
    if (dart.library.io) 'notifications_device.dart';

/// One reminder with its words.
class Reminder {
  const Reminder(this.kind, this.at, this.title, this.body);
  final NotificationKind kind;
  final DateTime at;
  final String title;
  final String body;
}

/// The reminders' words in the player's language.
class ReminderTexts {
  const ReminderTexts({
    required this.offlineTitle,
    required this.offlineBody,
    required this.dailyTitle,
    required this.dailyBody,
    required this.reserveTitle,
    required this.reserveBody,
  });

  /// [amount] is already formatted.
  final String Function(String amount) offlineTitle;
  final String offlineBody;
  final String Function(int day, int days) dailyTitle;
  final String dailyBody;
  final String reserveTitle;

  /// [first]: what the first exact hit winds, formatted ("1 h").
  final String Function(String time) reserveBody;
}

abstract interface class OfflineNotifications {
  /// Asks the OS for permission (Android 13+); true if granted.
  Future<bool> requestPermission();

  /// Replaces every pending reminder with [reminders].
  Future<void> schedule(List<Reminder> reminders);

  /// Cancels every pending reminder (the player is back).
  Future<void> cancel();
}

class NoNotifications implements OfflineNotifications {
  const NoNotifications();
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule(List<Reminder> reminders) async {}
  @override
  Future<void> cancel() async {}
}

/// Keeps what was scheduled, for tests.
class RecordingNotifications implements OfflineNotifications {
  List<Reminder> scheduled = [];
  int cancels = 0;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule(List<Reminder> reminders) async =>
      scheduled = List.of(reminders);
  @override
  Future<void> cancel() async {
    cancels++;
    scheduled = [];
  }
}
