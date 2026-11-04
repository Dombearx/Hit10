/// Game statistics sent to Firebase Analytics (docs/05 T-30, §8a).
///
/// Pure Dart (T-3): the controller logs through this door, the device build
/// plugs Firebase in behind it, tests and the web use the stand-ins below.
library;

abstract interface class Analytics {
  /// One event. [name] and the keys of [params]: ≤ 40 characters, letters,
  /// digits and `_`; values are `String` (≤ 100 characters) or `num`.
  void log(String name, [Map<String, Object> params = const {}]);

  /// A property of the player that later events are grouped by
  /// (≤ 24-character name, ≤ 36-character value; null clears it).
  void setUserProperty(String name, String? value);

  /// The player's choice in the settings (on by default).
  void setEnabled(bool on);
}

/// No statistics: web, tests, and builds without a Firebase project
/// (the APKs we install on our own phones, T-28).
class NoAnalytics implements Analytics {
  const NoAnalytics();
  @override
  void log(String name, [Map<String, Object> params = const {}]) {}
  @override
  void setUserProperty(String name, String? value) {}
  @override
  void setEnabled(bool on) {}
}

/// Keeps what was logged, for tests.
class RecordingAnalytics implements Analytics {
  final List<(String, Map<String, Object>)> events = [];
  final Map<String, String?> userProperties = {};
  bool enabled = true;

  /// Names of the events logged so far, in order.
  List<String> get names => [for (final e in events) e.$1];

  /// The parameters of the last event called [name].
  Map<String, Object>? last(String name) {
    for (final e in events.reversed) {
      if (e.$1 == name) return e.$2;
    }
    return null;
  }

  @override
  void log(String name, [Map<String, Object> params = const {}]) {
    if (enabled) events.add((name, params));
  }

  @override
  void setUserProperty(String name, String? value) =>
      userProperties[name] = value;

  @override
  void setEnabled(bool on) => enabled = on;
}

/// Rounds after which the player's accuracy is reported once
/// (`accuracy` event): enough to see how fast players learn the timing.
const accuracyCheckpoints = [10, 50, 200, 1000, 5000];

/// Shortens [text] to Firebase's 100-character limit for string values.
String clip(String text, [int max = 100]) =>
    text.length <= max ? text : text.substring(0, max);
