import 'dart:convert';
import 'dart:math' as math;

import 'package:archive/archive.dart';

import '../model/challenges.dart';
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
const saveVersion = 3;

/// One migration per version step: `migrations[n]` turns a vN map into
/// v(n+1).
final Map<int, Map<String, Object?> Function(Map<String, Object?>)> migrations =
    {1: _toV2, 2: _toV3};

/// Faces that were unlocked by Tiki earned before they became the seals'
/// trophies (docs/13 §5.5): whoever had one keeps it.
const _oldDialThresholds = {
  'quartz': 1e18,
  'atomic': 1e20,
  'neon': 5e21,
  'cosmic': 6e22,
  'golden': 3e23,
  'rift': 1e24,
};

/// v1 → v2 (docs/13): clock levels became mastery tiers with other prices,
/// so every Mainspring spent comes back; Time Loops start with what the
/// game so far holds.
Map<String, Object?> _toV2(Map<String, Object?> j) {
  final out = Map<String, Object?>.of(j);
  var refund = 0;
  _m(j['clockLevels']).forEach((_, v) {
    final level = _i(v);
    refund += level * (level + 1) ~/ 2; // level N cost N
  });
  final lifetime = _m(j['lifetime']);
  final seen = [
    ..._sl(j['dialsSeen']),
    // A save from before the faces: they are not news (see _decodeCurrent).
    if (!j.containsKey('dialsSeen')) '*',
  ];
  _oldDialThresholds.forEach((id, need) {
    if (_d(lifetime['earnedEver']) >= need && !seen.contains(id)) seen.add(id);
  });
  return out
    ..['saveVersion'] = 2
    ..['clockLevels'] = <String, Object?>{}
    ..['springs'] = _i(j['springs']) + refund
    ..['springsRefunded'] = refund
    ..['dialsSeen'] = seen
    ..['loopPlaySeconds'] = _d(lifetime['secondsPlayed'])
    ..['loopPrestiges'] = _i(j['prestiges']);
}

/// v2 → v3 (docs/15): the combo became a multiplier that stops at its cap
/// (5 + 2 per Combo level, 5 under "Short fuse"); the old streak counted
/// on past it. The streak and its record are cut to the cap.
Map<String, Object?> _toV3(Map<String, Object?> j) {
  final out = Map<String, Object?>.of(j);
  final shortFuse = _sl(j['loopRules']).contains('shortFuse');
  final cap = shortFuse ? 5 : 5 + 2 * _i(_m(j['skills'])['combo']);
  final lifetime = Map<String, Object?>.of(_m(j['lifetime']));
  if (_i(lifetime['bestCombo']) > cap) lifetime['bestCombo'] = cap;
  return out
    ..['saveVersion'] = 3
    ..['comboStreak'] = math.min(_i(j['comboStreak']), cap)
    ..['lifetime'] = lifetime;
}

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
    'skills': s.skills,
    'peakTiki': s.peakTiki,
    'chronons': s.chronons,
    'shards': s.shards,
    'perks': s.perks.toList(),
    'habits': s.habits,
    'achievements': s.achievements.toList(),
    'prestiges': s.prestiges,
    'rewindPending': s.rewindPending,
    'lastSeenMs': s.lastSeenMs,
    'offlineAway': s.offlineAway,
    'offlineCounted': s.offlineCounted,
    'offlineAmount': s.offlineAmount,
    'playSeconds': s.playSeconds,
    'tutorialDone': s.tutorialDone,
    'comboStreak': s.comboStreak,
    'shieldCharges': s.shieldCharges,
    'shieldProgress': s.shieldProgress,
    'goldenNextAt': s.goldenNextAt,
    'modeBlind': s.modeBlind,
    'secondClockOn': s.secondClockOn,
    'autoBuyerOn': s.autoBuyerOn,
    'tipsSeen': s.tipsSeen.toList(),
    'adCooldownUntil': s.adCooldownUntil,
    'turboLeft': s.turboLeft,
    'dailyKey': s.dailyKey,
    'dailyStreak': s.dailyStreak,
    'dailyGraceUsed': s.dailyGraceUsed,
    'challengeDay': s.challengeDay,
    'challengeWeek': s.challengeWeek,
    'challengeRerollDay': s.challengeRerollDay,
    'challengeBonusDay': s.challengeBonusDay,
    'tutorialEndPlay': s.tutorialEndPlay,
    'challenges': [for (final c in s.challenges) c.toJson()],
    'seasonKey': s.seasonKey,
    'seasonCatches': s.seasonCatches,
    'seasonHits': s.seasonHits,
    'seasonsDone': s.seasonsDone.toList(),
    'seasonStash': s.seasonStash,
    'theme': s.theme,
    'runTaps': s.runTaps,
    'springs': s.springs,
    'springProgress': s.springProgress,
    'springClockMs': s.springClockMs,
    'springReserve': s.springReserve,
    'springReserveMs': s.springReserveMs,
    'springAdDay': s.springAdDay,
    'springAdCount': s.springAdCount,
    'clockLevels': s.clockLevels,
    'springsRefunded': s.springsRefunded,
    'loop': s.loop,
    'loopRules': s.loopRules,
    'seals': s.seals.toList(),
    'loopsDone': s.loopsDone,
    'loopGoal': s.loopGoal,
    'loopEndSeen': s.loopEndSeen,
    'loopBonusPaid': s.loopBonusPaid,
    'loopPlaySeconds': s.loopPlaySeconds,
    'loopPrestiges': s.loopPrestiges,
    'loopStartMs': s.loopStartMs,
    'loopGoalSeconds': s.loopGoalSeconds,
    'loopBest': s.loopBest,
    'nextRules': s.nextRules,
    'everOwned': s.everOwned.toList(),
    'dial': s.dial,
    'dialsSeen': s.dialsSeen.toList(),
    'stats': {
      'rounds': s.stats.rounds,
      'byTier': {for (final e in s.stats.byTier.entries) e.key.name: e.value},
      'recentErrors': s.stats.recentErrors,
      'accidental': s.stats.accidental,
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
      'tenthDayPerfects': l.tenthDayPerfects,
      'tenthDayKey': l.tenthDayKey,
      'exactHits': l.exactHits,
      'blindPerfects': l.blindPerfects,
      'bothClocksPerfects': l.bothClocksPerfects,
      'dailyClaims': l.dailyClaims,
      'challengesDone': l.challengesDone,
      'shieldSaves': l.shieldSaves,
      'goldenFast': l.goldenFast,
      'goldenInFrenzy': l.goldenInFrenzy,
      'offlineFull': l.offlineFull,
      'springsWound': l.springsWound,
      'springSecondsLost': l.springSecondsLost,
    },
    'settings': {
      'sfxVolume': st.sfxVolume,
      'musicVolume': st.musicVolume,
      'haptics': st.haptics,
      'language': st.language,
      'notation': st.notation.name,
      'reduceMotion': st.reduceMotion,
      'notifications': st.notifications,
      'analytics': st.analytics,
      'analyticsAsked': st.analyticsAsked,
      'inputOffsetMs': st.inputOffsetMs,
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
    ..rewindPending = j['rewindPending'] == true
    ..lastSeenMs = _i(j['lastSeenMs'])
    ..offlineAway = _d(j['offlineAway'])
    ..offlineCounted = _d(j['offlineCounted'])
    ..offlineAmount = _d(j['offlineAmount'])
    ..playSeconds = _d(j['playSeconds'])
    ..tutorialDone = j['tutorialDone'] == true
    ..comboStreak = _i(j['comboStreak'])
    ..shieldCharges = _i(j['shieldCharges'])
    ..shieldProgress = _i(j['shieldProgress'])
    ..goldenNextAt = _d(j['goldenNextAt'])
    ..modeBlind = j['modeBlind'] == true
    ..secondClockOn = j['secondClockOn'] == true
    ..autoBuyerOn = j['autoBuyerOn'] == true
    ..turboLeft = _d(j['turboLeft'])
    ..dailyKey = _i(j['dailyKey'])
    ..dailyStreak = _i(j['dailyStreak'])
    ..dailyGraceUsed = j['dailyGraceUsed'] == true
    ..challengeDay = _i(j['challengeDay'])
    ..challengeWeek = _i(j['challengeWeek'])
    ..challengeRerollDay = _i(j['challengeRerollDay'])
    ..challengeBonusDay = _i(j['challengeBonusDay'])
    ..tutorialEndPlay = _d(j['tutorialEndPlay'])
    ..seasonKey = j['seasonKey'] is String ? j['seasonKey']! as String : ''
    ..seasonCatches = _i(j['seasonCatches'])
    ..seasonHits = _i(j['seasonHits'])
    ..theme = j['theme'] is String ? j['theme']! as String : ''
    ..springs = _i(j['springs'])
    ..springProgress = _d(j['springProgress'])
    ..springClockMs = _i(j['springClockMs'])
    // Saves from before the reserve (R-SPR-3) start with a full one.
    ..springReserve = _d(j['springReserve'])
    ..springReserveMs = _i(j['springReserveMs'])
    ..springAdDay = _i(j['springAdDay'])
    ..springAdCount = _i(j['springAdCount'])
    ..springsRefunded = _i(j['springsRefunded'])
    ..loop = math.max(1, _i(j['loop'], 1))
    ..loopsDone = _i(j['loopsDone'])
    ..loopGoal = j['loopGoal'] == true
    ..loopEndSeen = j['loopEndSeen'] == true
    ..loopBonusPaid = _i(j['loopBonusPaid'])
    ..loopPlaySeconds = _d(j['loopPlaySeconds'])
    ..loopPrestiges = _i(j['loopPrestiges'])
    ..loopStartMs = _i(j['loopStartMs'])
    ..loopGoalSeconds = _d(j['loopGoalSeconds'])
    ..dial = j['dial'] is String ? j['dial']! as String : ''
    // A save from before the counter: this run's taps are unknown.
    ..runTaps = j.containsKey('runTaps') ? _i(j['runTaps']) : 1 << 30;
  final challenges = j['challenges'];
  if (challenges is List) {
    s.challenges.addAll(challenges.map(Challenge.fromJson).nonNulls);
  }
  s.seasonsDone.addAll(_sl(j['seasonsDone']));
  _m(j['seasonStash']).forEach((k, v) {
    if (v is List && v.length == 2) s.seasonStash[k] = [_i(v[0]), _i(v[1])];
  });
  s.tipsSeen.addAll(_sl(j['tipsSeen']));
  _m(j['adCooldownUntil']).forEach((k, v) => s.adCooldownUntil[k] = _i(v));
  _m(j['owned']).forEach((k, v) => s.owned[k] = _i(v));
  _m(j['skills']).forEach((k, v) => s.skills[k] = _i(v));
  // Perks replaced in playtest 25 keep their slot (and their Shards).
  s.perks.addAll(_sl(j['perks']).map((id) => _renamedPerks[id] ?? id));
  s.habits.addAll(_sl(j['habits']));
  s.achievements.addAll(_sl(j['achievements']));
  _m(j['clockLevels']).forEach((k, v) => s.clockLevels[k] = _i(v));
  s.dialsSeen.addAll(_sl(j['dialsSeen']));
  // Rules taken out of the game drop out, with their seals and records.
  bool kept(String id) => !_retiredRules.contains(id);
  s.loopRules.addAll(_sl(j['loopRules']).where(kept));
  s.seals.addAll(_sl(j['seals']).where(kept));
  s.nextRules.addAll(_sl(j['nextRules']).where(kept));
  _m(j['loopBest']).forEach((k, v) {
    if (k.split('+').every(kept)) s.loopBest[k] = _d(v);
  });
  // Saves from before Mainsprings: clocks owned now or ever (their first
  // "own 1" badge) count as bought.
  s.everOwned.addAll(_sl(j['everOwned']));
  if (!j.containsKey('everOwned')) {
    s.everOwned
      ..addAll(s.owned.entries.where((e) => e.value > 0).map((e) => e.key))
      ..addAll(
        s.achievements
            .where((a) => a.startsWith('owned_') && a.endsWith('_1'))
            .map((a) => a.substring(6, a.length - 2)),
      );
  }
  if (!j.containsKey('dialsSeen')) {
    // Faces a player already earned are not news: no toast for each.
    s.dialsSeen.add('*');
  }
  final stats = _m(j['stats']);
  s.stats.rounds = _i(stats['rounds']);
  _m(stats['byTier']).forEach((k, v) {
    for (final t in Tier.values) {
      if (t.name == k) s.stats.byTier[t] = _i(v);
    }
  });
  final errors = stats['recentErrors'];
  if (errors is List) s.stats.recentErrors.addAll(errors.map((e) => _d(e)));
  s.stats.accidental = _i(stats['accidental']);
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
    ..secondsPlayed = _d(l['secondsPlayed'])
    ..tenthDayPerfects = _i(l['tenthDayPerfects'])
    ..tenthDayKey = _i(l['tenthDayKey'])
    ..exactHits = _i(l['exactHits'])
    ..blindPerfects = _i(l['blindPerfects'])
    ..bothClocksPerfects = _i(l['bothClocksPerfects'])
    ..dailyClaims = _i(l['dailyClaims'])
    ..challengesDone = _i(l['challengesDone'])
    ..shieldSaves = _i(l['shieldSaves'])
    ..goldenFast = _i(l['goldenFast'])
    ..goldenInFrenzy = _i(l['goldenInFrenzy'])
    ..offlineFull = _i(l['offlineFull'])
    ..springsWound = _i(l['springsWound'])
    ..springSecondsLost = _d(l['springSecondsLost']);
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
    ..notifications = st['notifications'] != false
    ..analytics = st['analytics'] != false
    // Turned off before the question existed: that was an answer.
    ..analyticsAsked = st['analyticsAsked'] == true || st['analytics'] == false
    ..inputOffsetMs = _d(st['inputOffsetMs']).clamp(-150.0, 250.0);
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

/// Old perk ids → their replacements (playtest 25): Shield at start and
/// the early Blind unlock never did anything a player could notice.
/// Loop rules no longer in the game (docs/15: Fragile combo, 11.2026).
const _retiredRules = {'fragileCombo'};

const _renamedPerks = {
  'startShield': 'shieldRecharge',
  'earlyModes': 'daredevil',
};
