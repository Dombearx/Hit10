import 'dart:convert';

import 'package:archive/archive.dart';

import '../model/game_state.dart';
import '../model/grading.dart';
import '../model/number_format.dart';
import '../model/settings.dart';

class SaveFormatException implements Exception {
  SaveFormatException(this.message);
  final String message;
  @override
  String toString() => 'SaveFormatException: $message';
}

/// Current save format; bump and add a migration for every change (T-17).
const saveVersion = 1;

/// One migration per version step: `migrations[n]` turns a vN map into
/// v(n+1). Empty until the format first changes.
final Map<int, Map<String, Object?> Function(Map<String, Object?>)> migrations =
    {};

class SaveData {
  SaveData(this.state, this.settings, {this.balanceVersion = 0});
  final GameState state;
  final Settings settings;

  /// Balance file version the save was written with (T-7, diagnostics).
  final int balanceVersion;
}

Map<String, Object?> encodeSave(SaveData d) {
  final s = d.state;
  final st = d.settings;
  final l = s.lifetime;
  return {
    'saveVersion': saveVersion,
    'balanceVersion': d.balanceVersion,
    'tiki': s.tiki,
    'earnedThisRun': s.earnedThisRun,
    'earnedTotal': s.earnedTotal,
    'owned': s.owned,
    'upgrades': s.upgrades,
    'synergies': s.synergies.toList(),
    'skills': s.skills,
    'peakTiki': s.peakTiki,
    'chronons': s.chronons,
    'shards': s.shards,
    'perks': s.perks.toList(),
    'achievements': s.achievements.toList(),
    'prestiges': s.prestiges,
    'lastSeenMs': s.lastSeenMs,
    'playSeconds': s.playSeconds,
    'tutorialDone': s.tutorialDone,
    'stats': {
      'rounds': s.stats.rounds,
      'byTier': {for (final e in s.stats.byTier.entries) e.key.name: e.value},
      'recentErrors': s.stats.recentErrors,
    },
    'lifetime': {
      'earnedEver': l.earnedEver,
      'perfects': l.perfects,
      'perfectStreak': l.perfectStreak,
      'bestPerfectStreak': l.bestPerfectStreak,
      'bestCombo': l.bestCombo,
      'earlyTaps': l.earlyTaps,
      'missedInARow': l.missedInARow,
      'goldenCaught': l.goldenCaught,
      'secondsPlayed': l.secondsPlayed,
    },
    'settings': {
      'sfxVolume': st.sfxVolume,
      'musicVolume': st.musicVolume,
      'haptics': st.haptics,
      'language': st.language,
      'notation': st.notation.name,
      'reduceMotion': st.reduceMotion,
      'notifications': st.notifications,
    },
  };
}

SaveData decodeSave(Map<String, Object?> raw) {
  var j = raw;
  final from = (j['saveVersion'] as num?)?.toInt();
  if (from == null) throw SaveFormatException('no saveVersion');
  if (from > saveVersion) {
    throw SaveFormatException(
      'save is newer ($from) than the app ($saveVersion)',
    );
  }
  for (var v = from; v < saveVersion; v++) {
    final m = migrations[v];
    if (m == null) throw SaveFormatException('no migration from v$v');
    j = m(j);
  }
  try {
    return _decodeCurrent(j);
  } on SaveFormatException {
    rethrow;
  } on Object catch (e) {
    throw SaveFormatException('corrupt save: $e');
  }
}

double _d(Object? v, [double fallback = 0]) =>
    v is num && v.isFinite ? v.toDouble() : fallback;
int _i(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
Map<String, Object?> _m(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};
List<String> _sl(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];

SaveData _decodeCurrent(Map<String, Object?> j) {
  final s = GameState()
    ..tiki = _d(j['tiki'])
    ..earnedThisRun = _d(j['earnedThisRun'])
    ..earnedTotal = _d(j['earnedTotal'])
    ..peakTiki = _d(j['peakTiki'])
    ..chronons = _i(j['chronons'])
    ..shards = _i(j['shards'])
    ..prestiges = _i(j['prestiges'])
    ..lastSeenMs = _i(j['lastSeenMs'])
    ..playSeconds = _d(j['playSeconds'])
    ..tutorialDone = j['tutorialDone'] == true;
  _m(j['owned']).forEach((k, v) => s.owned[k] = _i(v));
  _m(j['upgrades']).forEach((k, v) => s.upgrades[k] = _i(v));
  _m(j['skills']).forEach((k, v) => s.skills[k] = _i(v));
  s.synergies.addAll(_sl(j['synergies']));
  s.perks.addAll(_sl(j['perks']));
  s.achievements.addAll(_sl(j['achievements']));
  final stats = _m(j['stats']);
  s.stats.rounds = _i(stats['rounds']);
  _m(stats['byTier']).forEach((k, v) {
    for (final t in Tier.values) {
      if (t.name == k) s.stats.byTier[t] = _i(v);
    }
  });
  final errors = stats['recentErrors'];
  if (errors is List) s.stats.recentErrors.addAll(errors.map((e) => _d(e)));
  final l = _m(j['lifetime']);
  s.lifetime
    ..earnedEver = _d(l['earnedEver'])
    ..perfects = _i(l['perfects'])
    ..perfectStreak = _i(l['perfectStreak'])
    ..bestPerfectStreak = _i(l['bestPerfectStreak'])
    ..bestCombo = _i(l['bestCombo'])
    ..earlyTaps = _i(l['earlyTaps'])
    ..missedInARow = _i(l['missedInARow'])
    ..goldenCaught = _i(l['goldenCaught'])
    ..secondsPlayed = _d(l['secondsPlayed']);
  final st = _m(j['settings']);
  final settings = Settings()
    ..sfxVolume = _d(st['sfxVolume'], 1)
    ..musicVolume = _d(st['musicVolume'], 0.4)
    ..haptics = st['haptics'] != false
    ..language = st['language'] is String ? st['language'] as String : null
    ..notation = st['notation'] == Notation.scientific.name
        ? Notation.scientific
        : Notation.short
    ..reduceMotion = st['reduceMotion'] == true
    ..notifications = st['notifications'] != false;
  if (s.tiki < 0 || s.earnedTotal < 0) {
    throw SaveFormatException('negative money');
  }
  return SaveData(s, settings, balanceVersion: _i(j['balanceVersion']));
}

String saveToJsonString(SaveData d) => jsonEncode(encodeSave(d));

SaveData saveFromJsonString(String text) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException catch (e) {
    throw SaveFormatException('not JSON: ${e.message}');
  }
  if (decoded is! Map) throw SaveFormatException('not an object');
  return decodeSave(decoded.cast<String, Object?>());
}

/// Export string: JSON → gzip → base64 (T-19).
String exportSave(SaveData d) =>
    base64Encode(const GZipEncoder().encode(utf8.encode(saveToJsonString(d))));

SaveData importSave(String text) {
  final List<int> bytes;
  try {
    bytes = const GZipDecoder().decodeBytes(base64Decode(text.trim()));
  } on Object {
    throw SaveFormatException('not an exported save');
  }
  return saveFromJsonString(utf8.decode(bytes));
}
