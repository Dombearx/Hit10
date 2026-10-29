import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// The three music loops (docs/04 U-13).
enum MusicTrack { calm, frenzy, golden }

/// Sound effects and music (docs/04 §5). Everything is preloaded so a hit plays within
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
    'heartbeat',
    'chimes',
    'fanfare',
    'rewind',
  ];

  final _sources = <String, AudioSource>{};
  final _music = <MusicTrack, AudioSource>{};
  bool _ready = false;
  bool _starting = false;
  double volume = 1;
  bool enabled = true;

  bool get ready => _ready;
  bool _underwater = false;

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
      for (final m in MusicTrack.values) {
        _music[m] = await soloud.loadAsset('assets/audio/music_${m.name}.ogg');
      }
      // Low-pass filter (U-19); dry unless switched on.
      final lp = soloud.filters.biquadResonantFilter;
      lp.activate();
      lp.type.value = 0; // low-pass
      lp.frequency.value = 700;
      lp.wet.value = 0;
      _ready = true;
      _switchMusic(force: true);
    } on Object catch (e) {
      debugPrint('Sfx disabled: $e');
    } finally {
      _starting = false;
    }
  }

  /// Muffles everything inside the bullet-time zone (U-19).
  void underwater(bool on) {
    if (!_ready || on == _underwater) return;
    _underwater = on;
    try {
      SoLoud.instance.filters.biquadResonantFilter.wet.value = on ? 1 : 0;
    } on Object catch (e) {
      debugPrint('filter failed: $e');
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

  // --------------------------------------------------------------- music --

  /// 0–1; the music plays this loud (U-20: quiet by default).
  double musicVolume = 0.4;

  /// Set when another app was already playing music at launch (U-20): ours
  /// stays silent until the player moves the music slider.
  bool musicSuppressed = false;

  MusicTrack _track = MusicTrack.calm;
  SoundHandle? _musicHandle;
  static const _fade = Duration(milliseconds: 700);

  double get _musicGain => musicSuppressed ? 0 : musicVolume;

  /// Crossfades to [track]; cheap when it is already playing.
  void music(MusicTrack track) {
    if (track == _track) return;
    _track = track;
    _switchMusic();
  }

  void _switchMusic({bool force = false}) {
    if (!_ready) return;
    try {
      final soloud = SoLoud.instance;
      final old = _musicHandle;
      if (old != null) {
        soloud.fadeVolume(old, 0, _fade);
        soloud.scheduleStop(old, _fade);
      }
      final h = soloud.play(_music[_track]!, volume: 0, looping: true);
      soloud.fadeVolume(h, _musicGain, force ? Duration.zero : _fade);
      _musicHandle = h;
    } on Object catch (e) {
      debugPrint('music failed: $e');
    }
  }

  /// Applies a changed music volume at once.
  void updateMusicVolume() {
    final h = _musicHandle;
    if (!_ready || h == null) return;
    try {
      SoLoud.instance.setVolume(h, _musicGain);
    } on Object catch (e) {
      debugPrint('music volume failed: $e');
    }
  }

  /// Silences everything while the app is in the background (U-21).
  void mute(bool on) {
    if (!_ready) return;
    try {
      SoLoud.instance.setGlobalVolume(on ? 0 : 1);
    } on Object catch (e) {
      debugPrint('mute failed: $e');
    }
  }
}

/// Whether another app is playing music right now (Android only, U-20).
Future<bool> otherMusicPlaying() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    return await const MethodChannel('hit10/audio')
            .invokeMethod<bool>('otherMusicPlaying') ??
        false;
  } on Object catch (e) {
    debugPrint('otherMusicPlaying failed: $e');
    return false;
  }
}
