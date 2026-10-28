import 'dart:io';

import 'package:test/test.dart';

/// T-3: game logic must stay plain Dart so it can be unit-tested and
/// simulated without a device.
void main() {
  const pureDirs = ['lib/model', 'lib/engine', 'lib/balance', 'lib/ads'];
  final forbidden = RegExp(
    r'''^\s*(import|export)\s+['"](package:(flutter|flame|flutter_riverpod|flutter_soloud|flutter_animate)\b|dart:ui)''',
    multiLine: true,
  );

  for (final dir in pureDirs) {
    test('$dir does not import Flutter, Flame or dart:ui', () {
      final d = Directory(dir);
      if (!d.existsSync()) return;
      final offenders = <String>[];
      for (final f in d.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final m = forbidden.firstMatch(f.readAsStringSync());
        if (m != null) offenders.add('${f.path}: ${m.group(0)!.trim()}');
      }
      expect(offenders, isEmpty);
    });
  }
}
