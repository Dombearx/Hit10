import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/time_map.dart';
import 'package:test/test.dart';

void main() {
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  const w = Windows(perfect: 0.005, great: 0.020, good: 0.050);
  late double start;
  late RoundEngine e;

  setUp(() {
    start = 0;
    e = RoundEngine(
      config: b.round,
      timeMapFor: () => TimeMap(start: start, zoneStart: 9.8, zoneEnd: 10.2),
      windowsFor: () => w,
    );
  });

  test('first tap starts the round and is not graded (R-RUNDA-7)', () {
    expect(e.phase, RoundPhase.waiting);
    expect(e.tap(100), isA<RoundStarted>());
    expect(e.phase, RoundPhase.running);
    expect(e.gameTime(105), closeTo(5, 1e-9));
  });

  test('taps in the grace period are ignored (R-RUNDA-4)', () {
    e.tap(100);
    expect(e.tap(100.2), isNull);
    expect(e.phase, RoundPhase.running);
  });

  test('a tap at 10.00 is perfect and freezes the stopwatch', () {
    e.tap(100);
    final ev = e.tap(110.002) as RoundGraded;
    expect(ev.grade.tier, Tier.perfect);
    expect(ev.grade.error, closeTo(0.002, 1e-9));
    expect(e.phase, RoundPhase.result);
    expect(e.gameTime(110.5), closeTo(10.002, 1e-9));
  });

  test('early tap is a miss', () {
    e.tap(100);
    final ev = e.tap(105) as RoundGraded;
    expect(ev.grade.missKind, MissKind.early);
  });

  test('no tap ends the round at exactly 10.30 (R-RUNDA-5)', () {
    e.tap(100);
    expect(e.update(110.29), isNull);
    // A late frame still ends the round at the auto-end instant.
    final ev = e.update(110.6) as RoundGraded;
    expect(ev.grade.missKind, MissKind.noTap);
    expect(ev.gameTime, closeTo(10.3, 1e-9));
    // Result pause is measured from 110.3, not from the late frame.
    expect(e.update(110.99), isNull);
    expect(e.update(111.0), isA<RoundStarted>());
    expect(e.startedAt, closeTo(111.0, 1e-9));
  });

  test(
    'taps during the result pause are ignored, next round starts itself',
    () {
      e.tap(100);
      e.tap(110);
      expect(e.tap(110.3), isNull);
      expect(e.update(110.69), isNull);
      expect(e.update(110.7), isA<RoundStarted>());
      expect(e.phase, RoundPhase.running);
      expect(e.gameTime(111.7), closeTo(1.0, 1e-9));
    },
  );

  test('upgrades apply from the next round on', () {
    e.tap(100);
    start = 5;
    expect(e.gameTime(101), closeTo(1, 1e-9)); // still old map
    e.tap(110);
    e.update(110.7);
    expect(e.gameTime(111.7), closeTo(6, 1e-9));
  });

  test('a later start shows while waiting and keeps real seconds', () {
    start = 5.8;
    expect(e.gameTime(100), 5.8);
    e.tap(100);
    final ev = e.tap(104.2) as RoundGraded;
    expect(ev.grade.tier, Tier.perfect);
  });

  test('cancel returns to waiting without grading (R-RUNDA-8)', () {
    e.tap(100);
    e.cancel();
    expect(e.phase, RoundPhase.waiting);
    expect(e.update(200), isNull);
    expect(e.gameTime(200), 0);
  });
}
