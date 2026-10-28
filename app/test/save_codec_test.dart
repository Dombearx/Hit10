import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:test/test.dart';

GameState sample() {
  final s = GameState()
    ..tiki = 1234.5
    ..earnedThisRun = 2000
    ..earnedTotal = 9e12
    ..chronons = 7
    ..shards = 3
    ..prestiges = 1
    ..lastSeenMs = 1700000000000
    ..playSeconds = 321.5
    ..tutorialDone = true;
  s.owned.addAll({'grandpa': 12, 'grandma': 3});
  s.upgrades['grandpa'] = 2;
  s.synergies.add('grandparents');
  s.skills.addAll({'magnet': 4});
  s.perks.add('headStart');
  s.achievements.addAll({'earned_1', 'owned_grandpa_1'});
  s.stats.record(const Grade(Tier.perfect, 0.001), tapped: true);
  s.lifetime
    ..perfects = 5
    ..bestCombo = 12;
  return s;
}

void main() {
  test('round trip keeps every field (T-17)', () {
    final settings = Settings()
      ..notation = Notation.scientific
      ..language = 'pl'
      ..haptics = false;
    final text = saveToJsonString(
      SaveData(sample(), settings, balanceVersion: 1),
    );
    final back = saveFromJsonString(text);
    expect(saveToJsonString(back), text);
    expect(back.state.owned['grandpa'], 12);
    expect(back.state.stats.byTier[Tier.perfect], 1);
    expect(back.settings.notation, Notation.scientific);
    expect(back.settings.haptics, isFalse);
  });

  test('export/import round trip (T-19)', () {
    final d = SaveData(sample(), Settings());
    final code = exportSave(d);
    expect(code, isNot(contains('{')));
    expect(saveToJsonString(importSave(code)), saveToJsonString(d));
  });

  test('rejects garbage with SaveFormatException (T-20)', () {
    for (final bad in ['', 'nope', '[]', '{}', '{"saveVersion": 99}']) {
      expect(
        () => saveFromJsonString(bad),
        throwsA(isA<SaveFormatException>()),
        reason: bad,
      );
    }
    expect(
      () => importSave('not base64!'),
      throwsA(isA<SaveFormatException>()),
    );
    expect(
      () => saveFromJsonString('{"saveVersion":1,"tiki":-5}'),
      throwsA(isA<SaveFormatException>()),
    );
  });

  test('tolerates missing optional fields', () {
    final d = saveFromJsonString('{"saveVersion":1,"tiki":5}');
    expect(d.state.tiki, 5);
    expect(d.state.owned, isEmpty);
    expect(d.settings.sfxVolume, 1);
  });

  test('memory store keeps a backup of the previous save', () async {
    final m = MemorySaveStore();
    await m.write('a');
    await m.write('b');
    expect(await m.read(), 'b');
    expect(await m.readBackup(), 'a');
  });
}
