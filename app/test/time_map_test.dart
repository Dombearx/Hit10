import 'package:hit10/model/time_map.dart';
import 'package:test/test.dart';

void main() {
  const eps = 1e-9;

  test('identity when nothing is upgraded', () {
    final m = TimeMap(fastForwardEnd: 9, zoneStart: 9.8, zoneEnd: 10.2);
    for (final t in <double>[0, 1.5, 9, 9.9, 10, 10.3, 15]) {
      expect(m.gameAt(t), closeTo(t, eps));
      expect(m.realAt(t), closeTo(t, eps));
    }
  });

  test('fast forward compresses the start (R-RUNDA-10)', () {
    final m = TimeMap(
      fastForwardEnd: 9,
      zoneStart: 9.8,
      zoneEnd: 10.2,
      fastForward: 6,
    );
    expect(m.realAt(9), closeTo(1.5, eps));
    expect(m.gameAt(1.5), closeTo(9, eps));
    expect(m.realAt(10), closeTo(2.5, eps));
  });

  test('bullet time stretches the zone (R-RUNDA-11/12)', () {
    final m = TimeMap(
      fastForwardEnd: 9,
      zoneStart: 9.8,
      zoneEnd: 10.2,
      zoneSpeed: 0.4,
    );
    // 9.8 → 10.0 takes 0.2 / 0.4 = 0.5 s of real time.
    expect(m.realAt(10) - m.realAt(9.8), closeTo(0.5, eps));
    // A ±0.005 game window is ±0.0125 s for the finger.
    expect(m.realAt(10.005) - m.realAt(9.995), closeTo(0.025, eps));
    expect(m.inBulletZone(9.9), isTrue);
    expect(m.inBulletZone(10.2), isFalse);
  });

  test('fast clock speeds everything up', () {
    final m = TimeMap(
      fastForwardEnd: 9,
      zoneStart: 9.8,
      zoneEnd: 10.2,
      clock: 1.5,
    );
    expect(m.realAt(10), closeTo(10 / 1.5, eps));
  });

  test('round trip and continuity for every combination', () {
    for (final ff in <double>[1, 3.5, 6]) {
      for (final zs in [1.0, 0.7, 0.4]) {
        for (final c in [1.0, 1.5]) {
          final m = TimeMap(
            fastForwardEnd: 9,
            zoneStart: 9.8,
            zoneEnd: 10.2,
            fastForward: ff,
            zoneSpeed: zs,
            clock: c,
          );
          double prev = -1;
          for (var g = 0.0; g < 12; g += 0.0137) {
            final r = m.realAt(g);
            expect(m.gameAt(r), closeTo(g, 1e-9));
            expect(r, greaterThan(prev)); // strictly increasing
            prev = r;
          }
          for (final edge in [9.0, 9.8, 10.2]) {
            expect(
              m.gameAt(m.realAt(edge) - 1e-12),
              closeTo(edge, 1e-6),
              reason: 'continuous at $edge',
            );
          }
        }
      }
    }
  });
}
