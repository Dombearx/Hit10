import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/arena/golden_clock.dart';

/// R-ZLOTA-6: a golden clock saved mid-flight goes on from where it was
/// after a restart, at its usual speed (playtest: it started over from the
/// edge and crossed the screen in the few seconds it had left).
void main() {
  GoldenClock clock({double elapsed = 0}) => GoldenClock(
    arenaSize: Vector2(400, 800),
    dialTop: 300,
    radius: 20,
    life: 12,
    fromLeft: true,
    elapsed: elapsed,
  );

  test('a resumed clock starts where the flight was, not at the edge', () {
    final fresh = clock();
    final resumed = clock(elapsed: 9);
    expect(resumed.position.x, closeTo(fresh.at(9).x, 1e-9));
    expect(resumed.position.x, greaterThan(fresh.at(0).x + 200));
  });

  test('a resumed clock keeps the usual speed', () {
    final fresh = clock()..update(1);
    final resumed = clock(elapsed: 9);
    final x0 = resumed.position.x;
    resumed.update(1);
    expect(
      resumed.position.x - x0,
      closeTo(fresh.position.x - fresh.at(0).x, 1e-3),
    );
  });
}
