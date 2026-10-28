import 'dart:convert';
import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:test/test.dart';

String repoBalance() => File('assets/balance.json').readAsStringSync();

/// Applies [edit] to a fresh decoded copy of the repo balance file.
String mutated(void Function(Map<String, dynamic> j) edit) {
  final j = jsonDecode(repoBalance()) as Map<String, dynamic>;
  edit(j);
  return jsonEncode(j);
}

Matcher throwsBalance(String fragment) => throwsA(
  isA<BalanceException>().having(
    (e) => e.errors.join('\n'),
    'errors',
    contains(fragment),
  ),
);

void main() {
  test('the balance file in the repo is valid (T-6)', () {
    final b = Balance.fromJsonString(repoBalance());
    expect(b.generators, hasLength(14));
    expect(b.skills, hasLength(11));
    expect(b.prestige.perks, hasLength(16));
    expect(b.synergies, hasLength(6));
    expect(b.tier('perfect').window, 0.005);
  });

  test('numbers match the tuned design values (docs/02, 03)', () {
    final b = Balance.fromJsonString(repoBalance());
    expect(b.skill('echo').perLevel, 0.5);
    expect(b.combo.multiplierPerStep, 0.05);
    expect(b.skill('combo').perLevel, 2);
    expect(b.golden.intervalMin, 300);
    expect(b.golden.intervalMax, 900);
    expect(b.prestige.divisor, 1e8);
    expect(b.prestige.bonusPerChronon, 0.02);
    expect(b.ads.turboDuration, 1800);
  });

  group('rejects broken files with a readable message', () {
    test('not JSON', () {
      expect(
        () => Balance.fromJsonString('{oops'),
        throwsBalance('not valid JSON'),
      );
    });
    test('missing field', () {
      expect(
        () => Balance.fromJsonString(mutated((j) => j.remove('round'))),
        throwsBalance('missing or mistyped'),
      );
    });
    test('duplicate generator id', () {
      expect(
        () => Balance.fromJsonString(
          mutated((j) => (j['generators'] as List)[1]['id'] = 'grandpa'),
        ),
        throwsBalance('duplicate generator id "grandpa"'),
      );
    });
    test('perfect window could outgrow great (R-PROG-2)', () {
      expect(
        () => Balance.fromJsonString(
          mutated((j) {
            final magnet = (j['skills'] as List).firstWhere(
              (s) => s['id'] == 'magnet',
            );
            magnet['perLevel'] = 0.01;
          }),
        ),
        throwsBalance('max perfect window'),
      );
    });
    test('unknown synergy partner', () {
      expect(
        () => Balance.fromJsonString(
          mutated((j) => (j['synergies'] as List)[0]['b'] = 'nobody'),
        ),
        throwsBalance('unknown generator "nobody"'),
      );
    });
    test('unknown required perk', () {
      expect(
        () => Balance.fromJsonString(
          mutated((j) => (j['generators'] as List).last['requiresPerk'] = 'x'),
        ),
        throwsBalance('requires unknown perk "x"'),
      );
    });
    test('generators out of price order', () {
      expect(
        () => Balance.fromJsonString(
          mutated((j) => (j['generators'] as List)[2]['baseCost'] = 1),
        ),
        throwsBalance('must cost more than the previous one'),
      );
    });
  });
}
