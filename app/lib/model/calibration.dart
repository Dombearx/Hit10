/// Input-lag calibration (docs/05 T-13): what the test taps say about the
/// player's constant delay. Only the bias is measured; the spread is the
/// player's skill and stays theirs.
class CalibrationResult {
  const CalibrationResult({
    required this.offsetMs,
    required this.spreadMs,
    required this.used,
  });

  /// Suggested offset: how late the taps register, in ms (negative =
  /// early). Clamped to what a phone plausibly adds.
  final int offsetMs;

  /// Typical distance of a tap from that offset (median absolute
  /// deviation), in ms: large means the test said little.
  final double spreadMs;

  /// Taps that counted (wild ones are dropped).
  final int used;

  /// Few usable taps or a scattered test: worth repeating before applying.
  bool get unreliable => used < Calibration.minTaps || spreadMs > 45;
}

abstract final class Calibration {
  /// Taps one test asks for.
  static const taps = 10;

  /// Fewer usable taps than this and the result is not trusted.
  static const minTaps = 6;

  /// A tap further than this from the target is a slip, not lag.
  static const maxError = 0.2;

  /// The offset is limited to this range (ms).
  static const minOffsetMs = -80;
  static const maxOffsetMs = 200;

  /// [errors]: tap time minus target, in seconds, measured without any
  /// offset applied.
  static CalibrationResult analyse(List<double> errors) {
    final ok = [
      for (final e in errors)
        if (e.abs() <= maxError) e,
    ]..sort();
    if (ok.isEmpty) {
      return const CalibrationResult(offsetMs: 0, spreadMs: 0, used: 0);
    }
    final median = _median(ok);
    final deviations = [for (final e in ok) (e - median).abs()]..sort();
    return CalibrationResult(
      offsetMs: (median * 1000).round().clamp(minOffsetMs, maxOffsetMs),
      spreadMs: _median(deviations) * 1000,
      used: ok.length,
    );
  }

  static double _median(List<double> sorted) {
    final n = sorted.length;
    return n.isOdd ? sorted[n ~/ 2] : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
  }
}
