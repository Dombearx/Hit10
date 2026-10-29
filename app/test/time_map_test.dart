import 'package:hit10/model/time_map.dart';
import 'package:test/test.dart';

void main() {
  const eps = 1e-9;

  test('identity when nothing is upgraded', () {
    final m = TimeMap(zoneStart: 9.8, zoneEnd: 10.2);
    for (final t in <double>[0, 1.5, 9, 9.9, 10, 10.3, 15]) {
      expect(m.gameAt(t), closeTo(t, eps));
      expect(m.realAt(t), closeTo(t, eps));
    }
  });

  test('Start później starts later at the same tempo (R-RUNDA-10)', () {
    final m = TimeMap(start: 5.8, zoneStart: 9.8, zoneEnd: 10.2);
    expect(m.gameAt(0), 5.8);
    expect(m.realAt(10), closeTo(4.2, eps));
    // One real second is one stopwatch second everywhere.
    expect(m.gameAt(4.0) - m.gameAt(3.0), closeTo(1, eps));
    expect(m.realAt(3), 0);
  });

  test('the focus zone surrounds the target (R-RUNDA-11)', () {
    final m = TimeMap(zoneStart: 9.8, zoneEnd: 10.2);
    expect(m.inFocusZone(9.9), isTrue);
    expect(m.inFocusZone(10.2), isFalse);
  });

  test('round trip for every combination', () {
    for (final s in <double>[0, 3, 5.8]) {
      final m = TimeMap(start: s, zoneStart: 9.8, zoneEnd: 10.2);
      for (var g = s + 0.01; g < 12; g += 0.0137) {
        expect(m.gameAt(m.realAt(g)), closeTo(g, 1e-9));
      }
    }
  });
}
