/// Mapping between real time (since the round started) and game time (what
/// the stopwatch shows). docs/02 R-RUNDA-10…12, T-11.
///
/// The stopwatch starts at [start] (Start później) and runs at a constant
/// [clock] speed, so the rhythm never changes inside a round. Both
/// directions are exact, so a tap's real timestamp maps to the game time the
/// player saw, regardless of frame rate.
class TimeMap {
  TimeMap({
    this.start = 0,
    required this.zoneStart,
    required this.zoneEnd,
    this.clock = 1,
  }) : assert(clock > 0 && start >= 0),
       assert(start <= zoneStart && zoneStart <= zoneEnd);

  /// Game time shown when the round starts.
  final double start;

  /// The focus zone around the target (Zimna krew's cues).
  final double zoneStart;
  final double zoneEnd;
  final double clock;

  /// Game time shown after [real] seconds of the round.
  double gameAt(double real) => real <= 0 ? start : start + real * clock;

  /// Real seconds into the round at which the stopwatch shows [game].
  double realAt(double game) => game <= start ? 0 : (game - start) / clock;

  bool inFocusZone(double game) => game >= zoneStart && game < zoneEnd;
}
