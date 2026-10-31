import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ads/rewarded_ads.dart';
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
  HitFeedback(this.outcome, this.gameTime, {this.clock = 0});
  final RoundOutcome outcome;
  final double gameTime;

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

/// First-run steps (R-TUT-1): aim, earn, buy Grandpa, what he does.
enum TutorialStep { aim, earned, buyGrandpa, grandpaInfo, done }

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
    int Function()? wallClockMs,
    DateTime Function()? localNow,
  }) : state = state ?? GameState(),
       settings = settings ?? Settings(),
       sfx = sfx ?? Sfx(),
       haptics = haptics ?? Haptics(),
       _wallMs = wallClockMs ?? (() => DateTime.now().millisecondsSinceEpoch),
       _localNow = localNow ?? DateTime.now {
    engine = GameEngine(balance, this.state);
    ads = AdOffers(engine);
    achievements = buildAchievements(balance);
    _rebuildClocks();
    _applySettings();
    engine.goldenEnabled = this.state.tutorialDone;
    syncSeason();
  }

  final Balance balance;
  final GameState state;
  final Settings settings;
  final SaveStore? store;
  final Sfx sfx;
  final Haptics haptics;
  final OfflineNotifications notifications;
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
  }

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
    if (blind != null) state.modeBlind = blind;
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
    for (final c in clocks) {
      c.round.autoStart = !idle;
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
      if (engine.autoBuy(_econAcc) != null) sfx.play('buy', gain: 0.4);
      _econAcc = 0;
      notifyListeners();
    }
    _sinceAchievementCheck += dt;
    if (_sinceAchievementCheck >= 1) {
      _sinceAchievementCheck = 0;
      _checkAchievements(const AchievementContext());
      if (engine.canPrestige()) _tip('prestige');
      checkTips();
    }
    _sinceSave += dt;
    if (_sinceSave >= _saveEvery) unawaited(save());
  }

  void _handle(ClockSlot slot, RoundEvent? ev) {
    switch (ev) {
      case null:
        return;
      case RoundStarted():
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
        final local = _localNow();
        if (o.tier == Tier.perfect) engine.recordPerfectDate(local);
        if (state.comboStreak >= 3) _tip('combo');
        _playFeedback(o);
        _feedback.add(HitFeedback(o, gameTime, clock: slot.index));
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
    final inZone = econ.level('bulletTime') > 0 && round.timeMap.inFocusZone(g);
    if (inZone && now - slot.lastHeartbeat > 0.8) {
      slot.lastHeartbeat = now;
      sfx.play('heartbeat', gain: 0.8);
    }
    return inZone;
  }

  /// The player tapped the flying golden clock (R-ZLOTA-1).
  void claimGolden() {
    if (!engine.claimGolden()) return;
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
      sfx.play('buy');
      unawaited(haptics.light());
      _checkAchievements(const AchievementContext());
      _advanceTutorial();
      unawaited(save());
      notifyListeners();
    }
    return r;
  }

  BuyResult buyGenerators(String id, int count) {
    final first = econ.owned(id) == 0;
    final r = _afterBuy(engine.buyGenerators(id, count));
    // The first of a kind reveals the next generator (docs/04 §3).
    if (r == BuyResult.ok && first && id != balance.generators.last.id) {
      sfx.play('fanfare', gain: 0.6);
      unawaited(haptics.medium());
    }
    return r;
  }

  BuyResult buyUpgrade(String id) {
    tipActed('upgrade');
    return _afterBuy(engine.buyUpgrade(id));
  }

  BuyResult buySynergy(String id) {
    tipActed('upgrade');
    return _afterBuy(engine.buySynergy(id));
  }

  BuyResult buySkill(String id) {
    tipActed('skills');
    return _afterBuy(engine.buySkill(id));
  }

  BuyResult buyPerk(String id) => _afterBuy(engine.buyPerk(id));

  /// The rewind animation's sound and long buzz (docs/04 §3).
  void rewindEffects() {
    sfx.play('rewind');
    unawaited(haptics.long());
  }

  /// Time paradox (R-PRES-6 confirms in the UI first).
  int prestige() {
    _rebuildClocks();
    final gain = engine.prestige();
    // The run's upgrades are gone, and the second clock may be too.
    _rebuildClocks();
    if (gain > 0) {
      ads.rescue = null;
      _checkAchievements(const AchievementContext());
      unawaited(save());
      notifyListeners();
    }
    return gain;
  }

  // ----------------------------------------------------------- ad offers --

  /// Pauses the rounds, plays an ad and grants the offer only if it was
  /// watched to the end (R-AD-3). Returns whether the reward was granted.
  Future<bool> watchAd(AdOffer offer, RewardedAds provider) async {
    if (_adPlaying || !ads.available(offer, _wallMs()) || !provider.isReady) {
      return false;
    }
    _adPlaying = true;
    pause();
    try {
      final ok = await provider.show();
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

  TutorialStep get tutorialStep {
    if (state.tutorialDone) return TutorialStep.done;
    if (econ.owned('grandpa') == 0) {
      if (state.tiki >= balance.generators.first.baseCost) {
        return TutorialStep.buyGrandpa;
      }
      return state.tiki > 0 ? TutorialStep.earned : TutorialStep.aim;
    }
    return TutorialStep.grandpaInfo;
  }

  /// The stopwatch shows when to tap (closing gold ring, R-TUT-1): during
  /// the tutorial and the first rounds of a new player.
  bool get coachTiming =>
      !state.tutorialDone ||
      (state.prestiges == 0 && state.stats.rounds < coachRounds);
  static const coachRounds = 10;

  void _advanceTutorial() {
    if (!state.tutorialDone) notifyListeners();
  }

  /// "OK" on Grandpa's step (it also closes by itself, [_autoAdvance]).
  void nextTutorialStep() {
    if (tutorialStep == TutorialStep.grandpaInfo) finishTutorial();
  }

  /// Finishes (or skips) the tutorial (R-TUT-1).
  void finishTutorial() {
    state.tutorialDone = true;
    engine.goldenEnabled = true;
    // A breather before the first tip (R-TUT-2: tips are spaced out).
    _tipQuietUntil = state.playSeconds + tipGapAfterTutorial;
    _shownAt = null;
    notifyListeners();
    unawaited(save());
  }

  /// Shows the tutorial again from where the player is (help screen).
  /// Tips already seen stay seen.
  void replayTutorial() {
    state.tutorialDone = false;
    pendingTip = null;
    _shownAt = null;
    engine.goldenEnabled = false;
    notifyListeners();
    unawaited(save());
  }

  // Tips (R-TUT-2): one at a time, spaced out, and gone as soon as the
  // player does what they say.
  static const tipGap = 45.0; // s of play between two tips
  static const tipGapAfterTutorial = 20.0;
  static const infoSeconds = 7.0; // tips that ask for nothing close alone
  static const tipLife = 15.0; // s of play an ignored tip stays up
  double _tipQuietUntil = 0;

  /// Play time when the current info bubble appeared.
  double? _shownAt;
  Object? _shownFor;

  void _tip(String id) {
    if (!state.tutorialDone || pendingTip != null) return;
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

  /// Info-only bubbles (Grandpa's step, the combo tip) close by themselves
  /// after [infoSeconds] of play; a tip asking for something the player
  /// ignores goes after [tipLife] and comes back once, later (onboarding
  /// playtest: an ignored upgrade tip stayed for minutes and held back
  /// every tip after it).
  void _autoAdvance() {
    final Object? key = tutorialStep == TutorialStep.grandpaInfo
        ? TutorialStep.grandpaInfo
        : pendingTip;
    if (key == null || key == 'golden') {
      _shownAt = null;
      _shownFor = null;
      return;
    }
    if (_shownFor != key) {
      _shownFor = key;
      _shownAt = state.playSeconds;
      return;
    }
    final age = state.playSeconds - _shownAt!;
    final info = key == TutorialStep.grandpaInfo || key == 'combo';
    if (age < (info ? infoSeconds : tipLife)) return;
    _shownAt = null;
    _shownFor = null;
    if (key == TutorialStep.grandpaInfo) {
      nextTutorialStep();
    } else if (info || state.tipsSeen.contains('$key#1')) {
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
    if (!state.tutorialDone || pendingTip != null) return;
    // Only once one can be bought: a tip the player can't act on just
    // hangs there (onboarding playtest).
    if (econ.availableUpgrades().any((u) => u.cost <= state.tiki) ||
        econ.availableSynergies().any((x) => x.cost <= state.tiki)) {
      _tip('upgrade');
    }
    if (skillAffordable) _tip('skills');
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
    pendingOffline = engine.offlineSince(_wallMs());
    pendingDaily = engine.dailyFor(_localNow());
    state.lastSeenMs = _wallMs();
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
  void pause() {
    var changed = false;
    for (final c in clocks) {
      if (c.round.phase != RoundPhase.waiting) {
        c.round.cancel();
        engine.onRoundCancelled();
        changed = true;
      }
    }
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
    sfx: sfx,
    haptics: haptics,
  );
  c.saveWasCorrupt = corrupt && data == null;
  c.checkOffline();
  return c;
}
