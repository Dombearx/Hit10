import '../balance/balance.dart';
import '../model/grading.dart';
import '../model/time_map.dart';

enum RoundPhase {
  /// Clock at 0.00, "tap to start"; the starting tap is not graded (R-RUNDA-7).
  waiting,
  running,

  /// Showing the result; the next round starts by itself (R-RUNDA-6).
  result,
}

sealed class RoundEvent {
  const RoundEvent();
}

class RoundStarted extends RoundEvent {
  const RoundStarted();
}

class RoundGraded extends RoundEvent {
  const RoundGraded(this.grade, this.gameTime);
  final Grade grade;

  /// What the stopwatch showed at the tap (or at the auto-end).
  final double gameTime;
}

/// One stopwatch's round loop (docs/02 §1). Time is passed in explicitly
/// (seconds on a monotonic clock, T-8) so the engine is deterministic and
/// testable; the UI feeds it `Stopwatch` readings.
class RoundEngine {
  RoundEngine({
    required this.config,
    required this.timeMapFor,
    required this.windowsFor,
  });

  final RoundConfig config;

  /// Read at each round start, so upgrades bought mid-round apply from the
  /// next round on.
  final TimeMap Function() timeMapFor;
  final Windows Function() windowsFor;

  RoundPhase _phase = RoundPhase.waiting;
  RoundPhase get phase => _phase;

  double _start = 0;
  double _resultUntil = 0;
  double _resultGameTime = 0;
  late TimeMap _map;
  late Windows _windows;
  Grade? _last;

  /// The most recent grade (shown during [RoundPhase.result]).
  Grade? get lastGrade => _last;

  TimeMap get timeMap => _map;
  Windows get windows => _windows;

  /// Real time the current round started at.
  double get startedAt => _start;

  /// Stopwatch reading at [now]: frozen on the result, 0 while waiting.
  double gameTime(double now) => switch (_phase) {
    RoundPhase.waiting => 0,
    RoundPhase.running => _map.gameAt(now - _start),
    RoundPhase.result => _resultGameTime,
  };

  void _begin(double now) {
    _phase = RoundPhase.running;
    _start = now;
    _map = timeMapFor();
    _windows = windowsFor();
  }

  /// Whether the next round starts by itself after a result (R-RUNDA-6).
  /// The controller turns it off after untapped rounds.
  bool autoStart = true;

  /// Handles a pointer-down at [now]. Returns what happened, or null when the
  /// tap was ignored (grace period, result pause).
  RoundEvent? tap(double now) {
    switch (_phase) {
      case RoundPhase.waiting:
        _begin(now);
        return const RoundStarted();
      case RoundPhase.result:
        return null;
      case RoundPhase.running:
        if (now - _start < config.inputGraceAfterStart) return null;
        final t = _map.gameAt(now - _start);
        return _finish(now, t, grade(t - config.target, _windows));
    }
  }

  /// Advances timers; call every frame. Returns at most one event.
  RoundEvent? update(double now) {
    switch (_phase) {
      case RoundPhase.waiting:
        return null;
      case RoundPhase.running:
        final autoEnd = config.target + config.autoEndAfter;
        if (_map.gameAt(now - _start) < autoEnd) return null;
        // End exactly at the auto-end instant, however late this frame is.
        final endReal = _start + _map.realAt(autoEnd);
        return _finish(
          endReal,
          autoEnd,
          Grade(Tier.miss, config.autoEndAfter, MissKind.noTap),
        );
      case RoundPhase.result:
        if (now < _resultUntil) return null;
        if (!autoStart) {
          // Nobody is playing: wait for a touch (R-RUNDA-6, playtest 08).
          _phase = RoundPhase.waiting;
          return null;
        }
        _begin(_resultUntil);
        return const RoundStarted();
    }
  }

  RoundGraded _finish(double now, double gameTime, Grade g) {
    _phase = RoundPhase.result;
    _resultUntil = now + config.resultPause;
    _resultGameTime = gameTime;
    _last = g;
    return RoundGraded(g, gameTime);
  }

  /// Leaving the app or covering the clock abandons the round without a
  /// penalty (R-RUNDA-8).
  void cancel() {
    _phase = RoundPhase.waiting;
    _last = null;
  }
}
