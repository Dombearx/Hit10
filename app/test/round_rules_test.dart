import 'dart:math' as math;

import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Random that returns a fixed sequence (loops).
class SeqRandom implements math.Random {
  SeqRandom(this.values);
  final List<double> values;
  int _i = 0;
  @override
  double nextDouble() => values[_i++ % values.length];
  @override
  int nextInt(int max) => (nextDouble() * max).floor();
  @override
  bool nextBool() => nextDouble() < 0.5;
}

const perfect = Grade(Tier.perfect, 0);
const great = Grade(Tier.great, 0.01);
const good = Grade(Tier.good, 0.04);
const early = Grade(Tier.miss, -1, MissKind.early);
const noTap = Grade(Tier.miss, 0.3, MissKind.noTap);

void main() {
  final b = loadBalance();
  late GameState s;
  late GameEngine e;

  GameEngine make(List<double> rolls) =>
      GameEngine(b, s, random: SeqRandom(rolls));

  setUp(() {
    s = GameState();
    e = make([0.99]);
  });

  group('combo (R-COMBO-1…3)', () {
    test('steps: perfect +2, great +1, good keeps, miss resets', () {
      expect(e.resolveRound(perfect).streak, 2);
      expect(e.resolveRound(great).streak, 3);
      expect(e.resolveRound(good).streak, 3);
      final miss = e.resolveRound(early);
      expect(miss.streak, 0);
      expect(miss.comboBroken, isTrue);
    });

    test('capped at 5 + 2·level; multiplier 1 + 0.05·streak', () {
      for (var i = 0; i < 10; i++) {
        e.resolveRound(perfect);
      }
      expect(s.comboStreak, 5);
      s.skills['combo'] = 3;
      for (var i = 0; i < 10; i++) {
        e.resolveRound(perfect);
      }
      expect(s.comboStreak, 11);
      expect(e.resolveRound(perfect).combo, closeTo(1 + 0.05 * 11, 1e-12));
    });

    test('combo multiplies the whole payout including echo (R-COMBO-3)', () {
      s.stats.rounds = 30; // past beginner's luck
      s.owned['grandma'] = 10;
      s.skills.addAll({'echo': 2, 'combo': 10});
      s.comboStreak = 8; // → 10 after this perfect
      final o = e.resolveRound(perfect);
      expect(o.payout, closeTo((10 + 1 * 1.0 * 10) * 1.5, 1e-9));
    });

    test('shield absorbs a miss and recharges every 10 steps', () {
      s.skills['shield'] = 1;
      s.shieldCharges = 1;
      s.comboStreak = 4;
      final o = e.resolveRound(early);
      expect(o.shieldUsed, isTrue);
      expect(s.comboStreak, 4);
      expect(s.shieldCharges, 0);
      for (var i = 0; i < 5; i++) {
        e.resolveRound(perfect); // 10 steps
      }
      expect(s.shieldCharges, 1);
    });

    test('combo floor perk keeps 5 after a miss', () {
      s.perks.add('comboFloor');
      s.skills['combo'] = 5;
      s.comboStreak = 12;
      e.resolveRound(early);
      expect(s.comboStreak, 5);
    });
  });

  group('luck and hot hand', () {
    test('luck bumps great→perfect, good→great, never a miss', () {
      s.skills['luck'] = 10; // 20 %
      e = make([0.1]);
      expect(e.resolveRound(great).tier, Tier.perfect);
      expect(e.resolveRound(good).tier, Tier.great);
      expect(e.resolveRound(early).tier, Tier.miss);
      e = make([0.5]);
      expect(e.resolveRound(great).tier, Tier.great);
    });

    test('hot hand turns every hit into perfect', () {
      e.hotHandLeft = 10;
      expect(e.resolveRound(good).tier, Tier.perfect);
      expect(e.resolveRound(early).tier, Tier.miss);
    });
  });

  test('lifetime stats for achievements', () {
    e.resolveRound(perfect);
    e.resolveRound(perfect);
    e.resolveRound(great);
    e.resolveRound(early);
    e.resolveRound(noTap);
    e.resolveRound(noTap);
    final l = s.lifetime;
    expect(l.perfects, 2);
    expect(l.bestPerfectStreak, 2);
    expect(l.perfectStreak, 0);
    expect(l.earlyTaps, 1);
    expect(l.missedInARow, 2);
    expect(s.stats.recentErrors, hasLength(4)); // no-taps not recorded
  });

  group('golden second (R-ZLOTA-1…5)', () {
    test('appears after the interval, flies away after 12 s', () {
      final next = s.goldenNextAt;
      expect(next, inInclusiveRange(300, 900));
      s.playSeconds = next;
      expect(e.updateEffects(0.1), isTrue);
      expect(e.goldenVisibleLeft, 12);
      e.updateEffects(12);
      expect(e.goldenVisibleLeft, 0);
      expect(s.goldenNextAt, greaterThan(next));
    });

    test('caught → next round golden → effect scaled by tier', () {
      e = make([0.0]); // first effect in the list: frenzy
      e.summonGolden();
      expect(e.claimGolden(), isTrue);
      e.onRoundStart();
      expect(e.goldenRound, isTrue);
      final o = e.resolveRound(great);
      expect(o.golden!.effect, GoldenEffect.frenzy);
      expect(o.golden!.amount, closeTo(77 * 0.6, 1e-9));
      expect(e.frenzy, 7);
      e.updateEffects(77 * 0.6);
      expect(e.frenzy, 1);
    });

    test('lucky pays min(600 s of income, 10 % of bank)', () {
      e = make([0.5]); // middle of the weights: lucky
      s.owned['grandma'] = 1; // 1/s → 600
      s.tiki = 1e6; // 10 % = 100 000
      e.summonGolden();
      e.claimGolden();
      e.onRoundStart();
      final o = e.resolveRound(perfect);
      expect(o.golden!.effect, GoldenEffect.lucky);
      expect(o.golden!.amount, closeTo(600, 1e-6));
    });

    test('a miss lets it escape', () {
      e.summonGolden();
      e.claimGolden();
      e.onRoundStart();
      expect(e.resolveRound(early).golden!.effect, isNull);
    });

    test('pausing a golden round keeps it armed', () {
      e.summonGolden();
      e.claimGolden();
      e.onRoundStart();
      e.onRoundCancelled();
      expect(e.goldenArmed, isTrue);
      expect(e.goldenRound, isFalse);
    });

    test('disabled during the tutorial', () {
      e.goldenEnabled = false;
      s.playSeconds = s.goldenNextAt + 1;
      expect(e.updateEffects(0.1), isFalse);
    });
  });
}
