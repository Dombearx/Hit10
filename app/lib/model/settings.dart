import 'number_format.dart';

/// Player preferences (docs/04 §2), saved with the game.
class Settings {
  double sfxVolume = 1;
  double musicVolume = 0.4;
  bool haptics = true;

  /// null = follow the system language.
  String? language;
  Notation notation = Notation.short;
  bool reduceMotion = false;
  bool notifications = true;

  /// Game statistics for balancing (docs/05 T-30); the player can opt out.
  bool analytics = true;
}
