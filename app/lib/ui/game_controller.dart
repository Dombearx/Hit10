import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../balance/balance.dart';
import '../engine/game_engine.dart';
import '../engine/round_engine.dart';
import '../model/economy.dart';
import '../model/game_state.dart';
import '../model/grading.dart';
import '../model/settings.dart';
import '../model/showcase.dart';
import '../persistence/save_codec.dart';
import '../persistence/save_store.dart';
import 'audio.dart';
import 'haptics.dart';

/// What the arena needs to animate a finished round.
class HitFeedback {
  HitFeedback(this.outcome, this.gameTime);
  final RoundOutcome outcome;
  final double gameTime;

  Grade get grade =>
      Grade(outcome.tier, outcome.raw.error, outcome.raw.missKind);
  double get reward => outcome.payout;
}

/// Glue between the pure engine and the screen: owns the monotonic clock
/// (T-8), turns pointer-downs into grades (T-9), runs the economy tick
/// (T-14), saves (T-18) and fires sound and haptics.
class GameController extends ChangeNotifier {
  GameController({
    required this.balance,
    GameState? state,
    Settings? settings,
    this.store,
    Sfx? sfx,
    Haptics? haptics,
    int Function()? wallClockMs,
  }) : state = state ?? GameState(),
       settings = settings ?? Settings(),
       sfx = sfx ?? Sfx(),
       haptics = haptics ?? Haptics(),
       _wallMs = wallClockMs ?? (() => DateTime.now().millisecondsSinceEpoch) {
    engine = GameEngine(balance, this.state);
    round = RoundEngine(
      config: balance.round,
      timeMapFor: () => econ.timeMap(),
      windowsFor: econ.windows,
    );
    _applySettings();
  }

  final Balance balance;
  final GameState state;
  final Settings settings;
  final SaveStore? store;
  final Sfx sfx;
  final Haptics haptics;
  final int Function() _wallMs;
  late final GameEngine engine;
  late final RoundEngine round;
  final InputDiagnostics diagnostics = InputDiagnostics();
  final GeneratorShowcase showcase = GeneratorShowcase();

  Economy get econ => engine.econ;

  final Stopwatch _clock = Stopwatch()..start();

  /// Seconds on the monotonic clock.
  double now() => _clock.elapsedMicroseconds / 1e6;

  final _feedback = StreamController<HitFeedback>.broadcast();
  Stream<HitFeedback> get feedback => _feedback.stream;

  /// Fires with `true` when a golden round starts.
  final _roundStarts = StreamController<bool>.broadcast();
  Stream<bool> get roundStarts => _roundStarts.stream;

  int _lastTickTenth = -1;
  bool _whooshed = false;

  /// Offline income waiting in the "while you were away" dialog.
  OfflineReport? pendingOffline;

  /// Set when the save could not be read and the game started fresh (T-20).
  bool saveWasCorrupt = false;

  double? _lastTick;
  double _econAcc = 0;
  double _sinceSave = 0;
  static const _saveEvery = 10.0;

  void _applySettings() {
    sfx.volume = settings.sfxVolume;
    sfx.enabled = settings.sfxVolume > 0;
    haptics.enabled = settings.haptics;
  }

  /// Pointer-down on the arena. [eventTime] is the platform timestamp, used
  /// only for diagnostics; the grade comes from the clock read right here.
  void onPointerDown(Duration eventTime) {
    final t = now();
    diagnostics.recordInput(t, eventTime);
    unawaited(sfx.init()); // the web needs a gesture before audio starts
    _handle(round.tap(t));
  }

  /// Called every frame by the arena.
  void tick() {
    final t = now();
    final last = _lastTick;
    _lastTick = t;
    _handle(round.update(t));
    _roundSounds(t);
    if (last == null) return;
    // Long gaps (debugger, backgrounded tab) are offline time, not play.
    final dt = (t - last).clamp(0.0, 1.0);
    _econAcc += dt;
    final step = 1 / balance.economyTickHz;
    if (_econAcc >= step) {
      engine.tick(_econAcc);
      _econAcc = 0;
      notifyListeners();
    }
    _sinceSave += dt;
    if (_sinceSave >= _saveEvery) unawaited(save());
  }

  void _handle(RoundEvent? ev) {
    switch (ev) {
      case null:
        return;
      case RoundStarted():
        engine.onRoundStart();
        _lastTickTenth = -1;
        _whooshed = false;
        if (engine.goldenRound) sfx.play('coins');
        _roundStarts.add(engine.goldenRound);
        notifyListeners();
      case RoundGraded(:final grade, :final gameTime):
        sfx.underwater(false);
        final o = engine.resolveRound(grade);
        _playFeedback(o);
        _feedback.add(HitFeedback(o, gameTime));
        notifyListeners();
    }
  }

  void _playFeedback(RoundOutcome o) {
    // Ding rises a semitone every two streak steps, up to an octave (U-15).
    final pitch = math.pow(2, math.min(o.streak ~/ 2, 12) / 12).toDouble();
    switch (o.tier) {
      case Tier.perfect:
        sfx.play('perfect', speed: pitch);
        sfx.play('coins', gain: 0.6);
      case Tier.great:
        sfx.play('great', speed: pitch);
      case Tier.good:
        sfx.play('good');
      case Tier.miss:
        sfx.play('miss');
    }
    if (o.comboBroken && o.streakBefore >= 3) sfx.play('combo_break');
    if (o.golden?.effect != null) sfx.play('buy', gain: 0.8);
    unawaited(haptics.forTier(o.tier));
  }

  /// Ticking in the last second, the fast-forward whoosh and the muffled
  /// bullet-time zone (docs/04 §3, U-19).
  void _roundSounds(double now) {
    if (round.phase != RoundPhase.running) return;
    final g = round.gameTime(now);
    final r = balance.round;
    if (econ.level('ticking') > 0 && g >= r.target - 1 && g < r.target) {
      final tenth = (g * 10).floor();
      if (tenth != _lastTickTenth) {
        _lastTickTenth = tenth;
        sfx.play('tick', gain: 0.7);
        if (settings.haptics) unawaited(HapticFeedback.selectionClick());
      }
    }
    if (!_whooshed && round.timeMap.fastForward > 1 && g >= r.fastForwardEnd) {
      _whooshed = true;
      sfx.play('whoosh', gain: 0.6);
    }
    sfx.underwater(
      round.timeMap.zoneSpeed < 1 && round.timeMap.inBulletZone(g),
    );
  }

  /// The player tapped the flying golden clock (R-ZLOTA-1).
  void claimGolden() {
    if (!engine.claimGolden()) return;
    sfx.play('coins');
    if (settings.haptics) unawaited(HapticFeedback.mediumImpact());
    notifyListeners();
  }

  // ------------------------------------------------------------ shopping --

  BuyResult _afterBuy(BuyResult r) {
    if (r == BuyResult.ok) {
      sfx.play('buy');
      if (settings.haptics) unawaited(HapticFeedback.selectionClick());
      unawaited(save());
      notifyListeners();
    }
    return r;
  }

  BuyResult buyGenerators(String id, int count) =>
      _afterBuy(engine.buyGenerators(id, count));
  BuyResult buyUpgrade(String id) => _afterBuy(engine.buyUpgrade(id));
  BuyResult buySynergy(String id) => _afterBuy(engine.buySynergy(id));
  BuyResult buySkill(String id) => _afterBuy(engine.buySkill(id));

  // -------------------------------------------------------- offline/save --

  /// Checks for offline income (start-up and every resume).
  void checkOffline() {
    pendingOffline = engine.offlineSince(_wallMs());
    state.lastSeenMs = _wallMs();
    if (pendingOffline != null) notifyListeners();
  }

  void collectOffline({double multiplier = 1}) {
    final r = pendingOffline;
    if (r == null) return;
    engine.claimOffline(r, multiplier: multiplier);
    pendingOffline = null;
    sfx.play('coins');
    unawaited(save());
    notifyListeners();
  }

  Future<void> save() async {
    _sinceSave = 0;
    state.lastSeenMs = _wallMs();
    final store = this.store;
    if (store == null) return;
    try {
      await store.write(
        saveToJsonString(
          SaveData(state, settings, balanceVersion: balance.version),
        ),
      );
    } on Object catch (e) {
      debugPrint('save failed: $e');
    }
  }

  /// App hidden or a panel covers the clock (R-RUNDA-8).
  void pause() {
    if (round.phase != RoundPhase.waiting) {
      round.cancel();
      engine.onRoundCancelled();
      sfx.underwater(false);
      notifyListeners();
    }
    _lastTick = null;
    unawaited(save());
  }

  void resume() {
    _lastTick = null;
    checkOffline();
  }

  @override
  void dispose() {
    _feedback.close();
    _roundStarts.close();
    super.dispose();
  }
}

/// T-12: how far the moment we read the clock lags the platform's touch
/// timestamp. Only the spread matters (a constant offset is fine); a large
/// spread would mean grades depend on frame timing.
class InputDiagnostics {
  final List<double> _offsets = [];

  void recordInput(double clockSeconds, Duration eventTime) {
    if (eventTime == Duration.zero) return;
    _offsets.add(clockSeconds - eventTime.inMicroseconds / 1e6);
    if (_offsets.length > 100) _offsets.removeAt(0);
  }

  int get samples => _offsets.length;

  /// Largest deviation of the input offset from its mean, in ms.
  double get jitterMs {
    if (_offsets.length < 2) return 0;
    final mean = _offsets.reduce((a, b) => a + b) / _offsets.length;
    final dev = _offsets.map((o) => (o - mean).abs());
    return dev.reduce((a, b) => a > b ? a : b) * 1000;
  }
}

/// Loads the save (falling back to the backup, then to a fresh game, T-20)
/// and returns a ready controller with offline income checked.
Future<GameController> loadGame(Balance balance, SaveStore store) async {
  SaveData? data;
  var corrupt = false;
  for (final read in [store.read, store.readBackup]) {
    try {
      final text = await read();
      if (text == null) break;
      data = saveFromJsonString(text);
      break;
    } on Object catch (e) {
      corrupt = true;
      debugPrint('save unreadable: $e');
    }
  }
  final c = GameController(
    balance: balance,
    state: data?.state,
    settings: data?.settings,
    store: store,
  );
  c.saveWasCorrupt = corrupt && data == null;
  c.checkOffline();
  return c;
}
