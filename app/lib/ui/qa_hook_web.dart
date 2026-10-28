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
        'skills': s.skills,
        'combo': s.comboStreak,
        'shield': s.shieldCharges,
        'frenzyLeft': c.engine.frenzyLeft,
        'hotHandLeft': c.engine.hotHandLeft,
        'goldenVisible': c.engine.goldenVisibleLeft,
        'goldenArmed': c.engine.goldenArmed,
        'goldenRound': c.engine.goldenRound,
        'goldenCaught': s.lifetime.goldenCaught,
        'achievements': s.achievements.length,
        'chronons': s.chronons,
        'shards': s.shards,
        'perks': s.perks.toList(),
        'tutorial': c.tutorialStep.name,
        'clocks': c.clocks.length,
        'clockPhases': [for (final k in c.clocks) k.round.phase.name],
        'turboLeft': s.turboLeft,
        'tip': c.pendingTip,
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
  api.setProperty(
    'setSkill'.toJS,
    ((JSString id, JSNumber level) {
      c.state.skills[id.toDart] = level.toDartInt;
      if (id.toDart == 'shield') {
        c.state.shieldCharges = c.engine.maxShieldCharges();
      }
    }).toJS,
  );
  api.setProperty('summonGolden'.toJS, (() => c.engine.summonGolden()).toJS);
  api.setProperty(
    'effect'.toJS,
    ((JSString name, JSNumber seconds) {
      final v = seconds.toDartDouble;
      if (name.toDart == 'frenzy') c.engine.frenzyLeft = v;
      if (name.toDart == 'hotHand') c.engine.hotHandLeft = v;
    }).toJS,
  );
  api.setProperty(
    'setup'.toJS,
    ((JSString json) {
      final m = jsonDecode(json.toDart) as Map<String, dynamic>;
      if (m['perks'] case final List<dynamic> p) {
        c.state.perks.addAll(p.cast<String>());
      }
      if (m['shards'] case final num v) c.state.shards = v.toInt();
      if (m['perfects'] case final num v) c.state.lifetime.perfects = v.toInt();
      if (m['earnedTotal'] case final num v) c.state.earnedTotal = v.toDouble();
      if (m['playSeconds'] case final num v) c.state.playSeconds = v.toDouble();
      if (m['combo'] case final num v) c.state.comboStreak = v.toInt();
      if (m['tutorialDone'] == true) c.finishTutorial();
    }).toJS,
  );
  api.setProperty('save'.toJS, (() => c.save().toJS).toJS);
  api.setProperty(
    'wipe'.toJS,
    (() => (c.store?.clear() ?? Future<void>.value()).toJS).toJS,
  );
  globalContext.setProperty('hit10Qa'.toJS, api);
}
