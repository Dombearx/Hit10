import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ads/rewarded_ads.dart';
import '../analytics/analytics.dart';
import '../balance/balance.dart';
import '../engine/ad_offers.dart';
import '../engine/game_engine.dart';
import '../engine/notification_plan.dart';
import '../engine/round_engine.dart';
import '../engine/tap_clock.dart';
import '../model/achievements.dart';
import '../model/challenges.dart';
import '../model/economy.dart';
import '../model/features.dart';
import '../model/game_state.dart';
import '../model/grading.dart';
import '../model/number_format.dart';
import '../model/seasons.dart';
import '../model/settings.dart';
import '../model/showcase.dart';
import '../persistence/cloud_save.dart';
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
/// What a clock trait announces with a toast (docs/18).
enum TraitNotice { unlocked, cuckoo, warmUp, express, loopChronons }

class MilestoneEvent {
  const MilestoneEvent.generator(String this.generator, this.index)
    : synergy = null,
      dial = null,
      loopSprings = 0,
      trait = null,
      value = 0,
      text = '';
  const MilestoneEvent.synergy(String this.synergy)
    : generator = null,
      index = 0,
      dial = null,
      loopSprings = 0,
      trait = null,
      value = 0,
      text = '';

  /// A new stopwatch face (docs/12 §3.3).
  const MilestoneEvent.dial(String this.dial)
    : generator = null,
      synergy = null,
      index = 0,
      loopSprings = 0,
      trait = null,
      value = 0,
      text = '';

  /// Mainsprings for bonuses of the loop's goal clock (R-PETLA-2a).
  const MilestoneEvent.loopBonus(this.loopSprings)
    : generator = null,
      synergy = null,
      dial = null,
      index = 0,
      trait = null,
      value = 0,
      text = '';

  /// Clock [generator]'s trait at work: [index] is the trait tier for
  /// [TraitNotice.unlocked]; [value] and [text] what the toast shows.
  const MilestoneEvent.trait(
    String this.generator,
    TraitNotice this.trait, {
    this.index = 0,
    this.value = 0,
    this.text = '',
  }) : synergy = null,
       dial = null,
       loopSprings = 0;

  final int loopSprings;
  final String? generator;
  final int index;
  final String? synergy;
  final String? dial;
  final TraitNotice? trait;
  final double value;
  final String text;
}

/// One stopwatch and what was fixed when its round started (R-TRYB-1).
class ClockSlot {
  ClockSlot(this.index, this.round);
  final int index;
  final RoundEngine round;
  double mode = 1;
  bool blind = false;

  /// When Blind hides this round's clock (game time), drawn at the start
  /// of every round so switching Blind on mid-round has one too.
  double? hideAt;
  int lastTickTenth = -1;
  double lastHeartbeat = -10;
}

/// First-run steps (R-TUT-1): aim, earn, buy Grandpa, what he does, and
/// that the stopwatch starts by itself from now on.
enum TutorialStep { aim, earned, buyGrandpa, grandpaInfo, autoStart, done }

enum GoalKind { bonus, newClock, unlockClock, newLoop }

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

  /// The perk that unlocks the clock ([GoalKind.unlockClock]).
  final String? perk;

  /// The clock it is about (not for [GoalKind.newLoop]).
  final String? generator;

  /// Progress: clocks owned of the bonus' threshold, Tiks of the price, or
  /// Shards (with those a paradox would add) of the key perk's.
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
    this.cloud = const NoCloudSave(),
    this._consentRequired = false,
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
  final CloudSave cloud;
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
    var gained = 0;
    for (final g in balance.generators) {
      for (var k = before.$1[g.id]!; k < econ.milestonesReached(g.id); k++) {
        _milestones.add(MilestoneEvent.generator(g.id, k));
        any = true;
        gained++;
      }
    }
    if (gained > 0) _challengeAdd(ChallengeKind.milestones, gained.toDouble());
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
    analytics.setConsent(statsConsent);
  }

  // ------------------------------------------------------------- consent --

  /// Whether the law asks for consent where the player is (EEA, UK; from
  /// the ad network's consent check), null while unknown (docs/05 T-33).
  bool? _consentRequired;

  /// The ad network told us whether consent is needed here.
  void setConsentRequired(bool? required) {
    if (required == _consentRequired) return;
    _consentRequired = required;
    _applySettings();
    notifyListeners();
  }

  /// Statistics and crash reports: off when the player said no; sent when
  /// they said yes or no consent is needed; otherwise held on the phone
  /// until they answer (T-33).
  StatsConsent get statsConsent {
    if (!settings.analytics) return StatsConsent.off;
    if (settings.analyticsAsked || _consentRequired == false) {
      return StatsConsent.on;
    }
    return StatsConsent.held;
  }

  /// Time to ask about statistics: consent is (or may be) required, the
  /// player has not answered, and the tutorial is over — a natural break,
  /// not the first seconds of the game (docs/02 R-TUT-0).
  bool get statsQuestionPending =>
      settings.analytics &&
      !settings.analyticsAsked &&
      _consentRequired != false &&
      state.tutorialDone &&
      !replaying;

  void answerStatsQuestion({required bool yes}) {
    settings
      ..analytics = yes
      ..analyticsAsked = true;
    applySettings();
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
  void adOfferAnswered(AdOffer offer, {required bool watch}) {
    _offersShown.remove(offer);
    _log('ad_offer', {'offer': offer.name, 'watch': watch ? 1 : 0});
  }

  /// Offers on screen that already said so since the last answer, ad or
  /// return to the game.
  final _offersShown = <AdOffer>{};

  /// A rewarded offer is on screen and can be taken (docs/05 §8a): the
  /// denominator of the take rate. Safe to call on every build: it logs
  /// once per appearance, again after the player answers or watches it,
  /// and after the game comes back from the background.
  void adOfferShown(AdOffer offer) {
    if (!_offersShown.add(offer)) return;
    _log('ad_offer_shown', {'offer': offer.name});
  }

  /// Bumped on every settings change; the app rebuilds its locale from it.
  final settingsVersion = ValueNotifier<int>(0);

  void applySettings() {
    _applySettings();
    settingsVersion.value++;
    notifyListeners();
    unawaited(save());
  }

  // ---------------------------------------------- cloud save (T-35) --

  /// Signed in to Play Games (the settings show it).
  bool cloudSignedIn = false;

  /// When this phone last wrote the cloud save (wall clock), 0 = never in
  /// this session.
  int cloudSavedAtMs = 0;

  /// A cloud save with more progress than this phone's, waiting for the
  /// player's answer (T-35: never loaded without asking).
  CloudOffer? cloudOffer;

  /// Cloud saves the player chose not to load, by their play seconds.
  Set<int> get _cloudDeclined => {
    for (final t in state.tipsSeen)
      if (t.startsWith('cloudDeclined:')) ?int.tryParse(t.substring(14)),
  };

  /// At launch: signed in? Then is the cloud ahead of this phone?
  /// [manual]: the player asked from the settings; any save with more play
  /// is offered, even one turned down before. Returns the offer, if any.
  Future<CloudOffer?> checkCloud({bool manual = false}) async {
    if (!cloud.available) return null;
    cloudSignedIn = await cloud.signedIn();
    notifyListeners();
    if (!cloudSignedIn) return null;
    final offer = CloudSync.offer(
      await cloud.load(),
      state.lifetime.secondsPlayed,
      declined: manual ? const {} : _cloudDeclined,
    );
    if (!manual) cloudOffer = offer;
    notifyListeners();
    return offer;
  }

  /// The player answered [cloudOffer]: load it (the app restarts after,
  /// like an import) or keep this phone's progress, which the next upload
  /// writes over it.
  Future<bool> answerCloudOffer(CloudOffer offer, {required bool load}) async {
    cloudOffer = null;
    _log('cloud_offer', {
      'load': load ? 1 : 0,
      'lead_min': ((offer.playSeconds - state.lifetime.secondsPlayed) / 60)
          .round(),
    });
    if (load) {
      await importText(offer.text);
      return true;
    }
    state.tipsSeen.add('cloudDeclined:${offer.playSeconds.round()}');
    unawaited(save());
    notifyListeners();
    return false;
  }

  /// The player connects Play Games from the settings.
  Future<void> signInCloud() async {
    cloudSignedIn = await cloud.signIn();
    _log('cloud_connect', {'ok': cloudSignedIn ? 1 : 0});
    notifyListeners();
    if (cloudSignedIn) await uploadCloud(force: true);
  }

  /// Writes this phone's progress to the cloud (leaving the app; at most
  /// once a minute unless [force]). Not while an offer is unanswered: the
  /// cloud may hold the progress the player wants back.
  Future<void> uploadCloud({bool force = false}) async {
    if (!cloud.available || !cloudSignedIn || cloudOffer != null) return;
    // Leaving the app fires twice in a row: one upload at a time.
    if (_retired || _uploading) return;
    final now = _wallMs();
    if (!force &&
        now - cloudSavedAtMs < CloudSync.minUploadGap.inMilliseconds) {
      return;
    }
    _uploading = true;
    try {
      final played = state.lifetime.secondsPlayed;
      final ok = await cloud.save(
        exportText(),
        played: Duration(seconds: played.round()),
        description: 'Hit5 · ${(played / 3600).toStringAsFixed(1)} h',
      );
      if (ok) {
        cloudSavedAtMs = now;
        notifyListeners();
      }
    } finally {
      _uploading = false;
    }
  }

  bool _uploading = false;

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
    await _retire();
    await store?.write(saveToJsonString(data));
  }

  /// Wipes the progress but keeps the player's settings.
  Future<void> resetProgress() async {
    await _retire();
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
        engine.onRoundCancelled(c.index);
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
      // without the blind bonus (playtest 24).
      for (final c in clocks) {
        c
          ..blind = false
          ..mode = engine.modeMultiplier();
      }
    } else if (blind == true && engine.blindActive) {
      // On before the digits would go: nothing that will be hidden has been
      // seen yet, so this round turns blind and pays for it at once. Later
      // it waits for the next round (R-TRYB-1, playtest 28: switched on
      // mid-round it looked as if it did nothing for two or three rounds).
      final t = now();
      for (final c in clocks) {
        final at = c.hideAt;
        if (c.round.phase == RoundPhase.running &&
            at != null &&
            c.round.gameTime(t) < at) {
          c
            ..blind = true
            ..mode = engine.modeMultiplier();
        }
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

  /// Points the auto buyer at clock [id], up to its next bonus, and
  /// switches it on (docs/02 §9.3).
  void setAutoTarget(String id) {
    if (!engine.setAutoTarget(id)) return;
    state.autoBuyerOn = true;
    _log('auto_target', {'clock': id, 'until': state.autoUntil});
    tipActed('modes');
    sfx.play('tick');
    notifyListeners();
    unawaited(save());
  }

  /// How long the auto buyer has stood still, and whether it has nudged
  /// the player about it yet: once per stop, never again (docs/02 §9.3).
  double _autoWaitSecs = 0;
  bool _autoNudged = false;

  /// Goes up by one when the waiting auto buyer nudges (its chip pulses).
  int autoNudge = 0;

  @visibleForTesting
  void autoWatch(double dt) {
    if (!engine.autoBuyerWaiting) {
      _autoWaitSecs = 0;
      _autoNudged = false;
      return;
    }
    _autoWaitSecs += dt;
    final after = balance.perk('autoBuyer').params['remindAfterSeconds']!;
    if (!_autoNudged && _autoWaitSecs >= after) {
      _autoNudged = true;
      autoNudge++;
    }
  }

  // --------------------------------------------------------------- input --

  /// Pointer-down on the arena; [clock] is the half that was touched.
  /// [eventTime] is the platform timestamp, used only for diagnostics; the
  /// grade comes from the clock read right here.
  void onPointerDown(Duration eventTime, {int clock = 0}) {
    if (_adPlaying) return;
    final handler = now();
    // When the touch happened, not when the busy UI thread got to it
    // (T-10): the platform stamp mapped onto our clock.
    final t = tapClock.tapTime(
      handler,
      eventTime == Duration.zero ? null : eventTime.inMicroseconds / 1e6,
    );
    diagnostics.recordInput(handler, eventTime, tapClock.lastWait);
    unawaited(sfx.init()); // the web needs a gesture before audio starts
    final slot = clocks[clock.clamp(0, clocks.length - 1)];
    final wasWaiting = slot.round.phase == RoundPhase.waiting;
    // A graded tap also takes off the player's calibrated input lag
    // (T-13); the tap that starts a round does not.
    final graded = slot.round.phase == RoundPhase.running
        ? t - inputOffsetSeconds
        : t;
    _handle(slot, slot.round.tap(graded));
    // Starting from rest: the second clock follows half a round later.
    if (wasWaiting && clocks.length > 1 && slot.index == 0) {
      final b = clocks[1].round;
      if (b.phase == RoundPhase.waiting) {
        _startSecondAt =
            t + slot.round.timeMap.realAt(balance.round.target) / 2;
      }
    }
  }

  /// Maps touch timestamps onto [now] (T-10).
  final TapClock tapClock = TapClock();

  /// A calibration test finished (T-13): real phones' lag, by model
  /// (Firebase adds the device), to decide when the flag goes on.
  void calibrationDone({
    required int offsetMs,
    required double spreadMs,
    required int used,
    required bool applied,
  }) => _log('calibration', {
    'offset_ms': offsetMs,
    'spread_ms': spreadMs.round(),
    'used': used,
    'applied': applied ? 1 : 0,
  });

  /// The calibrated input lag (T-13), zero while the feature is off.
  double get inputOffsetSeconds =>
      Features.calibration ? settings.inputOffsetMs / 1000 : 0;

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
          : engine.frenzyLeft > 0 || engine.frenzyLastRound
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
        _challengeAdd(ChallengeKind.buyClocks, 1);
        sfx.play('buy', gain: 0.4);
        _announceBonuses(bonuses);
        _checkLoop();
      }
      autoWatch(_econAcc);
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
      _checkCuckoo();
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
        if (slot.index == 0) {
          syncSeason(); // a session can cross midnight
          syncChallenges();
        }
        final ticket = engine.onRoundStart(slot.index);
        slot
          ..mode = engine.modeMultiplier()
          ..blind = engine.blindActive
          ..hideAt = balance.blind.hideAt(_blindRng.nextDouble())
          ..lastTickTenth = -1;
        if (ticket.golden) sfx.play('coins');
        _roundStarts.add((slot.index, ticket.golden));
        notifyListeners();
      case RoundGraded(:final grade, :final gameTime):
        final o = engine.resolveRound(
          grade,
          mode: slot.mode,
          clock: slot.index,
        );
        // The Station clock's Express (docs/18).
        if (o.golden?.express ?? false) {
          _milestones.add(
            const MilestoneEvent.trait('stationClock', TraitNotice.express),
          );
        }
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
        if (grade.missKind != MissKind.noTap) {
          _challengeRound(o, grade.error);
          if (wound > 0) _challengeAdd(ChallengeKind.springWeek, wound);
        }
        // An empty reserve is said once, until a hit winds again. A full
        // stock takes nothing from it: not "empty" (R-SPR-4).
        var reserveEmpty = false;
        if (o.jackpot > 0 && econ.springsUnlocked) {
          if (wound > 0) {
            _reserveEmptyTold = false;
          } else if (!_reserveEmptyTold &&
              engine.springReserveAt(_wallMs()) < 60) {
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
            comboFull: state.comboStreak >= econ.comboCap(),
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
  /// Blind mode (docs/02 §7) hides the clock from [ClockSlot.hideAt]
  /// (a random moment, 3.60–4.20) of game time: digits, progress ring, the bullet-time heartbeat and
  /// vignette. Ticking is a bought help and keeps going (playtest 22).
  /// Blind is on but a running round started without it (switched on
  /// after 4.00): the mode row says it starts with the next round.
  bool get blindPending =>
      engine.blindActive &&
      clocks.any((c) => !c.blind && c.round.phase == RoundPhase.running);

  final _blindRng = math.Random();

  bool blindHidden(ClockSlot slot, double gameTime) {
    final at = slot.hideAt;
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
  /// The local hour (and half hour) the Cuckoo last called at.
  int _cuckooKey = 0;

  /// The Cuckoo's trait (docs/18): on the full hour, and on the half hour
  /// at tier 5, an extra Golden Second flies out while the game is played.
  void _checkCuckoo() {
    if (!state.tutorialDone || replaying) return;
    final now = _localNow();
    final half = now.minute == 30 && econ.cuckooOnHalfHour;
    if (!(now.minute == 0 && econ.cuckooOnHour) && !half) return;
    final key = dateKey(now) * 100 + now.hour * 2 + (half ? 1 : 0);
    if (key == _cuckooKey) return;
    _cuckooKey = key;
    if (!engine.cuckooGolden()) return;
    _log('cuckoo', {'half': half ? 1 : 0});
    _milestones.add(
      MilestoneEvent.trait(
        'cuckoo',
        TraitNotice.cuckoo,
        text: '${now.hour}:${half ? '30' : '00'}',
      ),
    );
  }

  void claimGolden() {
    if (!engine.claimGolden()) return;
    _log('golden_catch');
    _challengeAdd(ChallengeKind.goldenWeek, 1);
    tipActed('golden');
    sfx.play('coins');
    if (settings.haptics) unawaited(HapticFeedback.mediumImpact());
    _afterSeasonProgress();
    notifyListeners();
  }

  // ------------------------------------------- challenges (02 §18) --

  /// A challenge got done: the UI toasts it (with its reward to claim).
  final _challengeDone = StreamController<Challenge>.broadcast();
  Stream<Challenge> get challengeDone => _challengeDone.stream;

  final _challengeRng = math.Random();

  /// What the planner knows about this player now (docs/14 §1).
  ChallengePlayer challengePlayer() {
    final cfg = balance.challenges;
    // Sized for ordinary play: not the Blind mode the player may switch
    // off (only the loop's forced one), nor a Frenzy or Turbo that happens
    // to run right now.
    final mode = engine.blindForced ? engine.modeMultiplier() : 1.0;
    final boost = engine.frenzy * engine.turbo;
    return ChallengePlayer(
      recentErrors: List.of(state.stats.recentErrors),
      windows: econ.playerWindows(),
      jackpotWindow: balance.jackpot.window,
      roundSeconds:
          balance.round.target -
          econ.timeMap().start +
          balance.round.resultPause,
      payout: {
        for (final t in [Tier.perfect, Tier.great, Tier.good])
          t: engine.hitPayout(Grade(t, 0), mode: mode) / boost,
      },
      jackpotPayout: engine.jackpotAmount() * mode / boost,
      comboStep: balance.combo.multiplierPerStep,
      comboCap: econ.comboCap(),
      ownedClocks: state.owned.values.fold(0, (a, b) => a + b),
      bonusesInReach: [
        for (final g in balance.generators)
          if (econ.owned(g.id) > 0 &&
              (econ.nextMilestone(g.id) ?? 1 << 30) - econ.owned(g.id) <= 10)
            g,
      ].length,
      skillLevelsLeft: [
        for (final k in balance.skills)
          math.max(0, k.maxLevel - econ.level(k.id)),
      ].fold(0, (a, b) => a + b),
      springsUnlocked: econ.springsUnlocked,
      springsWindable:
          !engine.springsFull ||
          balance.generators.any(
            (g) =>
                econ.clockLevelable(g.id) &&
                econ.clockLevelCost(g.id)! <= state.springs,
          ),
      goldenEnabled: !engine.goldenBlocked,
      dailySeconds: cfg.dailySeconds,
      weeklySeconds: cfg.weeklySeconds,
      // The very first set is easier (R-WYZ-2).
      reachShare: state.challengeDay == 0
          ? cfg.firstReachShare
          : cfg.reachShare,
    );
  }

  /// What a rollover paid for challenges finished but not claimed (the UI
  /// says so once), or null.
  ChallengePay? challengeCarry;

  /// A new day or week: new challenges (R-WYZ-1). Called at start-up, on
  /// return and when a round starts — so the first ones may arrive in
  /// the middle of a session, like the ad offers, and a session can cross
  /// midnight.
  void syncChallenges() {
    // Not while the tutorial is replayed from the help (R-TUT-5a).
    if (replaying) return;
    final first = state.challengeDay == 0;
    final paid = engine.refreshChallenges(
      _localNow(),
      challengePlayer,
      _challengeRng,
    );
    if (paid.tiki + paid.bonus > 0 || paid.springs > 0) challengeCarry = paid;
    // When players meet them (05 T-34): play_min says how far in.
    if (first && state.challengeDay != 0) _log('challenges_unlocked');
  }

  void _challengeRound(RoundOutcome o, double error) {
    if (!engine.challengesUnlocked || state.challenges.isEmpty) return;
    _challengesDone(
      ChallengeProgress.round(
        state.challenges,
        ChallengeRound(
          tier: o.tier,
          error: error,
          jackpot: o.jackpot > 0,
          payout: o.payout,
        ),
      ),
    );
  }

  /// A new run pays far less per hit: today's hit-earnings target follows.
  void _replanChallenges() {
    if (!engine.challengesUnlocked || state.challenges.isEmpty) return;
    engine.replanAfterReset(challengePlayer(), _challengeRng);
  }

  void _challengeAdd(ChallengeKind kind, double amount) {
    if (!engine.challengesUnlocked || state.challenges.isEmpty) return;
    _challengesDone(ChallengeProgress.add(state.challenges, kind, amount));
  }

  void _challengesDone(List<Challenge> done) {
    for (final c in done) {
      _log('challenge_done', {
        'kind': c.kind.name,
        'weekly': c.weekly ? 1 : 0,
        'target': c.target.round(),
      });
      sfx.play('fanfare', gain: 0.7);
      unawaited(haptics.medium());
      _challengeDone.add(c);
    }
  }

  /// Challenges ready to claim (the header badge glows).
  int get challengesToClaim =>
      state.challenges.where((c) => c.done && !c.claimed).length;

  ChallengePay claimChallenge(Challenge c) {
    final pay = engine.claimChallenge(c);
    if (pay.tiki + pay.bonus > 0 || pay.springs > 0) {
      sfx.play('coins');
      unawaited(haptics.medium());
      unawaited(save());
      notifyListeners();
    }
    return pay;
  }

  /// Today's free re-roll of the daily challenge in [slot].
  bool rerollChallenge(int slot) {
    final fresh = engine.rerollChallenge(
      slot,
      challengePlayer(),
      _challengeRng,
    );
    if (fresh == null) return false;
    _log('challenge_reroll', {'kind': fresh.kind.name});
    sfx.play('tick');
    unawaited(save());
    notifyListeners();
    return true;
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

  /// The prologue (Grandpa late for tea) is due: once, right after a
  /// new player's first Tiki, when that round's result is over. Not
  /// before the first round: the first touch of the clock comes first
  /// (R-TUT-0), and the story reads better once a Tik is in the pocket.
  bool get prologuePending =>
      !state.tipsSeen.contains('prologue') &&
      !state.tutorialDone &&
      state.prestiges == 0 &&
      state.loopsDone == 0 &&
      state.earnedTotal > 0 &&
      clocks.every((c) => c.round.phase == RoundPhase.waiting);

  void prologueShown() => state.tipsSeen.add('prologue');

  /// The rare story scenes of the first loop (docs/16-fabula.md §4), in
  /// story order: the first Atomic Clock, the first paradox, the first
  /// Time Machine, Chronos' altar. One per break, each once, only in the
  /// first loop (a later loop has the chapters), never mid-round.
  static const storyScenes = ['atomic', 'paradox', 'timeMachine', 'altar'];

  String? get storyScenePending {
    if (!state.tutorialDone || state.loopsDone > 0 || replaying) return null;
    if (!clocks.every((c) => c.round.phase == RoundPhase.waiting)) return null;
    for (final id in storyScenes) {
      if (state.tipsSeen.contains('story_$id')) continue;
      final due = switch (id) {
        'atomic' => (state.owned['atomic'] ?? 0) > 0,
        'paradox' => state.prestiges > 0,
        'timeMachine' => (state.owned['timeMachine'] ?? 0) > 0,
        'altar' => state.perks.contains('unlockChronos'),
        _ => false,
      };
      if (due) return id;
    }
    return null;
  }

  void storySceneShown(String id) {
    state.tipsSeen.add('story_$id');
    unawaited(save());
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
    _log('season_complete', {'season': season?.key ?? ''});
    _reviewMoment();
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
    if (r == BuyResult.ok) {
      _challengeAdd(ChallengeKind.buyClocks, count.toDouble());
      _announceBonuses(bonuses);
    }
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
      _challengeAdd(ChallengeKind.skillLevels, 1);
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
    final tierBefore = econ.traitTier(id);
    final r = engine.levelClock(id);
    if (r == BuyResult.ok) {
      // A master title brings the clock's trait (docs/18).
      final tier = econ.traitTier(id);
      if (tier > tierBefore) {
        _milestones.add(
          MilestoneEvent.trait(id, TraitNotice.unlocked, index: tier),
        );
        _log('trait_unlock', {'id': id, 'tier': tier});
      }
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
    _reviewMoment(); // Chronos is bought: the best moment there is
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
    // A face for Chronos owned in this loop is kept before they reset.
    _announceDials();
    pause();
    _rebuildClocks();
    if (!engine.startLoop(_wallMs())) return false;
    // The perks are gone, and the second clock with them.
    _rebuildClocks();
    // The Time machine's Chronons to start with (docs/18).
    if (econ.loopStartChronons > 0) {
      _milestones.add(
        MilestoneEvent.trait(
          'timeMachine',
          TraitNotice.loopChronons,
          value: econ.loopStartChronons.toDouble(),
        ),
      );
    }
    _replanChallenges();
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
    _replanChallenges();
    _checkAchievements(const AchievementContext());
    // A fresh, faster run: from the second paradox on, a good moment.
    if (state.prestiges >= 2) _reviewMoment();
    unawaited(save());
    notifyListeners();
  }

  // -------------------------------------------------------------- review --

  /// Time to show Google Play's rating window (docs/02 R-OCENA-1): set at
  /// a high point, shown by the UI at the next quiet moment.
  bool reviewPending = false;

  /// Real-time days that must pass before a second rating window.
  static const reviewAgainAfterDays = 120;

  /// A high point (second paradox or later, a loop completed, a season
  /// finished, the 100th exact 5.00): asks for a rating only from a player
  /// who clearly likes the game — after at least 3 hours and on at least
  /// 3 different days — and at most twice, months apart.
  void _reviewMoment() {
    if (!state.tutorialDone || replaying) return;
    if (state.lifetime.secondsPlayed < 3 * 3600) return;
    if (state.lifetime.dailyClaims < 3) return;
    final asked = [
      for (final t in state.tipsSeen)
        if (t.startsWith('review:')) int.tryParse(t.substring(7)) ?? 0,
    ];
    if (asked.length >= 2) return;
    if (asked.isNotEmpty &&
        _wallMs() - asked.reduce(math.max) <
            reviewAgainAfterDays * 24 * 3600 * 1000) {
      return;
    }
    reviewPending = true;
  }

  /// The UI showed (or tried to show) the rating window.
  void reviewShown() {
    reviewPending = false;
    state.tipsSeen.add('review:${_wallMs()}');
    _log('review_prompt');
    unawaited(save());
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
  /// How the last ad ended: the message after it says why there is no
  /// reward (R-AD-8).
  AdResult? lastAdResult;

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
      final AdResult result;
      try {
        result = await provider.show();
      } finally {
        sfx.mute(false);
      }
      lastAdResult = result;
      _offersShown.remove(offer);
      _log(
        switch (result) {
          AdResult.earned => 'ad_reward',
          AdResult.closedEarly => 'ad_closed_early',
          AdResult.failed => 'ad_show_failed',
        },
        {'offer': offer.name},
      );
      if (result != AdResult.earned) return false;
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

  /// The one thing to aim for next, shown over the shop (R-TUT-7a): only
  /// the road to Chronos, never another perk or the moment of a paradox.
  /// Until the first paradox it starts with the first clock's first bonus.
  /// Then each new clock; with every clock within reach bought, the
  /// Shards for the perk that unlocks the next one ("unlock clock 13"; that
  /// a paradox pays them is the player's to find out); with Chronos bought,
  /// a new loop. Null when there is nothing to show.
  NextGoal? get nextGoal {
    if (!state.tutorialDone || replaying) return null;
    if (state.loopGoal) return const NextGoal(GoalKind.newLoop);
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
    final locked = lockedClock;
    if (locked == null) return null;
    final perk = balance.perk(locked.requiresPerk!);
    return NextGoal(
      GoalKind.unlockClock,
      generator: locked.id,
      perk: perk.id,
      // The Shards a paradox would add count too: the bar fills in play.
      have: state.shards + econ.prestigeGain().toDouble(),
      need: econ.perkCost(perk.id).toDouble(),
    );
  }

  /// The first clock still behind a perk, once every clock before it is
  /// bought: the shop shows it locked, with where its key is (R-PETLA-1).
  GeneratorConfig? get lockedClock {
    for (final g in balance.generators) {
      if (econ.generatorUnlocked(g.id)) {
        if (econ.owned(g.id) == 0) return null;
        continue;
      }
      return g.requiresPerk == null ? null : g;
    }
    return null;
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
      state.tutorialEndPlay = state.lifetime.secondsPlayed;
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
    if (state.challenges.isNotEmpty) _tip('challenges');
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
    if (state.lastSeenMs > 0 &&
        engine.onReturn((_wallMs() - state.lastSeenMs) / 1000)) {
      // "Na start!" (Sprint judge, docs/18).
      _milestones.add(
        MilestoneEvent.trait(
          'sprintJudge',
          TraitNotice.warmUp,
          index: state.warmUpHits,
          value: state.warmUpMultiplier,
        ),
      );
    }
    _checkLoop(); // also a save from before the loops
    pendingOffline = engine.offlineSince(_wallMs());
    // Saved until collected: closing the app over the summary loses nothing.
    engine.holdOffline(pendingOffline);
    if (pendingOffline != null) unawaited(save());
    pendingDaily = engine.dailyFor(_localNow());
    syncChallenges();
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
    _log('daily_collect', {'day': d.day, 'grace': d.grace ? 1 : 0});
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

  /// The newest save waiting for the write in progress, and that write.
  String? _pendingSave;
  Future<void>? _writing;

  /// Saves the state as it is now. Writes never overlap (T-18): leaving
  /// the app fires both "hidden" and "paused", and two writes into one
  /// temp file could leave a broken save. A save asked for during a write
  /// waits for it; several such saves become one, the newest.
  Future<void> save() {
    if (_retired) return Future.value();
    _sinceSave = 0;
    state.lastSeenMs = _wallMs();
    if (store == null) return Future.value();
    _pendingSave = saveToJsonString(
      SaveData(state, settings, balanceVersion: balance.version),
    );
    return _writing ??= _drainSaves();
  }

  Future<void> _drainSaves() async {
    try {
      while (_pendingSave != null) {
        final text = _pendingSave!;
        _pendingSave = null;
        try {
          await store!.write(text);
        } on Object catch (e) {
          debugPrint('save failed: $e');
        }
      }
    } finally {
      _writing = null;
    }
  }

  /// Stops this controller's saves for good and waits for the one in
  /// progress, so it cannot land on top of a save that replaces it.
  Future<void> _retire() async {
    _retired = true;
    _pendingSave = null;
    await _writing;
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
        engine.onRoundCancelled(c.index);
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

  /// Leaving the app: also schedules the reminders worth sending
  /// (R-OFF-4, R-POW-1…3) — at most two, never at night.
  void background({
    required ReminderTexts texts,
    String decimalSeparator = '.',
  }) {
    pause();
    unawaited(uploadCloud()); // T-35: the phone may not come back
    if (!settings.notifications) return;
    final reminders = plannedReminders(texts, decimalSeparator);
    if (reminders.isNotEmpty) unawaited(notifications.schedule(reminders));
  }

  /// The reminders [background] schedules now (tests see them here).
  List<Reminder> plannedReminders(
    ReminderTexts texts, [
    String decimalSeparator = '.',
  ]) {
    final now = _localNow();
    final nowMs = _wallMs();
    final candidates = <NotificationKind, DateTime>{};
    // The offline limit (R-OFF-4): only if the clocks earn anything.
    final rate = econ.passive() * engine.offlineEfficiency();
    final cap = engine.offlineCapSeconds();
    if (rate > 0) {
      candidates[NotificationKind.offlineFull] = now.add(
        Duration(seconds: cap.round()),
      );
    }
    // Tomorrow's daily bonus (R-POW-2): once a streak is worth keeping
    // and today's is collected.
    if (state.tutorialDone &&
        state.dailyStreak >= 2 &&
        state.dailyKey == dateKey(now)) {
      candidates[NotificationKind.dailyBonus] = NotificationPlan.dailyReminder(
        now,
      );
    }
    // The winding reserve (R-POW-1): after a paradox, when at least half
    // of it was used and refilling takes a while.
    if (econ.springsUnlocked &&
        engine.springReserveAt(nowMs) <= econ.hitReserve() / 2) {
      final fullIn = engine.springReserveFullIn(nowMs);
      if (fullIn.isFinite && fullIn >= 30 * 60) {
        candidates[NotificationKind.reserveFull] = now.add(
          Duration(seconds: fullIn.round()),
        );
      }
    }
    final days = balance.daily.minutes.length;
    final hit = balance.springs.hitSeconds;
    final hitText = hit >= 3600 && hit % 3600 == 0
        ? '${(hit / 3600).round()} h'
        : '${(hit / 60).round()} min';
    return [
      for (final p in NotificationPlan.choose(now, candidates))
        switch (p.kind) {
          NotificationKind.offlineFull => Reminder(
            p.kind,
            p.at,
            texts.offlineTitle(
              formatNumber(
                rate * cap,
                decimalSeparator: decimalSeparator,
                notation: settings.notation,
              ),
            ),
            texts.offlineBody,
          ),
          NotificationKind.dailyBonus => Reminder(
            p.kind,
            p.at,
            texts.dailyTitle(state.dailyStreak % days + 1, days),
            texts.dailyBody,
          ),
          NotificationKind.reserveFull => Reminder(
            p.kind,
            p.at,
            texts.reserveTitle,
            texts.reserveBody(hitText),
          ),
        },
    ];
  }

  void resume() {
    _lastTick = null;
    _offersShown.clear(); // a new visit: offers on screen count again
    tapClock.reset(); // the phone may have slept: the clocks may differ now
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
    _challengeDone.close();
    super.dispose();
  }
}

/// T-12: how far the moment we read the clock lags the platform's touch
/// timestamp. Only the spread matters (a constant offset is fine); a large
/// spread would mean grades depend on frame timing.
class InputDiagnostics {
  final List<double> _offsets = [];
  final List<double> _waits = [];

  /// [wait] is how much earlier than the handler the tap was counted
  /// ([TapClock.lastWait]).
  void recordInput(double clockSeconds, Duration eventTime, [double wait = 0]) {
    if (eventTime == Duration.zero) return;
    _offsets.add(clockSeconds - eventTime.inMicroseconds / 1e6);
    if (_offsets.length > 100) _offsets.removeAt(0);
    _waits.add(wait);
    if (_waits.length > 100) _waits.removeAt(0);
  }

  int get samples => _offsets.length;

  /// The largest correction among the last 100 taps, in ms: how late the
  /// handler would have counted a tap without the platform stamp.
  double get maxWaitMs =>
      _waits.isEmpty ? 0 : _waits.reduce((a, b) => a > b ? a : b) * 1000;

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
  CloudSave cloud = const NoCloudSave(),
  bool? consentRequired = false,
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
    cloud: cloud,
    consentRequired: consentRequired,
    sfx: sfx,
    haptics: haptics,
  );
  c.saveWasCorrupt = corrupt && data == null;
  c.checkOffline();
  return c;
}
