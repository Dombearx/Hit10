/// Typed view of `assets/balance.json` — every gameplay number lives there
/// (docs/05-technika.md T-5). Pure Dart: no Flutter imports, so the game,
/// the tests and `tool/simulate.dart` all read the same data.
library;

import 'dart:convert';

class BalanceException implements Exception {
  BalanceException(this.errors);
  final List<String> errors;
  @override
  String toString() => 'Invalid balance.json:\n  ${errors.join('\n  ')}';
}

double _d(Object? v) => (v as num).toDouble();
int _i(Object? v) => (v as num).toInt();
List<double> _dl(Object? v) => (v as List).map(_d).toList(growable: false);
Map<String, Object?> _m(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _ml(Object? v) =>
    (v as List).map(_m).toList(growable: false);

class RoundConfig {
  RoundConfig(Map<String, Object?> j)
    : target = _d(j['target']),
      autoEndAfter = _d(j['autoEndAfter']),
      inputGraceAfterStart = _d(j['inputGraceAfterStart']),
      resultPause = _d(j['resultPause']),
      fastForwardEnd = _d(j['fastForwardEnd']),
      bulletZone = _d(j['bulletZone']),
      secondClockOffset = _d(j['secondClockOffset']),
      idleStopAfter = _i(j['idleStopAfter']);
  final double target;
  final double autoEndAfter;
  final double inputGraceAfterStart;
  final double resultPause;
  final double fastForwardEnd;
  final double bulletZone;
  final double secondClockOffset;

  /// Untapped rounds in a row after which the stopwatch waits for a touch
  /// instead of starting the next round (phone put down, playtest 08).
  final int idleStopAfter;
}

/// BLISKO (docs/02 §2): a player's miss within [window] still pays
/// [reward] (in units of the tier rewards) but breaks the combo.
class CloseConfig {
  CloseConfig(Map<String, Object?> j)
    : window = _d(j['window']),
      reward = _d(j['reward']);
  final double window;
  final double reward;
}

/// Daily bonus (playtest 08): a 7-day streak; day N pays [minutes][N-1]
/// minutes of passive income, at least [floorPerDay]·N Tiki.
class DailyConfig {
  DailyConfig(Map<String, Object?> j)
    : minutes = [for (final m in j['minutes']! as List) _d(m)],
      floorPerDay = _d(j['floorPerDay']);
  final List<double> minutes;
  final double floorPerDay;
}

/// "Beginner's luck" (playtest 08): the first [rounds] rounds of a new
/// game pay more, so a new player buys within a minute. The windows stay
/// as they are: hitting 10.00 must stay an achievement.
class BeginnerConfig {
  BeginnerConfig(Map<String, Object?> j)
    : rounds = _i(j['rounds']),
      rewardMultiplier = _d(j['rewardMultiplier']),
      fadeRounds = _i(j['fadeRounds']);
  final int rounds;

  /// After [rounds], the bonus fades out linearly over this many rounds
  /// instead of stopping at once.
  final int fadeRounds;
  final double rewardMultiplier;
}

class TierConfig {
  TierConfig(Map<String, Object?> j)
    : id = j['id'] as String,
      window = _d(j['window']),
      reward = _d(j['reward']),
      echoShare = _d(j['echoShare']),
      comboStep = _i(j['comboStep']);
  final String id;
  final double window;
  final double reward;
  final double echoShare;
  final int comboStep;
}

class ComboConfig {
  ComboConfig(Map<String, Object?> j)
    : multiplierPerStep = _d(j['multiplierPerStep']),
      baseCap = _i(j['baseCap']),
      shieldRechargeSteps = _i(j['shieldRechargeSteps']);
  final double multiplierPerStep;
  final int baseCap;
  final int shieldRechargeSteps;
}

class SkillConfig {
  SkillConfig(Map<String, Object?> j)
    : id = j['id'] as String,
      maxLevel = _i(j['maxLevel']),
      baseCost = _d(j['baseCost']),
      costGrowth = _d(j['costGrowth']),
      perLevel = _d(j['perLevel']);
  final String id;
  final int maxLevel;
  final double baseCost;
  final double costGrowth;
  final double perLevel;
}

class GeneratorConfig {
  GeneratorConfig(Map<String, Object?> j)
    : id = j['id'] as String,
      sigma = _d(j['sigma']),
      baseCost = _d(j['baseCost']),
      baseRate = _d(j['baseRate']),
      requiresPerk = j['requiresPerk'] as String?;
  final String id;
  final double sigma;
  final double baseCost;
  final double baseRate;
  final String? requiresPerk;
}

class GeneratorUpgradesConfig {
  GeneratorUpgradesConfig(Map<String, Object?> j)
    : thresholds = (j['thresholds'] as List).map(_i).toList(growable: false),
      costMultipliers = _dl(j['costMultipliers']),
      multiplier = _d(j['multiplier']);
  final List<int> thresholds;
  final List<double> costMultipliers;
  final double multiplier;
}

class SynergyConfig {
  SynergyConfig(Map<String, Object?> j)
    : id = j['id'] as String,
      a = j['a'] as String,
      b = j['b'] as String,
      aPerB = _d(j['aPerB']),
      bPerA = _d(j['bPerA']),
      cost = _d(j['cost']);
  final String id;
  final String a;
  final String b;
  final double aPerB;
  final double bPerA;
  final double cost;
}

class GoldenEffectConfig {
  GoldenEffectConfig(Map<String, Object?> j)
    : id = j['id'] as String,
      weight = _d(j['weight']),
      multiplier = j['multiplier'] == null ? 1 : _d(j['multiplier']),
      duration = j['duration'] == null ? 0 : _d(j['duration']),
      productionSeconds = j['productionSeconds'] == null
          ? 0
          : _d(j['productionSeconds']),
      bankFraction = j['bankFraction'] == null ? 0 : _d(j['bankFraction']);
  final String id;
  final double weight;
  final double multiplier;
  final double duration;
  final double productionSeconds;
  final double bankFraction;
}

class GoldenConfig {
  GoldenConfig(Map<String, Object?> j)
    : intervalMin = _d(j['intervalMin']),
      intervalMax = _d(j['intervalMax']),
      visibleFor = _d(j['visibleFor']),
      tierStrength = _m(j['tierStrength']).map((k, v) => MapEntry(k, _d(v))),
      effects = _ml(j['effects']).map(GoldenEffectConfig.new).toList();
  final double intervalMin;
  final double intervalMax;
  final double visibleFor;
  final Map<String, double> tierStrength;
  final List<GoldenEffectConfig> effects;

  GoldenEffectConfig effect(String id) => effects.firstWhere((e) => e.id == id);
}

class ModeConfig {
  ModeConfig(Map<String, Object?> j)
    : unlockPerfects = _i(j['unlockPerfects']),
      rewardMultiplier = _d(j['rewardMultiplier']),
      hideDigitsAt = j['hideDigitsAt'] == null ? null : _d(j['hideDigitsAt']),
      clockSpeed = j['clockSpeed'] == null ? 1 : _d(j['clockSpeed']);
  final int unlockPerfects;
  final double rewardMultiplier;
  final double? hideDigitsAt;
  final double clockSpeed;
}

class OfflineConfig {
  OfflineConfig(Map<String, Object?> j)
    : capHours = _d(j['capHours']),
      efficiency = _d(j['efficiency']),
      minAwaySeconds = _d(j['minAwaySeconds']);
  final double capHours;
  final double efficiency;
  final double minAwaySeconds;
}

class AchievementsConfig {
  AchievementsConfig(Map<String, Object?> j)
    : bonusEach = _d(j['bonusEach']),
      earnedThresholds = _dl(j['earnedThresholds']),
      ownedThresholds = _ints(j['ownedThresholds']),
      perfectThresholds = _ints(j['perfectThresholds']),
      perfectStreakThresholds = _ints(j['perfectStreakThresholds']),
      comboThresholds = _ints(j['comboThresholds']),
      goldenThresholds = _ints(j['goldenThresholds']),
      prestigeThresholds = _ints(j['prestigeThresholds']),
      impatientEarlyTaps = _i(j['impatientEarlyTaps']),
      napMissedRounds = _i(j['napMissedRounds']),
      boiledEggGrandmas = _i(j['boiledEggGrandmas']),
      tenthDayPerfects = _i(j['tenthDayPerfects']);
  static List<int> _ints(Object? v) =>
      (v as List).map(_i).toList(growable: false);
  final double bonusEach;
  final List<double> earnedThresholds;
  final List<int> ownedThresholds;
  final List<int> perfectThresholds;
  final List<int> perfectStreakThresholds;
  final List<int> comboThresholds;
  final List<int> goldenThresholds;
  final List<int> prestigeThresholds;
  final int impatientEarlyTaps;
  final int napMissedRounds;
  final int boiledEggGrandmas;
  final int tenthDayPerfects;
}

class PerkConfig {
  PerkConfig(Map<String, Object?> j)
    : id = j['id'] as String,
      cost = _i(j['cost']),
      requires = j['requires'] as String?,
      params = j['params'] == null
          ? const {}
          : _m(j['params']).map((k, v) => MapEntry(k, _d(v)));
  final String id;
  final int cost;
  final String? requires;
  final Map<String, double> params;
}

class PrestigeConfig {
  PrestigeConfig(Map<String, Object?> j)
    : divisor = _d(j['divisor']),
      root = _d(j['root']),
      bonusPerChronon = _d(j['bonusPerChronon']),
      perks = _ml(j['perks']).map(PerkConfig.new).toList();
  final double divisor;

  /// Chronons grow with the [root]-th root of lifetime Tiki (R-PRES-2).
  final double root;
  final double bonusPerChronon;
  final List<PerkConfig> perks;
}

class AdsConfig {
  AdsConfig(Map<String, Object?> j)
    : unlockAfterSeconds = _d(j['unlockAfterSeconds']),
      offlineMultiplier = _d(_m(j['offline'])['multiplier']),
      offlineMinAwaySeconds = _d(_m(j['offline'])['minAwaySeconds']),
      turboMultiplier = _d(_m(j['turbo'])['multiplier']),
      turboDuration = _d(_m(j['turbo'])['duration']),
      turboMaxStock = _d(_m(j['turbo'])['maxStock']),
      turboCooldown = _d(_m(j['turbo'])['cooldown']),
      bagProductionSeconds = _d(_m(j['bag'])['productionSeconds']),
      bagCooldown = _d(_m(j['bag'])['cooldown']),
      rescueMinStreak = _i(_m(j['rescue'])['minStreak']),
      rescueCooldown = _d(_m(j['rescue'])['cooldown']),
      rescueOfferSeconds = _d(_m(j['rescue'])['offerSeconds']),
      goldenCooldown = _d(_m(j['golden'])['cooldown']);
  final double unlockAfterSeconds;
  final double offlineMultiplier;
  final double offlineMinAwaySeconds;
  final double turboMultiplier;
  final double turboDuration;
  final double turboMaxStock;

  /// Between two Turbo ads (playtest 08: players chained 8 in 3 minutes).
  final double turboCooldown;
  final double bagProductionSeconds;
  final double bagCooldown;
  final int rescueMinStreak;
  final double rescueCooldown;
  final double rescueOfferSeconds;
  final double goldenCooldown;
}

class UiConfig {
  UiConfig(Map<String, Object?> j)
    : skillRevealFraction = _d(j['skillRevealFraction']),
      generatorPopupsPerSecond = _d(j['generatorPopupsPerSecond']);
  final double skillRevealFraction;
  final double generatorPopupsPerSecond;
}

class Balance {
  Balance._(Map<String, Object?> j)
    : version = _i(j['version']),
      economyTickHz = _d(j['economyTickHz']),
      round = RoundConfig(_m(j['round'])),
      tiers = _ml(j['tiers']).map(TierConfig.new).toList(),
      combo = ComboConfig(_m(j['combo'])),
      skills = _ml(j['skills']).map(SkillConfig.new).toList(),
      generators = _ml(j['generators']).map(GeneratorConfig.new).toList(),
      generatorCostGrowth = _d(j['generatorCostGrowth']),
      generatorUpgrades = GeneratorUpgradesConfig(_m(j['generatorUpgrades'])),
      synergies = _ml(j['synergies']).map(SynergyConfig.new).toList(),
      golden = GoldenConfig(_m(j['golden'])),
      blind = ModeConfig(_m(_m(j['modes'])['blind'])),
      fastClock = ModeConfig(_m(_m(j['modes'])['fastClock'])),
      offline = OfflineConfig(_m(j['offline'])),
      achievements = AchievementsConfig(_m(j['achievements'])),
      prestige = PrestigeConfig(_m(j['prestige'])),
      ads = AdsConfig(_m(j['ads'])),
      beginner = BeginnerConfig(_m(j['beginner'])),
      close = CloseConfig(_m(j['close'])),
      daily = DailyConfig(_m(j['daily'])),
      ui = UiConfig(_m(j['ui']));

  /// Parses and validates; throws [BalanceException] listing every problem.
  factory Balance.fromJsonString(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw BalanceException(['not valid JSON: ${e.message}']);
    }
    final Balance b;
    try {
      b = Balance._(_m(decoded));
    } on Object catch (e) {
      // A missing field or wrong type surfaces as a cast error.
      throw BalanceException(['missing or mistyped field: $e']);
    }
    final errors = b.validate();
    if (errors.isNotEmpty) throw BalanceException(errors);
    return b;
  }

  final int version;
  final double economyTickHz;
  final RoundConfig round;
  final List<TierConfig> tiers;
  final ComboConfig combo;
  final List<SkillConfig> skills;
  final List<GeneratorConfig> generators;
  final double generatorCostGrowth;
  final GeneratorUpgradesConfig generatorUpgrades;
  final List<SynergyConfig> synergies;
  final GoldenConfig golden;
  final ModeConfig blind;
  final ModeConfig fastClock;
  final OfflineConfig offline;
  final AchievementsConfig achievements;
  final PrestigeConfig prestige;
  final AdsConfig ads;
  final BeginnerConfig beginner;
  final CloseConfig close;
  final DailyConfig daily;
  final UiConfig ui;

  TierConfig tier(String id) => tiers.firstWhere((t) => t.id == id);
  SkillConfig skill(String id) => skills.firstWhere((s) => s.id == id);
  GeneratorConfig generator(String id) =>
      generators.firstWhere((g) => g.id == id);
  PerkConfig perk(String id) => prestige.perks.firstWhere((p) => p.id == id);

  /// Cross-field checks (T-6). Returns human-readable problems; empty = valid.
  List<String> validate() {
    final e = <String>[];
    void unique(String what, Iterable<String> ids) {
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) e.add('duplicate $what id "$id"');
      }
    }

    const tierOrder = ['perfect', 'great', 'good'];
    if (tiers.map((t) => t.id).join(',') != tierOrder.join(',')) {
      e.add('tiers must be exactly ${tierOrder.join(', ')} in that order');
    }
    if (daily.minutes.isEmpty) e.add('daily.minutes must not be empty');
    if (tiers.map((t) => t.id).join(',') == tierOrder.join(',') &&
        close.window <= tier('good').window) {
      e.add('close.window must be wider than the good window');
    }
    for (var i = 1; i < tiers.length; i++) {
      if (tiers[i].window <= tiers[i - 1].window) {
        e.add(
          'tier "${tiers[i].id}" window must be wider than "${tiers[i - 1].id}"',
        );
      }
    }
    const skillIds = {
      'power',
      'fastForward',
      'ticking',
      'wideEye',
      'combo',
      'magnet',
      'echo',
      'bulletTime',
      'luck',
      'shield',
      'goldenTouch',
    };
    unique('skill', skills.map((s) => s.id));
    final missingSkills = skillIds.difference(skills.map((s) => s.id).toSet());
    if (missingSkills.isNotEmpty) e.add('missing skills: $missingSkills');
    for (final s in skills) {
      if (s.maxLevel < 1) e.add('skill "${s.id}" maxLevel must be ≥ 1');
      if (s.baseCost <= 0) e.add('skill "${s.id}" baseCost must be > 0');
      if (s.maxLevel > 1 && s.costGrowth <= 1) {
        e.add('skill "${s.id}" costGrowth must be > 1');
      }
    }
    if (e.isEmpty) {
      // Perfect window must stay inside great even with both skills maxed (R-PROG-2).
      final magnet = skill('magnet');
      final wide = skill('wideEye');
      final perfectMax =
          tier('perfect').window + magnet.perLevel * magnet.maxLevel;
      final greatMin = tier('great').window;
      if (perfectMax >= greatMin) {
        e.add(
          'max perfect window $perfectMax must be below great window $greatMin',
        );
      }
      if (wide.perLevel < 0) e.add('wideEye perLevel must be ≥ 0');
      final bt = skill('bulletTime');
      if (1 - bt.perLevel * bt.maxLevel <= 0) {
        e.add('bulletTime at max level must leave a positive speed');
      }
    }
    unique('generator', generators.map((g) => g.id));
    double? prevCost;
    for (final g in generators) {
      if (g.sigma < 0) e.add('generator "${g.id}" sigma must be ≥ 0');
      if (g.baseRate <= 0) e.add('generator "${g.id}" baseRate must be > 0');
      if (prevCost != null && g.baseCost <= prevCost) {
        e.add('generator "${g.id}" must cost more than the previous one');
      }
      prevCost = g.baseCost;
    }
    if (generatorCostGrowth <= 1) e.add('generatorCostGrowth must be > 1');
    final gu = generatorUpgrades;
    if (gu.thresholds.length != gu.costMultipliers.length) {
      e.add(
        'generatorUpgrades thresholds and costMultipliers differ in length',
      );
    }
    for (var i = 1; i < gu.thresholds.length; i++) {
      if (gu.thresholds[i] <= gu.thresholds[i - 1]) {
        e.add('generatorUpgrades thresholds must increase');
      }
    }
    final genIds = generators.map((g) => g.id).toSet();
    final perkIds = prestige.perks.map((p) => p.id).toSet();
    unique('synergy', synergies.map((s) => s.id));
    for (final s in synergies) {
      for (final partner in [s.a, s.b]) {
        if (!genIds.contains(partner)) {
          e.add('synergy "${s.id}" unknown generator "$partner"');
        }
      }
    }
    unique('perk', prestige.perks.map((p) => p.id));
    for (final p in prestige.perks) {
      if (p.requires != null && !perkIds.contains(p.requires)) {
        e.add('perk "${p.id}" requires unknown perk "${p.requires}"');
      }
    }
    for (final g in generators) {
      if (g.requiresPerk != null && !perkIds.contains(g.requiresPerk)) {
        e.add('generator "${g.id}" requires unknown perk "${g.requiresPerk}"');
      }
    }
    const goldenIds = {'frenzy', 'lucky', 'hotHand'};
    if (golden.effects
            .map((x) => x.id)
            .toSet()
            .difference(goldenIds)
            .isNotEmpty ||
        golden.effects.length != goldenIds.length) {
      e.add('golden effects must be exactly $goldenIds');
    }
    if (golden.intervalMin <= 0 || golden.intervalMax < golden.intervalMin) {
      e.add('golden interval must satisfy 0 < min ≤ max');
    }
    for (final t in tierOrder) {
      if (!golden.tierStrength.containsKey(t)) {
        e.add('golden tierStrength missing "$t"');
      }
    }
    if (offline.efficiency < 0 || offline.efficiency > 1) {
      e.add('offline efficiency must be within 0..1');
    }
    if (prestige.divisor <= 0 || prestige.root <= 0) {
      e.add('prestige divisor and root must be > 0');
    }
    if (round.fastForwardEnd >= round.target - round.bulletZone) {
      e.add('fastForwardEnd must end before the bullet-time zone');
    }
    if (ads.turboMaxStock < ads.turboDuration) {
      e.add('ads turbo maxStock must be ≥ duration');
    }
    return e;
  }
}
