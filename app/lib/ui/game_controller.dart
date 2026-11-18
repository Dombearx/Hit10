import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ads/rewarded_ads.dart';
import '../analytics/analytics.dart';
import '../balance/balance.dart';
import '../engine/ad_offers.dart';
import '../engine/game_engine.dart';
import '../engine/round_engine.dart';
import '../model/achievements.dart';
import '../model/economy.dart';
import '../model/game_state.dart';
import '../model/grading.dart';
import '../model/seasons.dart';
import '../model/settings.dart';
import '../model/showcase.dart';
import '../persistence/save_codec.dart';
import '../persistence/save_store.dart';
import 'audio.dart';
import 'haptics.dart';
import 'notifications.dart';

/// What the arena needs to animate a finished round.
class HitFeedback {
  HitFeedback(
    this.outcome,
    this.gameTime, {
    this.clock = 0,
    this.springSeconds = 0,
    this.springEmpty = false,
  });
  final RoundOutcome outcome;
  final double gameTime;

  /// Seconds an exact hit wound the Mainspring (docs/12 R-SPR-3).
  final double springSeconds;

  /// The exact hit found the winding reserve empty (told once, R-SPR-3).
  final bool springEmpty;

  /// Which stopwatch (0, or 1 for the second clock).
  final int clock;

  Grade get grade => Grade(
    outcome.tier,
    outcome.raw.error,
    outcome.raw.missKind,
    outcome.raw.close,
  );
  double get reward => outcome.payout;
}

/// A free bonus that just switched on (R-ULEP-1, R-SYN-1): generator
/// milestone [index] (0-based) of [generator], or synergy [synergy].
class MilestoneEvent {
  const MilestoneEvent.generator(String this.generator, this.index)
    : synergy = null,
      dial = null,
      loopSprings = 0;
  const MilestoneEvent.synergy(String this.synergy)
    : generator = null,
      index = 0,
      dial = null,
      loopSprings = 0;

  /// A new stopwatch face (docs/12 §3.3).
  const MilestoneEvent.dial(String this.dial)
    : generator = null,
      synergy = null,
      index = 0,
      loopSprings = 0;

  /// Mainsprings for bonuses of the loop's goal clock (R-PETLA-2a).
  const MilestoneEvent.loopBonus(this.loopSprings)
    : generator = null,
      synergy = null,
      dial = null,
      index = 0;

  final int loopSprings;
  final String? generator;
  final int index;
  final String? synergy;
  final String? dial;
}

/// One stopwatch and what was fixed when its round started (R-TRYB-1).
class ClockSlot {
  ClockSlot(this.index, this.round);
  final int index;
  final RoundEngine round;
  double mode = 1;
  bool blind = false;
  int lastTickTenth = -1;
  double lastHeartbeat = -10;
}

/// First-run steps (R-TUT-1): aim, earn, buy Grandpa, what he does, and
/// that the stopwatch starts by itself from now on.
enum TutorialStep { aim, earned, buyGrandpa, grandpaInfo, autoStart, done }

enum GoalKind { bonus, newClock, prestige, perk, loopBonus }

/// What [GameController.nextGoal] points the player at.
class NextGoal {
  const NextGoal(
    this.kind, {
    this.generator,
    this.perk,
    this.have = 0,
    this.need = 0,
  });
  final GoalKind kind;

  /// The perk it is about: the one to save Shards for ([GoalKind.perk]) or
  /// the one a paradox now would pay for ([GoalKind.prestige]).
  final String? perk;

  /// The clock it is about (not for [GoalKind.prestige]).
  final String? generator;

  /// Progress: clocks owned of the bonus' threshold, Tiks of the price, or
  /// Shards (with those a paradox would add) of the perk's.
  final double have;
  final double need;

  double get progress => need <= 0 ? 0 : (have / need).clamp(0.0, 1.0);
}

/// Glue between the pure engine and the screen: owns the monotonic clock
/// (T-8), turns pointer-downs into grades (T-9), runs the economy tick
/// (T-14), saves (T-18), offers, achievements and the tutorial, and fires
/// sound and haptics.
class GameController extends ChangeNotifier {
  GameController({
    required this.balance,
    GameState? state,
    Settings? settings,
    this.store,
    Sfx? sfx,
    Haptics? haptics,
    this.notifications = const NoNotifications(),
    this.analytics = const NoAnalytics(),
    int Function()? wallClockMs,
    DateTime Function()? localNow,
  }) : state = state ?? GameState(),
       settings = settings ?? Settings(),
       sfx = sfx ?? Sfx(),
       haptics = haptics ?? Haptics(),
       _wallMs = wallClockMs ?? (() => DateTime.now().millisecondsSinceEpoch),
       _localNow = localNow ?? DateTime.now {
    engine = GameEngine(balance, this.state);
    // The app closed between paying out a paradox and starting the new
    // run: start it now (R-PRES-6a).
    engine.finishPrestige();
    ads = AdOffers(engine);
    achievements = buildAchievements(balance);
    // Thresholds retuned after the achievement report (playtest 25):
    // badges that no longer exist neither show nor count.
    final known = {for (final a in achievements) a.id};
    this.state.achievements.retainWhere(known.contains);
    // A new game, or a save from before the faces: what is already earned
    // is not news (docs/12 §3.3).
    final seen = this.state.dialsSeen;
    if (seen.isEmpty || seen.remove('*')) {
      seen.addAll(econ.unlockedDials.map((d) => d.id));
    }
    _rebuildClocks();
    _applySettings();
    engine.goldenEnabled = this.state.tutorialDone;
    syncSeason();
    _syncUserProperties();
    _trackTutorial();
  }

  final Balance balance;
  final GameState state;
  final Settings settings;
  final SaveStore? store;
  final Sfx sfx;
  final Haptics haptics;
  final OfflineNotifications notifications;
  final Analytics analytics;
  final int Function() _wallMs;
  final DateTime Function() _localNow;
  late final GameEngine engine;
  late final AdOffers ads;
  late final List<AchievementDef> achievements;
  final InputDiagnostics diagnostics = InputDiagnostics();
  final GeneratorShowcase showcase = GeneratorShowcase();

  Economy get econ => engine.econ;

  final List<ClockSlot> clocks = [];

  /// The main stopwatch (the only one unless the second clock is on).
  RoundEngine get round => clocks.first.round;

  int wallMs() => _wallMs();

  final Stopwatch _clock = Stopwatch()..start();

  /// Seconds on the monotonic clock.
  double now() => _clock.elapsedMicroseconds / 1e6;

  final _feedback = StreamController<HitFeedback>.broadcast();
  Stream<HitFeedback> get feedback => _feedback.stream;

  /// Fires (clock index, golden?) when a round starts.
  final _roundStarts = StreamController<(int, bool)>.broadcast();
  Stream<(int, bool)> get roundStarts => _roundStarts.stream;

  final _unlocked = StreamController<AchievementDef>.broadcast();
  Stream<AchievementDef> get achievementUnlocked => _unlocked.stream;

  final _milestones = StreamController<MilestoneEvent>.broadcast();
  Stream<MilestoneEvent> get milestoneReached => _milestones.stream;

  /// Milestones per generator and the active synergies, before a purchase.
  (Map<String, int>, Set<String>) _bonuses() => (
    {for (final g in balance.generators) g.id: econ.milestonesReached(g.id)},
    {
      for (final syn in balance.synergies)
        if (econ.synergyActive(syn)) syn.id,
    },
  );

  /// Celebrates every bonus a purchase switched on.
  void _announceBonuses((Map<String, int>, Set<String>) before) {
    var any = false;
    for (final g in balance.generators) {
      for (var k = before.$1[g.id]!; k < econ.milestonesReached(g.id); k++) {
        _milestones.add(MilestoneEvent.generator(g.id, k));
        any = true;
      }
    }
    for (final syn in balance.synergies) {
      if (!before.$2.contains(syn.id) && econ.synergyActive(syn)) {
        _milestones.add(MilestoneEvent.synergy(syn.id));
        any = true;
      }
    }
    if (any) {
      tipActed('milestone');
      sfx.play('fanfare', gain: 0.7);
      unawaited(haptics.medium());
    }
  }

  /// Tiki paid for finishing the running season (docs/02 §14).
  final _seasonCompleted = StreamController<double>.broadcast();
  Stream<double> get seasonCompleted => _seasonCompleted.stream;

  /// Offline income waiting in the "while you were away" dialog.
  OfflineReport? pendingOffline;

  /// Set when the save could not be read and the game started fresh (T-20).
  bool saveWasCorrupt = false;

  /// A one-time tip to show (R-TUT-2), or null.
  String? pendingTip;

  double? _lastTick;
  double _econAcc = 0;
  double _sinceSave = 0;
  double _sinceAchievementCheck = 0;
  double? _startSecondAt;
  bool _adPlaying = false;
  bool _goldenShown = false;

  /// A running clock is inside the bullet-time zone (docs/04 §3, U-19).
  /// Its own notifier: the whole UI must not rebuild when it flips.
  final bulletZone = ValueNotifier<bool>(false);
  bool get inBulletZone => bulletZone.value;
  static const _saveEvery = 10.0;

  void _applySettings() {
    sfx.volume = settings.sfxVolume;
    sfx.enabled = settings.sfxVolume > 0;
    sfx.musicVolume = settings.musicVolume;
    sfx.updateMusicVolume();
    haptics.enabled = settings.haptics;
    analytics.setEnabled(settings.analytics);
  }

  // ---------------------------------------------------------- statistics --

  /// Logs a game event (docs/05 §8a) with where the player is: which run
  /// and how many minutes into the game.
  void _log(String name, [Map<String, Object> params = const {}]) =>
      analytics.log(name, {
        ...params,
        'run': state.prestiges,
        'play_min': (state.playSeconds / 60).floor(),
      });

  /// The best clock owned this run ('none' before Grandpa).
  String get _topClock {
    for (final g in balance.generators.reversed) {
      if (econ.owned(g.id) > 0) return g.id;
    }
    return 'none';
  }

  void _syncUserProperties() {
    analytics.setUserProperty('prestiges', '${state.prestiges}');
    analytics.setUserProperty('top_clock', _topClock);
    analytics.setUserProperty('tutorial_done', '${state.tutorialDone}');
  }

  /// The tutorial funnel (R-TUT-1): one event per step reached.
  TutorialStep? _loggedStep;
  void _trackTutorial() {
    if (state.tutorialDone) return;
    final step = tutorialStep;
    if (step == _loggedStep) return;
    _loggedStep = step;
    _log('tutorial_step', {'step': step.name});
  }

  /// The player answered a rewarded offer (docs/02 §13): the take rate of
  /// each offer.
  void adOfferAnswered(AdOffer offer, {required bool watch}) =>
      _log('ad_offer', {'offer': offer.name, 'watch': watch ? 1 : 0});

  /// Bumped on every settings change; the app rebuilds its locale from it.
  final settingsVersion = ValueNotifier<int>(0);

  void applySettings() {
    _applySettings();
    settingsVersion.value++;
    notifyListeners();
    unawaited(save());
  }

  // ------------------------------------------------------ export / reset --

  /// Set once this controller's save has been replaced (import, reset): it
  /// must never write again, or it would overwrite the new save.
  bool _retired = false;

  /// The save as copyable text (T-19).
  String exportText() =>
      exportSave(SaveData(state, settings, balanceVersion: balance.version));

  /// Validates [text] and makes it the save; throws [SaveFormatException]
  /// on anything that is not an exported save. The app restarts after.
  Future<void> importText(String text) async {
    final data = importSave(text);
    _retired = true;
    await store?.write(saveToJsonString(data));
  }

  /// Wipes the progress but keeps the player's settings.
  Future<void> resetProgress() async {
    _retired = true;
    await store?.clear();
    await store?.write(
      saveToJsonString(
        SaveData(GameState(), settings, balanceVersion: balance.version),
      ),
    );
  }

  // -------------------------------------------------------------- clocks --

  bool get secondClockActive =>
      state.secondClockOn && state.perks.contains('secondClock');

  RoundEngine _newRound() => RoundEngine(
    config: balance.round,
    timeMapFor: econ.timeMap,
    windowsFor: econ.playerWindows,
  );

  void _rebuildClocks() {
    for (final c in clocks) {
      if (c.round.phase != RoundPhase.waiting) {
        c.round.cancel();
        engine.onRoundCancelled();
      }
    }
    clocks
      ..clear()
      ..add(ClockSlot(0, _newRound()));
    if (secondClockActive) clocks.add(ClockSlot(1, _newRound()));
    _startSecondAt = null;
  }

  /// Toggles from the mode row (R-TRYB-1, docs/02 §9.2).
  void setMode({bool? blind, bool? secondClock, bool? autoBuyer}) {
    for (final (mode, on) in [
      ('blind', blind),
      ('second_clock', secondClock),
      ('auto_buyer', autoBuyer),
    ]) {
      if (on != null) _log('mode_toggle', {'mode': mode, 'on': on ? 1 : 0});
    }
    // "Broken stopwatch" keeps Blind on for the loop (R-PETLA-4).
    if (blind != null && engine.blindForced) return;
    if (blind != null) state.modeBlind = blind;
    if (blind == false) {
      // Off mid-round: the clock shows again at once, and this round pays
      // without the blind bonus (playtest 24). Switching on waits for the
      // next round.
      for (final c in clocks) {
        c
          ..blind = false
          ..mode = engine.modeMultiplier();
      }
    }
    if (autoBuyer != null) state.autoBuyerOn = autoBuyer;
    if (secondClock != null && secondClock != state.secondClockOn) {
      state.secondClockOn = secondClock;
      _rebuildClocks();
    }
    tipActed('modes');
    sfx.play('tick');
    notifyListeners();
    unawaited(save());
  }

  // --------------------------------------------------------------- input --

  /// Pointer-down on the arena; [clock] is the half that was touched.
  /// [eventTime] is the platform timestamp, used only for diagnostics; the
  /// grade comes from the clock read right here.
  void onPointerDown(Duration eventTime, {int clock = 0}) {
    if (_adPlaying) return;
    final t = now();
    diagnostics.recordInput(t, eventTime);
    unawaited(sfx.init()); // the web needs a gesture before audio starts
    final slot = clocks[clock.clamp(0, clocks.length - 1)];
    final wasWaiting = slot.round.phase == RoundPhase.waiting;
    _handle(slot, slot.round.tap(t));
    // Starting from rest: the second clock follows half a round later.
    if (wasWaiting && clocks.length > 1 && slot.index == 0) {
      final b = clocks[1].round;
      if (b.phase == RoundPhase.waiting) {
        _startSecondAt =
            t + slot.round.timeMap.realAt(balance.round.target) / 2;
      }
    }
  }

  /// QA builds only (store screenshots): holds the rounds still, so a
  /// result can be captured before the next round starts (R-RUNDA-6).
  bool qaFrozen = false;

  /// Called every frame by the arena.
  void tick() {
    if (qaFrozen) return;
    if (timeHeld) {
      // Game time stands still (R-AD-9): Frenzy, Hot hand, Turbo and the
      // golden clock wait for the player; the frame after counts from here.
      _lastTick = null;
      return;
    }
    final t = now();
    final last = _lastTick;
    _lastTick = t;
    final start = _startSecondAt;
    if (start != null && t >= start && clocks.length > 1) {
      _startSecondAt = null;
      _handle(clocks[1], clocks[1].round.tap(start));
    }
    var inZone = false;
    final idle = state.lifetime.missedInARow >= balance.round.idleStopAfter;
    // During the tutorial each round waits for a tap: the player reads
    // the bubbles without a new round already running (playtest). The
    // last step says it starts by itself from then on.
    final auto = !idle && state.tutorialDone && !replaying;
    for (final c in clocks) {
      c.round.autoStart = auto;
      _handle(c, c.round.update(t));
      inZone |= _roundSounds(c, t);
    }
    bulletZone.value = inZone; // notifies only on change
    sfx.music(
      engine.goldenRound
          ? MusicTrack.golden
          : engine.frenzyLeft > 0
          ? MusicTrack.frenzy
          : MusicTrack.calm,
    );
    if (last == null) return;
    // Long gaps (debugger, backgrounded tab) are offline time, not play.
    final dt = (t - last).clamp(0.0, 1.0);
    _econAcc += dt;
    final step = 1 / balance.economyTickHz;
    if (_econAcc >= step) {
      ads.tick(_econAcc);
      engine.tick(_econAcc);
      final golden = engine.goldenVisibleLeft > 0;
      if (golden && !_goldenShown) sfx.play('chimes', gain: 0.7);
      _goldenShown = golden;
      if (golden) {
        _tip('golden');
      } else if (pendingTip == 'golden') {
        // It flew away: say it again next time (not marked as seen).
        pendingTip = null;
      }
      _autoAdvance();
      final bonuses = _bonuses();
      if (engine.autoBuy(_econAcc) != null) {
        sfx.play('buy', gain: 0.4);
        _announceBonuses(bonuses);
        _checkLoop();
      }
      _econAcc = 0;
      notifyListeners();
    }
    _sinceAchievementCheck += dt;
    if (_sinceAchievementCheck >= 1) {
      _sinceAchievementCheck = 0;
      _checkAchievements(AchievementContext(passive: econ.passive()));
      if (engine.canPrestige()) _tip('prestige');
      _checkLoop();
      _windSprings();
      _announceDials();
      checkTips();
    }
    _sinceSave += dt;
    if (_sinceSave >= _saveEvery) unawaited(save());
  }

  void _handle(ClockSlot slot, RoundEvent? ev) {
    switch (ev) {
      case null:
        return;
      case TapIgnored():
        // Far too early to be an attempt: the round goes on (R-RUNDA-5a).
        state.stats.accidental++;
        notifyListeners();
      case RoundStarted():
        paused = false;
        if (slot.index == 0) syncSeason(); // a session can cross midnight
        engine.onRoundStart();
        slot
          ..mode = engine.modeMultiplier()
          ..blind = engine.blindActive
          ..lastTickTenth = -1;
        if (engine.goldenRound) sfx.play('coins');
        _roundStarts.add((slot.index, engine.goldenRound));
        notifyListeners();
      case RoundGraded(:final grade, :final gameTime):
        final o = engine.resolveRound(grade, mode: slot.mode);
        ads.onRound(o, _wallMs());
        _trackAccuracy();
        _trackTutorial();
        if (_replayStep == TutorialStep.aim) {
          _replayStep = TutorialStep.earned;
        }
        final local = _localNow();
        if (o.tier == Tier.perfect) engine.recordPerfectDate(local);
        // The dial read 5.00: the Mainspring winds faster (R-SPR-3).
        final wound = o.jackpot > 0 ? engine.springHit(_wallMs()) : 0.0;
        // An empty reserve is said once, until a hit winds again.
        var reserveEmpty = false;
        if (o.jackpot > 0 && econ.springsUnlocked) {
          if (wound > 0) {
            _reserveEmptyTold = false;
          } else if (!_reserveEmptyTold) {
            reserveEmpty = _reserveEmptyTold = true;
          }
        }
        _countForAchievements(slot, o.tier);
        if (state.comboStreak >= 3) _tip('combo');
        _playFeedback(o);
        _feedback.add(
          HitFeedback(
            o,
            gameTime,
            clock: slot.index,
            springSeconds: wound,
            springEmpty: reserveEmpty,
          ),
        );
        _afterSeasonProgress();
        _checkAchievements(
          AchievementContext(
            now: local,
            lastHitPerfect: o.tier == Tier.perfect,
            lastHitBlind: slot.blind,
            streak: state.comboStreak,
          ),
        );
        notifyListeners();
    }
  }

  bool _reserveEmptyTold = false;

  /// The clock of the last graded round if it was a PERFEKT.
  int? _lastPerfectClock;

  void _countForAchievements(ClockSlot slot, Tier tier) {
    final l = state.lifetime;
    if (tier != Tier.perfect) {
      _lastPerfectClock = null;
      return;
    }
    if (slot.blind) l.blindPerfects++;
    final other = _lastPerfectClock;
    if (other != null && other != slot.index) l.bothClocksPerfects++;
    _lastPerfectClock = slot.index;
  }

  /// How well the player times the stopwatch, at a few round counts:
  /// how fast players learn it (docs/03 tuning).
  void _trackAccuracy() {
    final st = state.stats;
    if (!accuracyCheckpoints.contains(st.rounds)) return;
    _log('accuracy', {
      'rounds': st.rounds,
      'typical_ms': (st.typicalError * 1000).round(),
      'mean_ms': (st.meanError * 1000).round(),
      'perfect_pct': (100 * st.byTier[Tier.perfect]! / st.rounds).round(),
      'miss_pct': (100 * st.byTier[Tier.miss]! / st.rounds).round(),
    });
  }

  void _playFeedback(RoundOutcome o) {
    // A skipped round (no touch) passes quietly: nobody is looking.
    if (o.raw.missKind == MissKind.noTap) return;
    // Ding rises a semitone every two streak steps, up to an octave (U-15).
    final pitch = math.pow(2, math.min(o.streak ~/ 2, 12) / 12).toDouble();
    switch (o.tier) {
      case Tier.perfect:
        sfx.play('perfect', speed: pitch);
        sfx.play('coins', gain: 0.6);
      case Tier.great:
        sfx.play('great', speed: pitch);
      case Tier.good:
        sfx.play('good');
      case Tier.miss when o.raw.close:
        sfx.play('good', gain: 0.6, speed: 0.8);
      case Tier.miss:
        sfx.play('miss');
    }
    if (o.comboBroken && o.streakBefore >= 3) sfx.play('combo_break');
    if (o.golden?.effect != null) sfx.play('buy', gain: 0.8);
    if (o.jackpot > 0) {
      sfx.play('fanfare', gain: 0.9);
      unawaited(haptics.medium());
    }
    unawaited(o.raw.close ? haptics.light() : haptics.forTier(o.tier));
  }

  /// Ticking in the last second and Zimna krew's heartbeat (docs/04 §3).
  /// Returns whether the clock is inside the bullet-time zone (U-19).
  /// Blind mode (docs/02 §7) hides the clock from [ModeConfig.hideDigitsAt]
  /// of game time: digits, progress ring, the bullet-time heartbeat and
  /// vignette. Ticking is a bought help and keeps going (playtest 22).
  bool blindHidden(ClockSlot slot, double gameTime) {
    final at = balance.blind.hideDigitsAt;
    return slot.blind &&
        slot.round.phase == RoundPhase.running &&
        at != null &&
        gameTime >= at;
  }

  bool _roundSounds(ClockSlot slot, double now) {
    final round = slot.round;
    if (round.phase != RoundPhase.running) return false;
    final g = round.gameTime(now);
    final r = balance.round;
    if (econ.level('ticking') > 0 && g >= r.target - 1 && g < r.target) {
      final tenth = (g * 10).floor();
      if (tenth != slot.lastTickTenth) {
        slot.lastTickTenth = tenth;
        sfx.play('tick', gain: 0.7);
        if (settings.haptics) unawaited(HapticFeedback.selectionClick());
      }
    }
    // Zimna krew: a heartbeat and a vignette around the target, at full
    // speed; the windows are wider, the clock never slows.
    final inZone =
        econ.level('bulletTime') > 0 &&
        round.timeMap.inFocusZone(g) &&
        !blindHidden(slot, g);
    if (inZone && now - slot.lastHeartbeat > 0.8) {
      slot.lastHeartbeat = now;
      sfx.play('heartbeat', gain: 0.8);
    }
    return inZone;
  }

  /// The player tapped the flying golden clock (R-ZLOTA-1).
  void claimGolden() {
    if (!engine.claimGolden()) return;
    _log('golden_catch');
    tipActed('golden');
    sfx.play('coins');
    if (settings.haptics) unawaited(HapticFeedback.mediumImpact());
    _afterSeasonProgress();
    notifyListeners();
  }

  // ------------------------------------------------------------- seasons --

  /// QA only (diagnostics, docs/05 T-12): runs this season whatever the
  /// date says; '' runs none (store screenshots). Not saved.
  String? seasonPreview;

  Season? get season => engine.season;

  /// Picks the season for today's local date (or the preview).
  void syncSeason() {
    final now = _localNow();
    final p = seasonPreview;
    engine.setSeason(
      p == null
          ? seasonAt(balance.seasons, now)
          : p.isEmpty
          ? null
          : seasonIn(balance.seasons, p, now.year),
    );
  }

  void previewSeason(String? id) {
    seasonPreview = id;
    syncSeason();
    notifyListeners();
  }

  /// Season ids whose theme is unlocked for good.
  List<String> get unlockedThemes => [
    for (final s in balance.seasons.list)
      if (state.seasonsDone.any((k) => k.startsWith('${s.id}-'))) s.id,
  ];

  /// The theme to draw: the running season, unless the player chose one.
  String? get themeId => switch (state.theme) {
    '' => season?.id,
    'classic' => null,
    final id => unlockedThemes.contains(id) ? id : season?.id,
  };

  void setTheme(String theme) {
    state.theme = theme;
    unawaited(save());
    notifyListeners();
  }

  /// The prologue (Chronos on the top shelf) is due: once, before the
  /// very first round, so a new player knows what the game is heading for.
  bool get prologuePending =>
      !state.tipsSeen.contains('prologue') &&
      !state.tutorialDone &&
      state.prestiges == 0 &&
      state.loopsDone == 0 &&
      state.earnedTotal == 0;

  void prologueShown() => state.tipsSeen.add('prologue');

  /// The season's intro dialog is due: once per season run, checked with
  /// the offline income and the daily bonus.
  bool seasonIntroPending = false;

  void seasonIntroShown() {
    seasonIntroPending = false;
    final s = season;
    if (s != null) state.tipsSeen.add('season:${s.key}');
  }

  void _afterSeasonProgress() {
    final paid = engine.seasonRewardPaid;
    if (paid == null) return;
    engine.seasonRewardPaid = null;
    _log('season_complete', {'season': season?.key ?? ''});
    sfx.play('fanfare', gain: 0.8);
    unawaited(haptics.medium());
    _seasonCompleted.add(paid);
    _checkAchievements(const AchievementContext());
    unawaited(save());
  }

  // -------------------------------------------------------- achievements --

  void _checkAchievements(AchievementContext ctx) {
    var any = false;
    for (final a in unlockAchievements(achievements, state, ctx)) {
      _unlocked.add(a);
      _log('unlock_achievement', {'achievement_id': a.id});
      any = true;
    }
    if (any) {
      sfx.play('fanfare', gain: 0.7);
      unawaited(haptics.medium());
    }
  }

  // ------------------------------------------------------------ shopping --

  BuyResult _afterBuy(BuyResult r) {
    if (r == BuyResult.ok) {
      _trackTutorial();
      sfx.play('buy');
      unawaited(haptics.light());
      _checkAchievements(const AchievementContext());
      if (_replayStep == TutorialStep.buyGrandpa) {
        _replayStep = TutorialStep.grandpaInfo;
      } else if (_shownFor == TutorialStep.grandpaInfo) {
        // Bought again with Grandpa's bubble up: the point was taken.
        nextTutorialStep();
      }
      _advanceTutorial();
      unawaited(save());
      notifyListeners();
    }
    return r;
  }

  BuyResult buyGenerators(String id, int count) {
    final first = econ.owned(id) == 0;
    final bonuses = _bonuses();
    final r = _afterBuy(engine.buyGenerators(id, count));
    if (r == BuyResult.ok) _announceBonuses(bonuses);
    if (r == BuyResult.ok) _checkLoop();
    if (r == BuyResult.ok && first) {
      _log('generator_first', {'id': id});
      analytics.setUserProperty('top_clock', _topClock);
    }
    // The first of a kind reveals the next generator (docs/04 §3).
    if (r == BuyResult.ok && first && id != balance.generators.last.id) {
      sfx.play('fanfare', gain: 0.6);
      unawaited(haptics.medium());
    }
    return r;
  }

  BuyResult buySkill(String id) {
    tipActed('skills');
    final r = _afterBuy(engine.buySkill(id));
    if (r == BuyResult.ok) {
      _log('skill_buy', {'id': id, 'level': state.skills[id] ?? 0});
    }
    return r;
  }

  /// Puts a skill in a Habit slot or takes it out (R-PRES-5b).
  void toggleHabit(String id) {
    final on = engine.toggleHabit(id);
    _log('habit', {'id': id, 'on': on ? 1 : 0});
    unawaited(save());
    notifyListeners();
  }

  BuyResult buyPerk(String id) {
    final r = _afterBuy(engine.buyPerk(id));
    if (r == BuyResult.ok) _log('perk_buy', {'id': id, 'shards': state.shards});
    return r;
  }

  // --------------------------------------- mainsprings (docs/12 §3.1) --

  /// Winds the Mainsprings up to now; a ready one rings.
  void _windSprings() {
    final ready = engine.windSprings(_wallMs());
    if (ready > 0) {
      sfx.play('chimes', gain: 0.5);
      notifyListeners();
    }
  }

  /// Raises clock [id] one level for Mainsprings (R-SPR-5).
  BuyResult levelClock(String id) {
    final r = engine.levelClock(id);
    if (r == BuyResult.ok) {
      _log('clock_level', {
        'id': id,
        'level': econ.clockLevel(id),
        'springs': state.springs,
      });
      sfx.play('fanfare', gain: 0.6);
      unawaited(haptics.medium());
      _checkAchievements(const AchievementContext());
      unawaited(save());
      notifyListeners();
    }
    return r;
  }

  /// The player read that the levels became mastery tiers (docs/13 §5.3).
  void ackSpringsRefund() {
    if (state.springsRefunded == 0) return;
    state.springsRefunded = 0;
    unawaited(save());
    notifyListeners();
  }

  // ----------------------------------------- time loops (docs/13 §5.2) --

  /// The goal of the loop was reached and its ending not shown yet.
  bool get loopEndPending =>
      state.loopGoal && !state.loopEndSeen && state.tutorialDone && !replaying;

  void loopEndShown() {
    // A new loop started from the ending has no ending to mark yet.
    if (!state.loopGoal || state.loopEndSeen) return;
    state.loopEndSeen = true;
    unawaited(save());
  }

  /// The loop's goal and the Mainsprings for its clock's bonuses
  /// (R-PETLA-1, 2a).
  void _checkLoop() {
    final r = engine.checkLoop();
    if (r.goalReached) {
      _log('loop_done', {
        'loop': state.loop,
        'rule': state.loopRules.join('+'),
        'play_min': (state.loopPlaySeconds / 60).round(),
        'paradoxes': state.loopPrestiges,
      });
      analytics.setUserProperty('loop', '${state.loop}');
      sfx.play('fanfare');
      unawaited(haptics.long());
      _announceDials();
    }
    if (r.springs > 0) {
      _milestones.add(MilestoneEvent.loopBonus(r.springs));
      sfx.play('chimes', gain: 0.6);
    }
    if (r.goalReached || r.springs > 0) {
      unawaited(save());
      notifyListeners();
    }
  }

  /// A new Time Loop (R-PETLA-3; the UI confirms first).
  bool startLoop() {
    if (!state.loopGoal) return false;
    pause();
    _rebuildClocks();
    if (!engine.startLoop(_wallMs())) return false;
    // The perks are gone, and the second clock with them.
    _rebuildClocks();
    ads.rescue = null;
    _log('loop_start', {
      'loop': state.loop,
      'rule': state.loopRules.join('+'),
      'springs': state.springs,
    });
    analytics.setUserProperty('loop', '${state.loop}');
    unawaited(save());
    notifyListeners();
    return true;
  }

  /// After the story the player picks the next loop's rules (R-PETLA-8).
  void toggleNextRule(String id) {
    if (!econ.storyDone) return;
    if (!state.nextRules.remove(id)) state.nextRules.add(id);
    unawaited(save());
    notifyListeners();
  }

  // ------------------------------------------- dials (docs/12 §3.3) --

  /// Celebrates every face the Tiki earned so far unlocked.
  void _announceDials() {
    for (final d in econ.unlockedDials) {
      if (state.dialsSeen.add(d.id)) {
        _milestones.add(MilestoneEvent.dial(d.id));
        _log('dial_unlock', {'id': d.id});
        sfx.play('fanfare', gain: 0.6);
      }
    }
  }

  void setDial(String id) {
    state.dial = id == balance.dials.first.id ? '' : id;
    unawaited(save());
    notifyListeners();
  }

  /// The rewind animation's sound and long buzz (docs/04 §3).
  void rewindEffects() {
    sfx.play('rewind');
    unawaited(haptics.long());
  }

  /// Time paradox in one go (R-PRES-6 confirms in the UI first).
  int prestige() {
    final gain = beginPrestige();
    finishPrestige();
    return gain;
  }

  /// Pays out Chronons and Shards; the run stays until [finishPrestige],
  /// so the Shards can buy perks for the new run first (R-PRES-6a).
  int beginPrestige() {
    pause();
    final top = _topClock;
    final gain = engine.beginPrestige();
    if (gain > 0) {
      _log('prestige', {'chronons': gain, 'top_clock': top});
      analytics.setUserProperty('prestiges', '${state.prestiges}');
      lastPrestigeGain = gain;
      ads.rescue = null;
      _checkAchievements(const AchievementContext());
      unawaited(save());
      notifyListeners();
    }
    return gain;
  }

  /// Chronons (and Shards) the last [beginPrestige] paid out.
  int lastPrestigeGain = 0;

  /// Waiting between [beginPrestige] and [finishPrestige].
  bool get rewindPending => state.rewindPending;

  /// Resets the run with the perks owned now.
  void finishPrestige() {
    if (!state.rewindPending) return;
    _rebuildClocks();
    engine.finishPrestige();
    // The run's upgrades are gone, and the second clock may be too.
    _rebuildClocks();
    _checkAchievements(const AchievementContext());
    unawaited(save());
    notifyListeners();
  }

  // ----------------------------------------------------------- ad offers --

  /// A rewarded offer's dialog is open (set by the UI around it).
  bool offerOpen = false;

  /// Game time stands still: an offer is being read or an ad plays
  /// (R-AD-9). On Android the ad covers the game without stopping its
  /// frames, so the timers would run on under it.
  bool get timeHeld => _adPlaying || offerOpen;

  /// Pauses the rounds, plays an ad and grants the offer only if it was
  /// watched to the end (R-AD-3). Returns whether the reward was granted.
  Future<bool> watchAd(AdOffer offer, RewardedAds provider) async {
    if (_adPlaying || !ads.available(offer, _wallMs())) return false;
    if (!provider.isReady) {
      _log('ad_unavailable', {'offer': offer.name});
      return false;
    }
    _adPlaying = true;
    pause();
    try {
      // The ad has its own sound: the game's music and effects stay quiet
      // until it closes (playtest 24: the music played over the ad).
      sfx.mute(true);
      final bool ok;
      try {
        ok = await provider.show();
      } finally {
        sfx.mute(false);
      }
      _log(ok ? 'ad_reward' : 'ad_closed_early', {'offer': offer.name});
      if (!ok) return false;
      final amount = ads.grant(
        offer,
        _wallMs(),
        offlineAmount: pendingOffline?.amount ?? 0,
      );
      if (amount > 0) sfx.play('coins');
      // The ad adds the extra; the base amount is collected with it.
      if (offer == AdOffer.offline) collectOffline();
      unawaited(save());
      return true;
    } finally {
      _adPlaying = false;
      _lastTick = null;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------ tutorial --

  /// The step of a replay asked for on the help screen by a player who
  /// already owns a clock: the steps can't be read off the state then, so
  /// they are walked by hand. Not saved: closing the app ends the replay.
  TutorialStep? _replayStep;
  bool get replaying => _replayStep != null;

  TutorialStep get tutorialStep {
    final replay = _replayStep;
    if (replay != null) return replay;
    if (state.tutorialDone) return TutorialStep.done;
    if (econ.owned('grandpa') == 0) {
      if (state.tiki >= balance.generators.first.baseCost) {
        return TutorialStep.buyGrandpa;
      }
      return state.tiki > 0 ? TutorialStep.earned : TutorialStep.aim;
    }
    return state.tipsSeen.contains(_grandpaInfoSeen)
        ? TutorialStep.autoStart
        : TutorialStep.grandpaInfo;
  }

  /// Saved with the tips: Grandpa's step was read (the last step follows).
  static const _grandpaInfoSeen = 'tutorial:grandpaInfo';

  /// The stopwatch shows when to tap (closing gold ring, R-TUT-1): during
  /// the tutorial and the first rounds of a new player.
  bool get coachTiming =>
      !state.tutorialDone ||
      replaying ||
      (state.prestiges == 0 && state.stats.rounds < coachRounds);
  static const coachRounds = 10;

  void _advanceTutorial() {
    if (!state.tutorialDone) notifyListeners();
  }

  // --------------------------------------------------------- next goal --

  /// The one thing to aim for next, shown over the shop (R-TUT-7). Until
  /// the first paradox: the first clock's first bonus, then each new
  /// clock (the first paradox is the player's call: a coach tip says it
  /// is ready, the bar does not push it). After it: a paradox that doubles the
  /// Chronons, the next new clock, the next perk (or the paradox that
  /// pays for it), then the clock bonus closest to done. Null when there
  /// is nothing to show.
  NextGoal? get nextGoal {
    if (!state.tutorialDone || replaying) return null;
    final gain = econ.prestigeGain();
    if (state.prestiges == 0) {
      final first = balance.generators.first.id;
      final bonus = econ.nextMilestone(first);
      if (econ.milestonesReached(first) == 0 && bonus != null) {
        return NextGoal(
          GoalKind.bonus,
          generator: first,
          have: econ.owned(first).toDouble(),
          need: bonus.toDouble(),
        );
      }
    } else if (!state.rewindPending && gain >= 5 && gain >= state.chronons) {
      return const NextGoal(GoalKind.prestige);
    }
    for (final g in balance.generators) {
      if (econ.owned(g.id) > 0 || !econ.generatorUnlocked(g.id)) continue;
      return NextGoal(
        GoalKind.newClock,
        generator: g.id,
        have: state.tiki,
        need: econ.generatorCost(g.id),
      );
    }
    if (state.prestiges == 0) return null;
    // The goal is reached: each bonus of its clock pays a Mainspring
    // (R-PETLA-2a).
    final goalClock = balance.loops.goal;
    final nextBonus = econ.nextMilestone(goalClock);
    if (state.loopGoal &&
        nextBonus != null &&
        econ.owned(goalClock) > 0 &&
        econ.milestonesReached(goalClock) >= state.loopBonusPaid) {
      return NextGoal(
        GoalKind.loopBonus,
        generator: goalClock,
        have: econ.owned(goalClock).toDouble(),
        need: nextBonus.toDouble(),
      );
    }
    // The cheapest perk within reach of the tree.
    PerkConfig? perk;
    for (final p in balance.prestige.perks) {
      if (!engine.perkAvailable(p.id)) continue;
      if (perk == null || p.cost < perk.cost) perk = p;
    }
    if (perk != null) {
      final have = state.shards.toDouble();
      // Affordable only with what a paradox would add: that is the goal.
      if (have < perk.cost && have + gain >= perk.cost) {
        return NextGoal(GoalKind.prestige, perk: perk.id);
      }
      return NextGoal(
        GoalKind.perk,
        perk: perk.id,
        have: have + gain,
        need: perk.cost.toDouble(),
      );
    }
    // Everything is unlocked: the clock bonus closest to done.
    NextGoal? best;
    for (final g in balance.generators) {
      final next = econ.nextMilestone(g.id);
      if (next == null) continue;
      final goal = NextGoal(
        GoalKind.bonus,
        generator: g.id,
        have: econ.owned(g.id).toDouble(),
        need: next.toDouble(),
      );
      if (best == null || goal.progress > best.progress) best = goal;
    }
    return best;
  }

  /// "OK" on Grandpa's step and the last one, and on every step of a
  /// replay (a player far into the game can't be asked to earn their first
  /// Tiks again).
  void nextTutorialStep() {
    final step = tutorialStep;
    if (step == TutorialStep.autoStart) {
      finishTutorial();
    } else if (step == TutorialStep.grandpaInfo && !replaying) {
      state.tipsSeen.add(_grandpaInfoSeen);
      _shownAt = null;
      _shownFor = null;
      _trackTutorial();
      notifyListeners();
      unawaited(save());
    } else if (replaying && step != TutorialStep.done) {
      _replayStep = TutorialStep.values[step.index + 1];
      notifyListeners();
    }
  }

  /// Finishes (or skips) the tutorial (R-TUT-1).
  void finishTutorial() {
    if (replaying) {
      _replayStep = null;
      _shownAt = null;
      _shownFor = null;
      engine.goldenEnabled = state.tutorialDone;
      _tipQuietUntil = state.playSeconds + tipGapAfterTutorial;
      notifyListeners();
      return;
    }
    if (!state.tutorialDone) {
      // 'autoStart' = finished; any earlier step = skipped.
      _log('tutorial_complete', {
        'at_step': tutorialStep.name,
        'rounds': state.stats.rounds,
      });
      analytics.setUserProperty('tutorial_done', 'true');
    }
    state.tutorialDone = true;
    engine.goldenEnabled = true;
    // A breather before the first tip (R-TUT-2: tips are spaced out).
    _tipQuietUntil = state.playSeconds + tipGapAfterTutorial;
    _shownAt = null;
    _shownFor = null;
    notifyListeners();
    unawaited(save());
  }

  /// Shows the whole tutorial again (help screen), whatever the player
  /// owns. Tips already seen stay seen.
  void replayTutorial() {
    _log('tutorial_replay');
    pendingTip = null;
    _shownAt = null;
    _shownFor = null;
    engine.goldenEnabled = false;
    if (econ.owned(balance.generators.first.id) == 0) {
      // Nothing bought yet: the real first run, read off the state.
      _loggedStep = null;
      state.tutorialDone = false;
      state.tipsSeen.remove(_grandpaInfoSeen);
      unawaited(save());
    } else {
      _replayStep = TutorialStep.aim;
    }
    notifyListeners();
  }

  // Tips (R-TUT-2): one at a time, spaced out, and gone as soon as the
  // player does what they say.
  static const tipGap = 45.0; // s of play between two tips
  static const tipGapAfterTutorial = 20.0;
  static const infoSeconds = 7.0; // tips that ask for nothing close alone
  static const tipLife = 15.0; // s of play an ignored tip stays up
  static const milestoneTipAt = 3; // Grandpas before the bonus bar tip
  double _tipQuietUntil = 0;

  /// Play time when the current info bubble appeared.
  double? _shownAt;
  Object? _shownFor;

  void _tip(String id) {
    if (!state.tutorialDone || replaying || pendingTip != null) return;
    if (state.tipsSeen.contains(id)) return;
    if (state.playSeconds < _tipQuietUntil) return;
    pendingTip = id;
  }

  /// The player did what tip [id] asked: it closes and is never shown again.
  void tipActed(String id) {
    if (pendingTip == id) {
      dismissTip();
    } else {
      state.tipsSeen.add(id);
    }
  }

  /// The combo tip, which asks for nothing, closes by itself after
  /// [infoSeconds] of play. Grandpa's step does not (testers never saw it:
  /// it was gone in 7 s): it waits for "OK" or the next purchase
  /// ([_afterBuy]). A tip asking for something the player
  /// ignores goes after [tipLife] and comes back once, later (onboarding
  /// playtest: an ignored upgrade tip stayed for minutes and held back
  /// every tip after it).
  void _autoAdvance() {
    final Object? key = tutorialStep == TutorialStep.grandpaInfo
        ? TutorialStep.grandpaInfo
        : pendingTip;
    // The paradox tip is a tutorial step: it stays until closed or acted
    // on (the goal bar no longer points at the first paradox).
    if (key == null || key == 'golden' || key == 'prestige') {
      _shownAt = null;
      _shownFor = null;
      return;
    }
    if (_shownFor != key) {
      _shownFor = key;
      _shownAt = state.playSeconds;
      return;
    }
    if (key == TutorialStep.grandpaInfo) return;
    final age = state.playSeconds - _shownAt!;
    final info = key == 'combo';
    if (age < (info ? infoSeconds : tipLife)) return;
    _shownAt = null;
    _shownFor = null;
    if (info || state.tipsSeen.contains('$key#1')) {
      dismissTip();
    } else {
      // Not now: once more after the usual gap.
      state.tipsSeen.add('$key#1');
      pendingTip = null;
      _tipQuietUntil = state.playSeconds + tipGap;
      notifyListeners();
    }
  }

  @visibleForTesting
  void debugAutoAdvance() => _autoAdvance();

  /// Tips for things that appear outside the screen the player looks at
  /// (playtest: the skills tab, the upgrade strip and the toggles went
  /// unnoticed for a long time).
  void checkTips() {
    if (!state.tutorialDone || replaying || pendingTip != null) return;
    // The first clock's bonus bar, once it has a few (R-ULEP-1).
    final first = balance.generators.first.id;
    if (econ.owned(first) >= milestoneTipAt &&
        econ.milestonesReached(first) == 0) {
      _tip('milestone');
    }
    if (skillAffordable) _tip('skills');
    // After the first paradox and the first new loop: one line each, on
    // the thing that appeared (docs/12 §3.1, docs/13 §5.2).
    if (state.loop > 1) _tip('loop');
    if (econ.springsUnlocked) _tip('springs');
    if (engine.blindUnlocked() ||
        state.perks.contains('secondClock') ||
        state.perks.contains('autoBuyer')) {
      _tip('modes');
    }
    if (pendingTip != null) notifyListeners();
  }

  void dismissTip() {
    final t = pendingTip;
    if (t == null) return;
    state.tipsSeen.add(t);
    pendingTip = null;
    _tipQuietUntil = state.playSeconds + tipGap;
    notifyListeners();
  }

  /// R-UMIEJ-3: a skill card shows once the player has held half its first
  /// price.
  bool skillRevealed(String id) =>
      econ.level(id) > 0 ||
      state.peakTiki >=
          balance.skill(id).baseCost * balance.ui.skillRevealFraction;

  /// A skill the player can buy right now (the red dot on its tab).
  bool get skillAffordable => balance.skills.any((sk) {
    if (!skillRevealed(sk.id)) return false;
    final cost = econ.skillCost(sk.id);
    return cost != null && cost <= state.tiki;
  });

  /// A clock the player can buy right now (the red dot on its tab).
  bool get generatorAffordable => balance.generators.any(
    (g) =>
        econ.generatorUnlocked(g.id) &&
        econ.generatorCost(g.id) <= state.tiki &&
        _generatorShown(g.id),
  );

  bool _generatorShown(String id) {
    final i = balance.generators.indexWhere((g) => g.id == id);
    return i == 0 ||
        econ.owned(id) > 0 ||
        econ.owned(balance.generators[i - 1].id) > 0;
  }

  // -------------------------------------------------------- offline/save --

  /// Checks for offline income (start-up and every resume).
  void checkOffline() {
    syncSeason();
    final s = season;
    seasonIntroPending =
        s != null &&
        state.tutorialDone &&
        !state.tipsSeen.contains('season:${s.key}');
    if (state.lastSeenMs > 0) {
      engine.onReturn((_wallMs() - state.lastSeenMs) / 1000);
    }
    _checkLoop(); // also a save from before the loops
    pendingOffline = engine.offlineSince(_wallMs());
    // Saved until collected: closing the app over the summary loses nothing.
    engine.holdOffline(pendingOffline);
    if (pendingOffline != null) unawaited(save());
    pendingDaily = engine.dailyFor(_localNow());
    state.lastSeenMs = _wallMs();
    engine.windSprings(_wallMs());
    if (pendingOffline != null || pendingDaily != null || seasonIntroPending) {
      notifyListeners();
    }
  }

  /// Today's daily bonus waiting in its dialog (playtest 08), or null.
  DailyBonus? pendingDaily;

  void collectDaily() {
    final d = pendingDaily;
    if (d == null) return;
    engine.claimDaily(d);
    _log('daily_collect', {'day': d.day});
    pendingDaily = null;
    sfx.play('fanfare', gain: 0.7);
    unawaited(haptics.medium());
    unawaited(save());
    notifyListeners();
  }

  void collectOffline({double multiplier = 1}) {
    final r = pendingOffline;
    if (r == null) return;
    engine.claimOffline(r, multiplier: multiplier);
    _log('offline_collect', {
      'away_min': (r.awaySeconds / 60).round(),
      'capped': r.countedSeconds < r.awaySeconds ? 1 : 0,
    });
    pendingOffline = null;
    sfx.play('coins');
    unawaited(save());
    notifyListeners();
  }

  Future<void> save() async {
    if (_retired) return;
    _sinceSave = 0;
    state.lastSeenMs = _wallMs();
    final store = this.store;
    if (store == null) return;
    try {
      await store.write(
        saveToJsonString(
          SaveData(state, settings, balanceVersion: balance.version),
        ),
      );
    } on Object catch (e) {
      debugPrint('save failed: $e');
    }
  }

  /// App hidden, a panel covers the clock or an ad plays (R-RUNDA-8).
  /// The stopwatch was stopped (pause button, shop, a sheet, leaving the
  /// app): the dial says so until the next round starts (docs/04 U-29).
  bool paused = false;

  /// The pause button: stops the running round, or starts one when
  /// stopped.
  void togglePause() {
    final running = clocks.any((c) => c.round.phase != RoundPhase.waiting);
    if (running) {
      pause();
      paused = true;
      notifyListeners();
    } else {
      onPointerDown(Duration.zero);
    }
  }

  void pause() {
    var changed = false;
    for (final c in clocks) {
      if (c.round.phase != RoundPhase.waiting) {
        c.round.cancel();
        engine.onRoundCancelled();
        changed = true;
      }
    }
    if (changed) paused = true;
    _startSecondAt = null;
    sfx.underwater(false);
    if (changed) notifyListeners();
    _lastTick = null;
    unawaited(save());
  }

  /// Leaving the app: also schedules the "offline limit reached"
  /// notification (R-OFF-4).
  void background({required String Function(String amount) title}) {
    pause();
    if (!settings.notifications) return;
    final rate = econ.passive() * engine.offlineEfficiency();
    if (rate <= 0) return;
    final cap = engine.offlineCapSeconds();
    unawaited(
      notifications.scheduleOfflineFull(
        DateTime.now().add(Duration(seconds: cap.round())),
        rate * cap,
        title,
      ),
    );
  }

  void resume() {
    _lastTick = null;
    unawaited(notifications.cancel());
    checkOffline();
  }

  @override
  void dispose() {
    _feedback.close();
    _seasonCompleted.close();
    _roundStarts.close();
    _unlocked.close();
    _milestones.close();
    super.dispose();
  }
}

/// T-12: how far the moment we read the clock lags the platform's touch
/// timestamp. Only the spread matters (a constant offset is fine); a large
/// spread would mean grades depend on frame timing.
class InputDiagnostics {
  final List<double> _offsets = [];

  void recordInput(double clockSeconds, Duration eventTime) {
    if (eventTime == Duration.zero) return;
    _offsets.add(clockSeconds - eventTime.inMicroseconds / 1e6);
    if (_offsets.length > 100) _offsets.removeAt(0);
  }

  int get samples => _offsets.length;

  /// Largest deviation of the input offset from its mean, in ms.
  double get jitterMs {
    if (_offsets.length < 2) return 0;
    final mean = _offsets.reduce((a, b) => a + b) / _offsets.length;
    final dev = _offsets.map((o) => (o - mean).abs());
    return dev.reduce((a, b) => a > b ? a : b) * 1000;
  }
}

/// Loads the save (falling back to the backup, then to a fresh game, T-20)
/// and returns a ready controller with offline income checked.
Future<GameController> loadGame(
  Balance balance,
  SaveStore store, {
  OfflineNotifications notifications = const NoNotifications(),
  Analytics analytics = const NoAnalytics(),
  Sfx? sfx,
  Haptics? haptics,
}) async {
  SaveData? data;
  var corrupt = false;
  for (final read in [store.read, store.readBackup]) {
    try {
      final text = await read();
      if (text == null) break;
      data = saveFromJsonString(text);
      break;
    } on Object catch (e) {
      corrupt = true;
      debugPrint('save unreadable: $e');
    }
  }
  final c = GameController(
    balance: balance,
    state: data?.state,
    settings: data?.settings,
    store: store,
    notifications: notifications,
    analytics: analytics,
    sfx: sfx,
    haptics: haptics,
  );
  c.saveWasCorrupt = corrupt && data == null;
  c.checkOffline();
  return c;
}
