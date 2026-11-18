/// Which reminders to schedule when the player leaves (docs/02 R-OFF-4,
/// R-POW-1…3). Few and worth reading: each says something the player can
/// act on, never at night, never two close together.
library;

/// A reminder the game can send, in order of importance.
enum NotificationKind {
  /// The clocks reached the offline limit: past this, waiting earns
  /// nothing (R-OFF-4).
  offlineFull,

  /// Today's daily bonus is waiting and the streak is at stake (R-POW-2).
  dailyBonus,

  /// The winding reserve is full again: exact 5.00s wind Mainsprings, the
  /// first one by a whole hour (R-POW-1).
  reserveFull,
}

class PlannedNotification {
  const PlannedNotification(this.kind, this.at);
  final NotificationKind kind;
  final DateTime at;

  @override
  String toString() => '$kind @ $at';
}

abstract final class NotificationPlan {
  /// At most this many reminders per absence.
  static const maxPerAbsence = 2;

  /// Two reminders are at least this far apart.
  static const minGap = Duration(hours: 3);

  /// Quiet hours, local time: a reminder due then waits for the morning.
  static const quietFrom = 22;
  static const quietUntil = 9;

  /// Hour of the daily-bonus reminder, local time.
  static const dailyHour = 18;

  /// The reminders to schedule from [candidates] (local times): moved out
  /// of the quiet hours, the more important first, then by time, keeping
  /// [minGap] and [maxPerAbsence]. Times before [now] are dropped.
  static List<PlannedNotification> choose(
    DateTime now,
    Map<NotificationKind, DateTime> candidates,
  ) {
    final moved = [
      for (final e in candidates.entries)
        if (e.value.isAfter(now)) PlannedNotification(e.key, awake(e.value)),
    ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
    final chosen = <PlannedNotification>[];
    for (final p in moved) {
      if (chosen.length >= maxPerAbsence) break;
      final clash = chosen.any((q) => p.at.difference(q.at).abs() < minGap);
      if (!clash) chosen.add(p);
    }
    return chosen..sort((a, b) => a.at.compareTo(b.at));
  }

  /// [t], or the end of the quiet hours it falls into.
  static DateTime awake(DateTime t) {
    if (t.hour >= quietFrom) {
      return DateTime(t.year, t.month, t.day + 1, quietUntil);
    }
    if (t.hour < quietUntil) {
      return DateTime(t.year, t.month, t.day, quietUntil);
    }
    return t;
  }

  /// When to remind about tomorrow's daily bonus: tomorrow at
  /// [dailyHour].
  static DateTime dailyReminder(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1, dailyHour);
}
