/// Turns a touch's platform timestamp into a reading of the game's
/// monotonic clock (docs/05 T-9, T-10).
///
/// The handler that receives a pointer-down runs on the UI thread, which
/// may be busy building a frame when the touch arrives; reading the clock
/// there counts the touch late by however long it waited. The platform
/// stamps every touch when it happens, on its own monotonic clock. The two
/// clocks differ by a constant, so for every touch
///
///     handler reading − event stamp = offset + wait,   wait ≥ 0.
///
/// The smallest difference seen recently is the offset (plus the shortest
/// possible wait), and `event stamp + that minimum` is the touch on the
/// game clock, however busy the frame was.
///
/// Pure Dart, no Flutter: times are seconds.
class TapClock {
  TapClock({this.window = 64, this.maxWait = 0.1});

  /// How many recent touches the minimum is taken over: a short window
  /// follows a clock that drifts or jumps, a long one finds the true
  /// minimum more surely.
  final int window;

  /// A wait longer than this is not believed: the two clocks must have
  /// moved apart (the phone slept, a different time base), so the touch
  /// counts at the handler reading and the history starts again.
  final double maxWait;

  final List<double> _diffs = [];

  /// The last correction applied, in seconds (diagnostics, T-12).
  double lastWait = 0;

  /// The touch on the game clock. [handlerNow] is the game clock read in
  /// the handler; [eventStamp] the platform's timestamp of the touch, or
  /// null when there is none (screen readers, the pause button, tests).
  double tapTime(double handlerNow, double? eventStamp) {
    if (eventStamp == null || eventStamp <= 0) {
      lastWait = 0;
      return handlerNow;
    }
    final diff = handlerNow - eventStamp;
    _diffs.add(diff);
    if (_diffs.length > window) _diffs.removeAt(0);
    var min = _diffs.first;
    for (final d in _diffs) {
      if (d < min) min = d;
    }
    final wait = diff - min;
    if (wait > maxWait) {
      _diffs
        ..clear()
        ..add(diff);
      lastWait = 0;
      return handlerNow;
    }
    lastWait = wait;
    return handlerNow - wait;
  }

  /// Forget the history (the app came back: the clocks may have moved).
  void reset() {
    _diffs.clear();
    lastWait = 0;
  }
}
