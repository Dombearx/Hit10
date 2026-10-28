import 'dart:async';

import 'package:flutter/foundation.dart';

import '../balance/balance.dart';
import '../engine/round_engine.dart';
import '../model/game_state.dart';
import '../model/grading.dart';
import '../model/time_map.dart';
import 'audio.dart';
import 'haptics.dart';

/// What the arena needs to animate a finished round.
class HitFeedback {
  HitFeedback(this.grade, this.reward, this.gameTime);
  final Grade grade;
  final double reward;
  final double gameTime;
}

/// Glue between the pure engine and the screen: owns the monotonic clock
/// (T-8), turns pointer-downs into grades (T-9), pays rewards and fires sound
/// and haptics. The arena reads it every frame; widgets listen for changes.
class GameController extends ChangeNotifier {
  GameController({required this.balance, Sfx? sfx, Haptics? haptics})
    : sfx = sfx ?? Sfx(),
      haptics = haptics ?? Haptics() {
    round = RoundEngine(
      config: balance.round,
      timeMapFor: _timeMap,
      windowsFor: _windows,
    );
  }

  final Balance balance;
  final Sfx sfx;
  final Haptics haptics;
  final GameState state = GameState();
  late final RoundEngine round;
  final InputDiagnostics diagnostics = InputDiagnostics();

  final Stopwatch _clock = Stopwatch()..start();

  /// Seconds on the monotonic clock.
  double now() => _clock.elapsedMicroseconds / 1e6;

  final _feedback = StreamController<HitFeedback>.broadcast();
  Stream<HitFeedback> get feedback => _feedback.stream;

  TimeMap _timeMap() {
    final r = balance.round;
    return TimeMap(
      fastForwardEnd: r.fastForwardEnd,
      zoneStart: r.target - r.bulletZone,
      zoneEnd: r.target + r.bulletZone,
    );
  }

  Windows _windows() => Windows(
    perfect: balance.tier('perfect').window,
    great: balance.tier('great').window,
    good: balance.tier('good').window,
  );

  /// Pointer-down on the arena. [eventTime] is the platform timestamp, used
  /// only for diagnostics; the grade comes from the clock read right here.
  void onPointerDown(Duration eventTime) {
    final t = now();
    diagnostics.recordInput(t, eventTime);
    unawaited(sfx.init()); // the web needs a gesture before audio starts
    _handle(round.tap(t));
  }

  /// Called every frame by the arena.
  void tick() => _handle(round.update(now()));

  void _handle(RoundEvent? ev) {
    switch (ev) {
      case null:
        return;
      case RoundStarted():
        notifyListeners();
      case RoundGraded(:final grade, :final gameTime):
        final reward = grade.isHit ? balance.tier(grade.tier.name).reward : 0.0;
        state.earn(reward);
        state.stats.record(grade, tapped: grade.missKind != MissKind.noTap);
        _playFeedback(grade.tier);
        _feedback.add(HitFeedback(grade, reward, gameTime));
        notifyListeners();
    }
  }

  void _playFeedback(Tier tier) {
    switch (tier) {
      case Tier.perfect:
        sfx.play('perfect');
        sfx.play('coins', gain: 0.6);
      case Tier.great:
        sfx.play('great');
      case Tier.good:
        sfx.play('good');
      case Tier.miss:
        sfx.play('miss');
    }
    unawaited(haptics.forTier(tier));
  }

  /// App hidden or a panel covers the clock (R-RUNDA-8).
  void pause() {
    if (round.phase == RoundPhase.waiting) return;
    round.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _feedback.close();
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

  /// Spread (max − min after removing the mean) of the input offset, in ms.
  double get jitterMs {
    if (_offsets.length < 2) return 0;
    final mean = _offsets.reduce((a, b) => a + b) / _offsets.length;
    final dev = _offsets.map((o) => (o - mean).abs());
    return dev.reduce((a, b) => a > b ? a : b) * 1000;
  }
}
