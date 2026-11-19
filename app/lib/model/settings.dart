import 'number_format.dart';

/// Player preferences (docs/04 §2), saved with the game.
class Settings {
  double sfxVolume = 1;
  double musicVolume = 0.4;
  bool haptics = true;

  /// null = follow the system language.
  String? language;
  Notation notation = Notation.short;

  /// Calm mode ("Tryb spokojny", docs/04 U-6): less motion and flicker.
  /// Kept under its old name, also in saves.
  bool reduceMotion = false;
  bool notifications = true;

  /// Game statistics and crash reports (docs/05 T-30, T-33). Where the law
  /// asks for consent they wait until [analyticsAsked]; elsewhere they are
  /// on unless the player turns them off.
  bool analytics = true;

  /// The player answered the statistics question (or chose in the
  /// settings).
  bool analyticsAsked = false;

  /// The player's input lag in ms from the calibration test (docs/05
  /// T-13): subtracted from every graded tap. Used only while
  /// `Features.calibration` is on.
  double inputOffsetMs = 0;
}
