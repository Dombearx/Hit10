import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Code points mapped by a TrueType font's Unicode cmap (formats 4 and 12).
Set<int> _cmap(String path) {
  final b = ByteData.sublistView(File(path).readAsBytesSync());
  final tables = b.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < tables; i++) {
    final rec = 12 + 16 * i;
    if (String.fromCharCodes(List.generate(4, (k) => b.getUint8(rec + k))) ==
        'cmap') {
      cmap = b.getUint32(rec + 8);
    }
  }
  expect(cmap, isNot(-1), reason: '$path has no cmap');
  final out = <int>{};
  final subtables = b.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final at = cmap + b.getUint32(cmap + 4 + 8 * i + 4);
    switch (b.getUint16(at)) {
      case 4:
        final segs = b.getUint16(at + 6) ~/ 2;
        final ends = at + 14;
        final starts = ends + 2 * segs + 2;
        final deltas = starts + 2 * segs;
        final ranges = deltas + 2 * segs;
        for (var s = 0; s < segs; s++) {
          final end = b.getUint16(ends + 2 * s);
          final start = b.getUint16(starts + 2 * s);
          final delta = b.getInt16(deltas + 2 * s);
          final range = b.getUint16(ranges + 2 * s);
          for (var c = start; c <= end && c != 0xFFFF; c++) {
            final glyph = range == 0
                ? (c + delta) & 0xFFFF
                : b.getUint16(ranges + 2 * s + range + 2 * (c - start));
            if (glyph != 0) out.add(c);
          }
        }
      case 12:
        final groups = b.getUint32(at + 12);
        for (var g = 0; g < groups; g++) {
          final rec = at + 16 + 12 * g;
          for (var c = b.getUint32(rec); c <= b.getUint32(rec + 4); c++) {
            out.add(c);
          }
        }
    }
  }
  return out;
}

void main() {
  // Every character the translations use must be in both fonts, or the
  // device swaps in a system font mid-word (found in M4: "WCZEŚNIE").
  test('both fonts cover every character in the translations', () {
    final used = <int>{};
    for (final f in ['lib/l10n/app_pl.arb', 'lib/l10n/app_en.arb']) {
      final arb = jsonDecode(File(f).readAsStringSync()) as Map;
      for (final e in arb.entries) {
        if (e.key.toString().startsWith('@') || e.value is! String) continue;
        // Placeholders like {count} are filled with digits at runtime.
        final text = (e.value as String).replaceAll(RegExp(r'\{\w+\}'), '');
        used.addAll(text.runes.where((r) => r > 0x20 && r < 0x2000));
      }
    }
    for (final font in [
      'assets/fonts/PaytoneOne-Regular.ttf',
      'assets/fonts/Nunito-400.ttf',
      'assets/fonts/Nunito-800.ttf',
    ]) {
      final missing = used.difference(_cmap(font));
      expect(
        missing.map(String.fromCharCode).join(),
        isEmpty,
        reason: '$font lacks these characters',
      );
    }
  });
}
