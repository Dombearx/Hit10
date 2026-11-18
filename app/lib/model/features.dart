/// Features that are built and tested but not shown to players yet
/// (docs/07, "Funkcje za flagą"). Each is a compile-time switch, so a
/// player build cannot turn one on by accident.
abstract final class Features {
  /// Input-lag calibration (docs/05 T-13): a test in the settings and a
  /// per-device offset on every graded tap. Off for players; the test APK
  /// from CI turns it on with `--dart-define=FEATURE_CALIBRATION=true`.
  static const calibration = bool.fromEnvironment('FEATURE_CALIBRATION');
}
