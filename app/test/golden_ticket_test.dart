import 'dart:math' as math;

import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// R-ZLOTA-7: a round keeps what it started with — the golden round
/// belongs to one clock, and a Frenzy or Hot hand that ends mid-round
/// still counts for a round that started inside it.
void main() {
  final b = loadBalance();
  final frenzyX = b.golden.effect('frenzy').multiplier;
  final hotX = b.golden.effect('hotHand').multiplier;
  const great = Grade(Tier.great, 0.02);
  const miss = Grade(Tier.miss, 0.3, MissKind.late);

  late GameState s;
  late GameEngine e;

  setUp(() {
    s = GameState()..stats.rounds = 100; // past beginner's luck
    e = GameEngine(b, s, random: math.Random(1));
  });

  /// What a GREAT pays with no effects (Luck may bump it; seed is fixed,
  /// so compare against a fresh engine with the same seed).
  double plain(Grade g) {
    final s2 = GameState()..stats.rounds = 100;
    final e2 = GameEngine(b, s2, random: math.Random(1));
    e2.onRoundStart();
    return e2.resolveRound(g).payout;
  }

  group('Frenzy', () {
    test('a round started in it is paid ×7 after the timer ran out', () {
      e.frenzyLeft = 1;
      e.tick(0.5);
      e.onRoundStart();
      e.tick(1); // the Frenzy ends mid-round
      expect(e.frenzyLeft, 0);
      expect(e.frenzy, 1);
      expect(e.frenzyLastRound, isTrue);
      final o = e.resolveRound(great);
      expect(o.frenzyGrace, isTrue);
      expect(o.payout, closeTo(plain(great) * frenzyX, 1e-9));
      // The bonus was for that round only; passive income is back to 1×.
      expect(e.frenzy, 1);
      expect(e.frenzyLastRound, isFalse);
    });

    test('a round started after it ended gets nothing', () {
      e.frenzyLeft = 0.5;
      e.tick(1);
      e.onRoundStart();
      final o = e.resolveRound(great);
      expect(o.frenzyGrace, isFalse);
      expect(o.payout, closeTo(plain(great), 1e-9));
    });

    test('a round still inside it is not flagged as grace', () {
      e.frenzyLeft = 10;
      e.tick(0.1);
      e.onRoundStart();
      final o = e.resolveRound(great);
      expect(o.frenzyGrace, isFalse);
      expect(o.payout, closeTo(plain(great) * frenzyX, 1e-9));
    });

    test('two clocks: each keeps its own ticket', () {
      e.frenzyLeft = 1;
      e.onRoundStart(0); // left starts inside the Frenzy
      e.tick(1.5); // it ends
      e.onRoundStart(1); // right starts after it
      final left = e.resolveRound(great, clock: 0);
      final right = e.resolveRound(great, clock: 1);
      expect(left.frenzyGrace, isTrue);
      expect(right.frenzyGrace, isFalse);
      expect(left.payout, closeTo(right.payout * frenzyX, 1e-6));
    });

    test('a cancelled round drops its ticket', () {
      e.frenzyLeft = 1;
      e.onRoundStart();
      e.tick(2);
      e.onRoundCancelled();
      expect(e.frenzyLastRound, isFalse);
      e.onRoundStart();
      expect(e.resolveRound(great).frenzyGrace, isFalse);
    });
  });

  group('Hot hand', () {
    test('a round started in it keeps it after the timer ran out', () {
      e.hotHandLeft = 1;
      e.onRoundStart();
      e.tick(2);
      expect(e.hotHandLastRound, isTrue);
      final o = e.resolveRound(great);
      expect(o.tier, Tier.perfect);
      expect(o.hotHand, isTrue);
      expect(o.hotHandGrace, isTrue);
      expect(
        o.payout,
        closeTo(plain(const Grade(Tier.perfect, 0.02)) * hotX, 1e-6),
      );
      expect(e.hotHandLastRound, isFalse);
    });

    test('a miss stays a miss and is not grace', () {
      e.hotHandLeft = 1;
      e.onRoundStart();
      e.tick(2);
      final o = e.resolveRound(miss);
      expect(o.tier, Tier.miss);
      expect(o.hotHandGrace, isFalse);
    });

    test('a round started after it ended gets nothing', () {
      e.hotHandLeft = 1;
      e.tick(2);
      e.onRoundStart();
      final o = e.resolveRound(great);
      expect(o.hotHand, isFalse);
    });
  });

  group('the golden round with two clocks', () {
    void catchClock() {
      e.goldenVisibleLeft = 5;
      expect(e.claimGolden(), isTrue);
    }

    test('it is the round of the clock that started first after the catch', () {
      e.onRoundStart(0); // left runs already
      catchClock();
      expect(e.ticket(0).golden, isFalse);
      e.onRoundStart(1); // right starts after the catch: golden
      expect(e.ticket(1).golden, isTrue);
      expect(e.goldenRound, isTrue);
      // Left ends first: an ordinary round, it does not use up the gold.
      final left = e.resolveRound(great, clock: 0);
      expect(left.golden, isNull);
      expect(e.goldenRound, isTrue);
      // A new left round while the right one is golden is not golden.
      expect(e.onRoundStart(0).golden, isFalse);
      final right = e.resolveRound(great, clock: 1);
      expect(right.golden, isNotNull);
      expect(e.goldenRound, isFalse);
      expect(s.goldenArmed, isFalse);
    });

    test('only one clock takes it when both start after the catch', () {
      catchClock();
      expect(e.onRoundStart(0).golden, isTrue);
      expect(e.onRoundStart(1).golden, isFalse);
    });

    test('a cancelled golden round stays armed for the next one', () {
      catchClock();
      e.onRoundStart(1);
      e.onRoundCancelled(1);
      expect(e.goldenArmed, isTrue);
      expect(e.onRoundStart(0).golden, isTrue);
    });

    test('the same clock restarting keeps its own golden round', () {
      catchClock();
      expect(e.onRoundStart(0).golden, isTrue);
      expect(e.onRoundStart(0).golden, isTrue);
    });
  });
}
