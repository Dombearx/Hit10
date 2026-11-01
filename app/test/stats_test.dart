import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:test/test.dart';

/// R-STAT-1 after the playtest: stray taps don't swamp the figures.
void main() {
  test('typical error and bias come from taps near the target', () {
    final st = RoundStats();
    for (final e in [-0.010, 0.020, -0.030, 0.040, -0.050]) {
      st.record(Grade(Tier.good, e), tapped: true);
    }
    // Three slips seconds off the target.
    for (final e in [-3.1, -2.7, -3.4]) {
      st.record(Grade(Tier.miss, e, MissKind.early), tapped: true);
    }
    expect(st.typicalError, closeTo(0.030, 1e-12)); // median of |e|
    expect(st.meanError, closeTo(-0.006, 1e-12));
    expect(st.spread, lessThan(0.05)); // not ~1.5 s
  });
}
