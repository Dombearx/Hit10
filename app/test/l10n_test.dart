import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Map<String, dynamic> arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> keys(Map<String, dynamic> m) =>
    m.keys.where((k) => !k.startsWith('@')).toSet();

Set<String> placeholders(String s) =>
    RegExp(r'\{(\w+)').allMatches(s).map((m) => m.group(1)!).toSet();

/// docs/06 §1.4: both languages carry the same keys and placeholders.
void main() {
  final en = arb('en');
  final pl = arb('pl');

  test('PL and EN have the same keys', () {
    expect(keys(pl).difference(keys(en)), isEmpty, reason: 'only in PL');
    expect(keys(en).difference(keys(pl)), isEmpty, reason: 'only in EN');
  });

  test('placeholders match', () {
    for (final k in keys(en)) {
      expect(
        placeholders(pl[k] as String),
        placeholders(en[k] as String),
        reason: k,
      );
    }
  });

  test('every generator upgrade has a name and a one-liner (R-ULEP-2)', () {
    final balance = jsonDecode(
      File('assets/balance.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final g in balance['generators'] as List<dynamic>) {
      final id = (g as Map<String, dynamic>)['id'];
      for (var i = 1; i <= 8; i++) {
        for (final m in [en, pl]) {
          expect(m['upg_${id}_$i'], isA<String>(), reason: '$id $i');
          expect(m['upg_${id}_${i}_desc'], isA<String>(), reason: '$id $i');
        }
      }
    }
  });
}
