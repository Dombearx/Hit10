/// Piecewise-linear mapping between real time (since the round started) and
/// game time (what the stopwatch shows). docs/02 R-RUNDA-10…12, T-11.
///
/// Game time runs at `clock · fastForward` before [fastForwardEnd], at
/// `clock · zoneSpeed` inside the bullet-time zone `[zoneStart, zoneEnd)`, and
/// at `clock` everywhere else. Both directions are exact, so a tap's real
/// timestamp maps to the game time the player saw, regardless of frame rate.
class TimeMap {
  TimeMap({
    required this.fastForwardEnd,
    required this.zoneStart,
    required this.zoneEnd,
    this.fastForward = 1,
    this.zoneSpeed = 1,
    this.clock = 1,
  }) : assert(fastForward > 0 && zoneSpeed > 0 && clock > 0),
       assert(fastForwardEnd <= zoneStart && zoneStart <= zoneEnd) {
    // Segment boundaries in game time and the speed inside each segment.
    _gameBounds = [0, fastForwardEnd, zoneStart, zoneEnd];
    _speeds = [fastForward * clock, clock, zoneSpeed * clock, clock];
    _realBounds = [0];
    for (var i = 0; i < 3; i++) {
      _realBounds.add(
        _realBounds[i] + (_gameBounds[i + 1] - _gameBounds[i]) / _speeds[i],
      );
    }
  }

  final double fastForwardEnd;
  final double zoneStart;
  final double zoneEnd;
  final double fastForward;
  final double zoneSpeed;
  final double clock;

  late final List<double> _gameBounds;
  late final List<double> _speeds;
  late final List<double> _realBounds;

  /// Game time shown after [real] seconds of the round.
  double gameAt(double real) {
    if (real <= 0) return 0;
    var i = 3;
    while (i > 0 && real < _realBounds[i]) {
      i--;
    }
    return _gameBounds[i] + (real - _realBounds[i]) * _speeds[i];
  }

  /// Real seconds into the round at which the stopwatch shows [game].
  double realAt(double game) {
    if (game <= 0) return 0;
    var i = 3;
    while (i > 0 && game < _gameBounds[i]) {
      i--;
    }
    return _realBounds[i] + (game - _gameBounds[i]) / _speeds[i];
  }

  /// How fast game time runs at game time [game] (for effects and sound).
  double speedAt(double game) {
    var i = 3;
    while (i > 0 && game < _gameBounds[i]) {
      i--;
    }
    return _speeds[i];
  }

  bool inBulletZone(double game) => game >= zoneStart && game < zoneEnd;
}
