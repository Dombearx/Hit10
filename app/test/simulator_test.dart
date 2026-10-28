import 'package:hit10/sim/simulator.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Smoke test of the simulator; the full pacing check runs in CI via
/// `dart run tool/simulate.dart --check` (docs/06 §1.2).
void main() {
  final b = loadBalance();

  test('one simulated hour is deterministic and progresses', () {
    final a = Simulator(b, const SimConfig(hours: 1, seed: 3)).run();
    final c = Simulator(b, const SimConfig(hours: 1, seed: 3)).run();
    expect(a.state.earnedTotal, c.state.earnedTotal);
    expect(
      a.firstGenerator.keys,
      containsAll(['grandpa', 'grandma', 'cuckoo']),
    );
    expect(a.state.skills.values.fold<int>(0, (x, y) => x + y), greaterThan(5));
    expect(a.hourly, hasLength(1));
  });

  test('avgStreak matches the closed form at the extremes', () {
    expect(Simulator.avgStreak(1, 0, 25), 25);
    expect(Simulator.avgStreak(0, 0.1, 25), 0);
    // Never reaches the cap: mean of k·inc over a geometric cycle.
    expect(Simulator.avgStreak(1, 0.5, 1000), closeTo(1, 1e-9));
  });
}
