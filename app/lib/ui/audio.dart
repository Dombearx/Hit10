import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Sound effects (docs/04 §5). Everything is preloaded so a hit plays within
/// a few milliseconds of the tap (U-14). Audio is optional: if the engine
/// fails to start (no device, browser policy) the game stays silent.
class Sfx {
  static const names = [
    'perfect',
    'great',
    'good',
    'miss',
    'coins',
    'tick',
    'start',
    'whoosh',
    'buy',
    'combo_break',
  ];

  final _sources = <String, AudioSource>{};
  bool _ready = false;
  bool _starting = false;
  double volume = 1;
  bool enabled = true;

  bool get ready => _ready;

  /// Safe to call repeatedly; on the web it must follow a user gesture.
  Future<void> init() async {
    if (_ready || _starting) return;
    _starting = true;
    try {
      final soloud = SoLoud.instance;
      if (!soloud.isInitialized) await soloud.init(bufferSize: 512);
      for (final n in names) {
        _sources[n] = await soloud.loadAsset('assets/audio/$n.ogg');
      }
      _ready = true;
    } on Object catch (e) {
      debugPrint('Sfx disabled: $e');
    } finally {
      _starting = false;
    }
  }

  /// [speed] shifts pitch (U-15: the combo ladder), 1 = original.
  void play(String name, {double gain = 1, double speed = 1}) {
    if (!_ready || !enabled) return;
    final src = _sources[name];
    if (src == null) return;
    try {
      SoLoud.instance.play(src, volume: volume * gain, scale: speed);
    } on Object catch (e) {
      debugPrint('Sfx play failed: $e');
    }
  }
}
