import 'package:hit10/model/grading.dart';
import 'package:test/test.dart';

void main() {
  const w = Windows(perfect: 0.005, great: 0.020, good: 0.050);

  test('tiers from narrowest to widest (R-PROG-1)', () {
    expect(grade(0, w).tier, Tier.perfect);
    expect(grade(0.004999, w).tier, Tier.perfect);
    expect(grade(-0.004999, w).tier, Tier.perfect);
    expect(grade(0.005, w).tier, Tier.great); // boundary is exclusive
    expect(grade(0.019999, w).tier, Tier.great);
    expect(grade(-0.020, w).tier, Tier.good);
    expect(grade(0.049999, w).tier, Tier.good);
    expect(grade(0.050, w).tier, Tier.miss);
  });

  test('misses know whether they were early or late (R-RUNDA-5)', () {
    expect(grade(-0.3, w).missKind, MissKind.early);
    expect(grade(0.06, w).missKind, MissKind.late);
    expect(grade(0.001, w).missKind, isNull);
  });

  test('perfect never outgrows great (R-PROG-2)', () {
    const bad = Windows(perfect: 0.03, great: 0.02, good: 0.05);
    expect(grade(0.025, bad).tier, Tier.good);
    expect(grade(0.019, bad).tier, Tier.perfect);
  });
}
