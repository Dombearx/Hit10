import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../engine/round_engine.dart';
import 'game_controller.dart';

/// `hit10Qa.tapAt(t)` taps when the current round's stopwatch shows `t`
/// (starting a round first if needed); `hit10Qa.state()` returns JSON.
void registerQaHook(GameController c) {
  final api = JSObject();
  api.setProperty(
    'tapAt'.toJS,
    ((JSNumber t) {
      final game = t.toDartDouble;
      if (c.round.phase != RoundPhase.running) {
        c.onPointerDown(Duration.zero);
      }
      final dueReal = c.round.startedAt + c.round.timeMap.realAt(game);
      // Timers fire late by a frame or so: wake 30 ms early, then spin.
      final delayUs = ((dueReal - c.now() - 0.03) * 1e6).round();
      Timer(Duration(microseconds: delayUs < 0 ? 0 : delayUs), () {
        while (c.now() < dueReal) {}
        c.onPointerDown(Duration.zero);
      });
    }).toJS,
  );
  api.setProperty('tapNow'.toJS, (() => c.onPointerDown(Duration.zero)).toJS);
  api.setProperty(
    'state'.toJS,
    (() {
      final s = c.state;
      return jsonEncode({
        'tiki': s.tiki,
        'phase': c.round.phase.name,
        'gameTime': c.round.gameTime(c.now()),
        'rounds': s.stats.rounds,
        'byTier': s.stats.byTier.map((k, v) => MapEntry(k.name, v)),
        'lastError': c.round.lastGrade?.error,
        'owned': s.owned,
        'upgrades': s.upgrades,
        'synergies': s.synergies.toList(),
        'passive': c.engine.passive(),
        'pendingOffline': c.pendingOffline?.amount,
      }).toJS;
    }).toJS,
  );
  api.setProperty(
    'grant'.toJS,
    // The next economy tick (≤ 0.1 s) repaints the counter.
    ((JSNumber amount) => c.state.earn(amount.toDartDouble)).toJS,
  );
  // Pretend the player left [seconds] ago, then came back.
  api.setProperty(
    'awayFor'.toJS,
    ((JSNumber seconds) {
      c.state.lastSeenMs -= (seconds.toDartDouble * 1000).round();
      c.resume();
    }).toJS,
  );
  api.setProperty(
    'buy'.toJS,
    ((
      JSString id,
      JSNumber count,
    ) => c.buyGenerators(id.toDart, count.toDartInt).name.toJS).toJS,
  );
  api.setProperty(
    'buyUpgrade'.toJS,
    ((JSString id) => c.buyUpgrade(id.toDart).name.toJS).toJS,
  );
  api.setProperty('save'.toJS, (() => c.save().toJS).toJS);
  api.setProperty(
    'wipe'.toJS,
    (() => (c.store?.clear() ?? Future<void>.value()).toJS).toJS,
  );
  globalContext.setProperty('hit10Qa'.toJS, api);
}
