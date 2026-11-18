/// Game statistics sent to Firebase Analytics (docs/05 T-30, §8a).
///
/// Pure Dart (T-3): the controller logs through this door, the device build
/// plugs Firebase in behind it, tests and the web use the stand-ins below.
library;

/// What the player allows (docs/05 T-33).
enum StatsConsent {
  /// Nothing is collected; anything held is dropped.
  off,

  /// The answer is not in yet where the law asks for one (EEA, UK):
  /// events and crash reports wait on the phone, nothing is sent.
  held,

  /// Sent.
  on,
}

abstract interface class Analytics {
  /// One event. [name] and the keys of [params]: ≤ 40 characters, letters,
  /// digits and `_`; values are `String` (≤ 100 characters) or `num`.
  void log(String name, [Map<String, Object> params = const {}]);

  /// A property of the player that later events are grouped by
  /// (≤ 24-character name, ≤ 36-character value; null clears it).
  void setUserProperty(String name, String? value);

  /// What the player allows, for statistics and crash reports alike.
  void setConsent(StatsConsent consent);

  /// A Dart error Flutter caught (Crashlytics on devices, docs/05 T-30):
  /// Play's Android vitals only see the app dying.
  void recordError(Object error, StackTrace? stack, {bool fatal = false});
}

/// Holds events while consent is [StatsConsent.held] and sends them once
/// it turns [StatsConsent.on]; [StatsConsent.off] drops them. Starts held:
/// nothing leaves the phone before the controller knows the answer.
abstract class ConsentAwareAnalytics implements Analytics {
  /// At most this many events wait for an answer (the first minutes of a
  /// new player, the tutorial funnel); later ones are dropped.
  static const maxHeld = 300;

  StatsConsent _consent = StatsConsent.held;
  StatsConsent get consent => _consent;
  final List<(String, Map<String, Object>)> _held = [];
  final Map<String, String?> _properties = {};

  /// Events waiting for consent (tests).
  int get heldCount => _held.length;

  void sendEvent(String name, Map<String, Object> params);
  void sendUserProperty(String name, String? value);

  /// Switches the backend's own collection (and crash reports).
  void applyConsent(StatsConsent consent);

  @override
  void log(String name, [Map<String, Object> params = const {}]) {
    switch (_consent) {
      case StatsConsent.on:
        sendEvent(name, params);
      case StatsConsent.held:
        if (_held.length < maxHeld) _held.add((name, params));
      case StatsConsent.off:
        break;
    }
  }

  @override
  void setUserProperty(String name, String? value) {
    _properties[name] = value;
    if (_consent == StatsConsent.on) sendUserProperty(name, value);
  }

  @override
  void setConsent(StatsConsent consent) {
    if (consent == _consent) return;
    _consent = consent;
    applyConsent(consent);
    if (consent == StatsConsent.on) {
      _properties.forEach(sendUserProperty);
      for (final (name, params) in _held) {
        sendEvent(name, params);
      }
    }
    if (consent != StatsConsent.held) _held.clear();
  }
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
  void setConsent(StatsConsent consent) {}
  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {}
}

/// Keeps what was sent, for tests. Starts with consent given, like a
/// player outside the EEA.
class RecordingAnalytics extends ConsentAwareAnalytics {
  RecordingAnalytics({StatsConsent initial = StatsConsent.on}) {
    setConsent(initial);
  }

  final List<(String, Map<String, Object>)> events = [];
  final Map<String, String?> userProperties = {};
  final List<Object> errors = [];

  bool get enabled => consent == StatsConsent.on;

  /// Names of the events sent so far, in order.
  List<String> get names => [for (final e in events) e.$1];

  /// The parameters of the last event called [name].
  Map<String, Object>? last(String name) {
    for (final e in events.reversed) {
      if (e.$1 == name) return e.$2;
    }
    return null;
  }

  @override
  void sendEvent(String name, Map<String, Object> params) =>
      events.add((name, params));

  @override
  void sendUserProperty(String name, String? value) =>
      userProperties[name] = value;

  @override
  void applyConsent(StatsConsent consent) {}

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    if (consent != StatsConsent.off) errors.add(error);
  }
}

/// Rounds after which the player's accuracy is reported once
/// (`accuracy` event): enough to see how fast players learn the timing.
const accuracyCheckpoints = [10, 50, 200, 1000, 5000];

/// Shortens [text] to Firebase's 100-character limit for string values.
String clip(String text, [int max = 100]) =>
    text.length <= max ? text : text.substring(0, max);
