import '../balance/balance.dart';

/// Calendar events (docs/02 §14): each season switches itself on by the
/// phone's local date — no server, like Cookie Clicker's seasons — and
/// comes back every year. Pure Dart (T-3).
class Season {
  const Season(this.config, this.year, this.from, this.to);
  final SeasonConfig config;

  /// The year the season started in (New Year's runs into January).
  final int year;

  /// First and last local day, inclusive.
  final DateTime from;
  final DateTime to;

  String get id => config.id;

  /// Progress and the reward belong to one year's run of a season.
  String get key => '$id-$year';
}

/// The season running on local date [now], or null.
Season? seasonAt(SeasonsConfig cfg, DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  for (final s in cfg.list) {
    // In January, a season that wraps the new year started last year.
    for (final y in [now.year, now.year - 1]) {
      final (from, to) = seasonDates(s, y);
      if (!day.isBefore(from) && !day.isAfter(to)) {
        return Season(s, y, from, to);
      }
    }
  }
  return null;
}

/// The season [id] as it falls in [year] (a preview for QA, docs/05 T-12).
Season seasonIn(SeasonsConfig cfg, String id, int year) {
  final s = cfg.list.firstWhere((s) => s.id == id);
  final (from, to) = seasonDates(s, year);
  return Season(s, year, from, to);
}

(DateTime, DateTime) seasonDates(SeasonConfig s, int year) {
  final easter = s.easterFrom == null ? null : easterSunday(year);
  final from = easter != null
      ? easter.add(Duration(days: s.easterFrom!))
      : DateTime(year, s.from!.$1, s.from!.$2);
  var to = easter != null
      ? easter.add(Duration(days: s.easterTo!))
      : DateTime(year, s.to!.$1, s.to!.$2);
  if (to.isBefore(from)) to = DateTime(year + 1, to.month, to.day);
  return (from, to);
}

/// Western Easter Sunday (Meeus/Jones/Butcher).
DateTime easterSunday(int y) {
  final a = y % 19, b = y ~/ 100, c = y % 100, d = b ~/ 4, e = b % 4;
  final f = (b + 8) ~/ 25, g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4, k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(y, month, day);
}
