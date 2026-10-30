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
      timeMapFor: () => TimeMap(start: start, zoneStart: 4.8, zoneEnd: 5.2),
      windowsFor: () => w,
    );
  });

  test('first tap starts the round and is not graded (R-RUNDA-7)', () {
    expect(e.phase, RoundPhase.waiting);
    expect(e.tap(100), isA<RoundStarted>());
    expect(e.phase, RoundPhase.running);
    expect(e.gameTime(103), closeTo(3, 1e-9));
  });

  test('taps in the grace period are ignored (R-RUNDA-4)', () {
    e.tap(100);
    expect(e.tap(100.2), isNull);
    expect(e.phase, RoundPhase.running);
  });

  test('a tap at 5.00 is perfect and freezes the stopwatch', () {
    e.tap(100);
    final ev = e.tap(105.002) as RoundGraded;
    expect(ev.grade.tier, Tier.perfect);
    expect(ev.grade.error, closeTo(0.002, 1e-9));
    expect(e.phase, RoundPhase.result);
    expect(e.gameTime(105.5), closeTo(5.002, 1e-9));
  });

  test('early tap is a miss', () {
    e.tap(100);
    final ev = e.tap(103) as RoundGraded;
    expect(ev.grade.missKind, MissKind.early);
  });

  test('no tap ends the round at exactly 5.30 (R-RUNDA-5)', () {
    e.tap(100);
    expect(e.update(105.29), isNull);
    // A late frame still ends the round at the auto-end instant.
    final ev = e.update(105.6) as RoundGraded;
    expect(ev.grade.missKind, MissKind.noTap);
    expect(ev.gameTime, closeTo(5.3, 1e-9));
    // Result pause is measured from 105.3, not from the late frame.
    expect(e.update(105.99), isNull);
    expect(e.update(106.0), isA<RoundStarted>());
    expect(e.startedAt, closeTo(106.0, 1e-9));
  });

  test(
    'taps during the result pause are ignored, next round starts itself',
    () {
      e.tap(100);
      e.tap(105);
      expect(e.tap(105.3), isNull);
      expect(e.update(105.69), isNull);
      expect(e.update(105.7), isA<RoundStarted>());
      expect(e.phase, RoundPhase.running);
      expect(e.gameTime(106.7), closeTo(1.0, 1e-9));
    },
  );

  test('upgrades apply from the next round on', () {
    e.tap(100);
    start = 0.5;
    expect(e.gameTime(101), closeTo(1, 1e-9)); // still old map
    e.tap(105);
    e.update(105.7);
    expect(e.gameTime(106.7), closeTo(1.5, 1e-9));
  });

  test('a later start shows while waiting and keeps real seconds', () {
    start = 0.8;
    expect(e.gameTime(100), 0.8);
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
