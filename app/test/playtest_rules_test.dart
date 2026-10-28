import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/time_map.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Rules added after the simulated playtest (docs/08).
void main() {
  final b = loadBalance();
  late GameState s;
  late GameEngine e;

  setUp(() {
    s = GameState();
    e = GameEngine(b, s);
  });

  group("beginner's luck", () {
    test('wider windows and triple pay for the first rounds only', () {
      final w = e.econ.playerWindows();
      expect(w.good, b.beginner.good);
      expect(w.perfect, b.beginner.perfect);
      final pay = e.hitPayout(const Grade(Tier.perfect, 0));
      s.stats.rounds = b.beginner.rounds;
      expect(e.econ.playerWindows().good, e.econ.windows().good);
      expect(pay, e.hitPayout(const Grade(Tier.perfect, 0)) * 3);
    });

    test('never after a paradox, never for generators', () {
      s.owned['grandpa'] = 10;
      expect(e.econ.windows().good, b.tier('good').window);
      s.chronons = 1;
      expect(e.econ.beginner, isFalse);
    });
  });

  group('a round without a touch is skipped, not missed', () {
    const noTap = Grade(Tier.miss, 0.3, MissKind.noTap);

    test('keeps the combo and the shield, pays nothing, counts no round', () {
      s.comboStreak = 6;
      s.shieldCharges = 1;
      final o = e.resolveRound(noTap);
      expect(o.comboBroken, isFalse);
      expect(s.comboStreak, 6);
      expect(s.shieldCharges, 1);
      expect(o.payout, 0);
      expect(s.stats.rounds, 0);
      expect(s.lifetime.missedInARow, 1);
    });

    test('a real tap resets the untapped count', () {
      e.resolveRound(noTap);
      e.resolveRound(const Grade(Tier.good, 0.04));
      expect(s.lifetime.missedInARow, 0);
    });
  });

  test('without auto-start the stopwatch waits for a touch', () {
    final r = RoundEngine(
      config: b.round,
      timeMapFor: () =>
          TimeMap(fastForwardEnd: 9, zoneStart: 9.8, zoneEnd: 10.2),
      windowsFor: () => e.econ.windows(),
    )..autoStart = false;
    r.tap(0);
    r.update(11); // auto-ends at 10.3 without a tap
    expect(r.phase, RoundPhase.result);
    r.update(20);
    expect(r.phase, RoundPhase.waiting);
  });

  test('turbo ads are 5 minutes apart', () {
    s.tutorialDone = true;
    s.playSeconds = 1000;
    final ads = AdOffers(e);
    ads.grant(AdOffer.turbo, 0);
    expect(ads.available(AdOffer.turbo, 299 * 1000), isFalse);
    expect(ads.available(AdOffer.turbo, 300 * 1000), isTrue);
  });
}
