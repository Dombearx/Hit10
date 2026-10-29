import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../arena/arena_game.dart';
import '../l10n/gen/app_localizations.dart';
import '../model/grading.dart';
import 'diagnostics_panel.dart';
import 'format.dart';
import 'game_controller.dart';
import 'daily_dialog.dart';
import 'offline_dialog.dart';
import 'season_dialog.dart';
import 'seasons_ui.dart';
import 'providers.dart';
import 'qa_hook.dart';
import 'shop/generator_list.dart';
import 'shop/skill_list.dart';
import 'shop/upgrade_strip.dart';
import 'catalog.dart';
import 'screens/achievements_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prestige_screen.dart';
import 'screens/stats_screen.dart';
import 'theme.dart';
import 'throttled.dart';
import 'widgets/animated_counter.dart';
import 'widgets/combo_meter.dart';
import 'widgets/ad_buttons.dart';
import 'widgets/effect_chips.dart';
import 'widgets/mode_row.dart';
import 'widgets/toasts.dart';
import 'widgets/tutorial.dart';
import 'widgets/frenzy_background.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final GameController controller = ref.read(gameControllerProvider);
  late final ArenaGame arena = ArenaGame(controller, _labels());
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onHide: _onHide,
    onPause: _onHide,
    onShow: _onShow,
  );

  void _onHide() {
    controller.sfx.mute(true); // U-21
    controller.background(
      title: AppLocalizations.of(context).notificationTitle,
    );
  }

  /// The shop and the upgrade strip repaint at 4 Hz, not at every tick.
  late final ThrottledListenable _slow = ThrottledListenable(
    controller,
    const Duration(milliseconds: 250),
  );

  bool _diagnostics = false;
  bool _shopCollapsed = false;
  bool _offlineOpen = false;
  int _tab = 0;
  BuyAmount _amount = BuyAmount.one;
  int _secretTaps = 0;
  DateTime _lastSecretTap = DateTime(0);

  ArenaLabels _labels() {
    final l = AppLocalizations.of(context);
    return ArenaLabels(
      perfect: l.tierPerfect,
      great: l.tierGreat,
      good: l.tierGood,
      early: l.missEarly,
      late: l.missLate,
      close: l.missClose,
      tapToStart: l.tapToStart,
      decimalSeparator: l.decimalSeparator,
      goldenRound: l.goldenRound,
      goldenEscaped: l.goldenEscaped,
      frenzy: l.goldenFrenzy,
      lucky: l.goldenLucky,
      hotHand: l.goldenHotHand,
      luckyBump: l.luckyBump,
      shieldSaved: l.shieldSaved,
    );
  }

  @override
  void initState() {
    super.initState();
    if (qaEnabled) registerQaHook(controller);
    controller.addListener(_maybeShowOffline);
    _seasonSub = controller.seasonCompleted.listen(_onSeasonCompleted);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOffline();
      if (controller.saveWasCorrupt && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).saveCorrupt)),
        );
      }
    });
  }

  void _onShow() {
    controller.sfx.mute(false);
    controller.resume();
    _maybeShowOffline();
  }

  /// The "while you were away" dialog, then the daily bonus, then a new
  /// season's intro.
  Future<void> _maybeShowOffline() async {
    if (_offlineOpen || !mounted) return;
    final c = controller;
    if (c.pendingOffline == null &&
        c.pendingDaily == null &&
        !c.seasonIntroPending) {
      return;
    }
    _offlineOpen = true;
    c.pause();
    try {
      if (c.pendingOffline != null) {
        await showOfflineDialog(context, c, ref.read(rewardedAdsProvider));
      }
      if (mounted && c.pendingDaily != null) {
        await showDailyDialog(context, c);
      }
      if (mounted && c.seasonIntroPending) {
        c.seasonIntroShown();
        await showSeasonDialog(context, c);
      }
    } finally {
      _offlineOpen = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lifecycle; // start listening
    arena.labels = _labels();
  }

  StreamSubscription<double>? _seasonSub;

  void _onSeasonCompleted(double amount) {
    final s = controller.season;
    if (!mounted || s == null) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l.seasonCompleted(
            seasonName(l, s.id),
            Fmt.of(context, controller).n(amount),
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_seasonSub?.cancel());
    controller.removeListener(_maybeShowOffline);
    _slow.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  /// Seven quick taps on the balance toggle the diagnostics overlay (T-12).
  void _onSecretTap() {
    final now = DateTime.now();
    _secretTaps = now.difference(_lastSecretTap).inMilliseconds < 600
        ? _secretTaps + 1
        : 1;
    _lastSecretTap = now;
    if (_secretTaps >= 7) {
      _secretTaps = 0;
      setState(() => _diagnostics = !_diagnostics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FrenzyBackground(
        controller: controller,
        child: SafeArea(
          // Tablets (M-9): the game keeps a phone's proportions, centred;
          // the background still fills the screen.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 6),
                      _Header(
                        controller: controller,
                        onSecretTap: _onSecretTap,
                        onAchievements: () =>
                            showAchievements(context, controller),
                        onStats: () => showStats(context, controller),
                        onPrestige: () => showPrestige(context, controller),
                        onSettings: () => showSettings(context, controller),
                      ),
                      Expanded(
                        flex: _shopCollapsed ? 8 : 5,
                        child: Listener(
                          key: const Key('arena'),
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (e) {
                            final p = e.localPosition;
                            // A tap on the flying golden clock is not a round
                            // tap (R-ZLOTA-1).
                            if (arena.isLoaded &&
                                arena.tapGolden(Vector2(p.dx, p.dy))) {
                              return;
                            }
                            // With two clocks each half of the arena is one clock
                            // (R-DRUGI-1).
                            final clock =
                                controller.clocks.length > 1 &&
                                    p.dx > arena.size.x / 2
                                ? 1
                                : 0;
                            controller.onPointerDown(e.timeStamp, clock: clock);
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: RepaintBoundary(
                                  child: GameWidget(game: arena),
                                ),
                              ),
                              // Offer tiles float over the arena's top corners but
                              // swallow their own taps (U-22).
                              Positioned(
                                left: 8,
                                right: 8,
                                top: 4,
                                child: ListenableBuilder(
                                  listenable: _slow,
                                  builder: (context, _) =>
                                      AdCornerButtons(controller: controller),
                                ),
                              ),
                              // A 5-second offer: floats over the arena's foot so
                              // the shop below doesn't jump.
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Center(
                                  child: ListenableBuilder(
                                    listenable: controller,
                                    builder: (context, _) =>
                                        RescuePopup(controller: controller),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) =>
                            TutorialBubble(controller: controller),
                      ),
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) =>
                            ComboMeter(controller: controller),
                      ),
                      ListenableBuilder(
                        listenable: _slow,
                        builder: (context, _) =>
                            ModeRow(controller: controller),
                      ),
                      RepaintBoundary(
                        child: ListenableBuilder(
                          listenable: _slow,
                          builder: (context, _) =>
                              UpgradeStrip(controller: controller),
                        ),
                      ),
                      _ShopHeader(
                        tab: _tab,
                        amount: _amount,
                        collapsed: _shopCollapsed,
                        onTab: (t) => setState(() {
                          _tab = t;
                          _shopCollapsed = false;
                        }),
                        onAmount: (a) => setState(() => _amount = a),
                        onToggle: () =>
                            setState(() => _shopCollapsed = !_shopCollapsed),
                      ),
                      if (!_shopCollapsed)
                        Expanded(
                          flex: 5,
                          child: RepaintBoundary(
                            child: ListenableBuilder(
                              listenable: _slow,
                              builder: (context, _) => _tab == 0
                                  ? GeneratorList(
                                      controller: controller,
                                      amount: _amount,
                                    )
                                  : SkillList(controller: controller),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 8,
                    child: AchievementToasts(controller: controller),
                  ),
                  if (_diagnostics)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: DiagnosticsPanel(controller: controller),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.onSecretTap,
    required this.onAchievements,
    required this.onStats,
    required this.onPrestige,
    required this.onSettings,
  });
  final GameController controller;
  final VoidCallback onSecretTap;
  final VoidCallback onAchievements;
  final VoidCallback onStats;
  final VoidCallback onPrestige;
  final VoidCallback onSettings;

  Widget _icon(
    String emoji,
    Key key,
    VoidCallback onTap, {
    bool glow = false,
  }) => GestureDetector(
    key: key,
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: glow ? Palette.perfect : Colors.white.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: Palette.outline, width: 2),
      ),
      child: Image.asset(EmojiArt.path(emoji)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSecretTap,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final f = Fmt.of(context, controller);
          final ps = controller.engine.passive();
          return Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  _icon(
                    'trophy',
                    const Key('open-achievements'),
                    onAchievements,
                  ),
                  const SizedBox(width: 6),
                  _icon('bar_chart', const Key('open-stats'), onStats),
                  Expanded(
                    child: Center(
                      child: SeasonBadge(
                        controller: controller,
                        onTap: () => showSeasonDialog(context, controller),
                      ),
                    ),
                  ),
                  _icon('gear', const Key('open-settings'), onSettings),
                  const SizedBox(width: 6),
                  _icon(
                    'cyclone',
                    const Key('open-prestige'),
                    onPrestige,
                    glow: controller.engine.canPrestige(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedCounter(
                    key: const Key('balance'),
                    value: controller.state.tiki,
                    decimalSeparator: l.decimalSeparator,
                    notation: controller.settings.notation,
                    whole: true,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l.tikiLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              EffectChips(controller: controller),
              AnimatedOpacity(
                opacity: ps > 0 ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  f.perSecond(ps),
                  style: TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 16,
                    color: Palette.outline.withValues(alpha: 0.7),
                  ),
                ),
              ),
              // What the next hit pays, per tier (playtest: is tapping
              // worth it at high income?).
              if (controller.state.tutorialDone)
                _PerfectPrice(controller: controller, f: f),
            ],
          );
        },
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({
    required this.tab,
    required this.amount,
    required this.collapsed,
    required this.onTab,
    required this.onAmount,
    required this.onToggle,
  });

  final int tab;
  final BuyAmount amount;
  final bool collapsed;
  final ValueChanged<int> onTab;
  final ValueChanged<BuyAmount> onAmount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget tabButton(int i, String text) => GestureDetector(
      key: Key('tab-$i'),
      onTap: () => onTab(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: tab == i
              ? Palette.outline
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Palette.outline, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: Fonts.display,
            fontSize: 15,
            color: tab == i ? Colors.white : Palette.outline,
          ),
        ),
      ),
    );
    Widget amountButton(BuyAmount a, String text) => GestureDetector(
      key: Key('amount-${a.name}'),
      onTap: () => onAmount(a),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: amount == a ? Palette.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: Fonts.display,
            fontSize: 13,
            color: amount == a ? Colors.white : Palette.outline,
          ),
        ),
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if ((v > 200 && !collapsed) || (v < -200 && collapsed)) onToggle();
      },
      child: Column(
        children: [
          // Drag or tap the handle to fold the shop away (U-2).
          GestureDetector(
            key: const Key('shop-toggle'),
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              width: 120,
              height: 18,
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Palette.outline.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 8, 6),
            child: Row(
              children: [
                // Scale down rather than overflow on narrow screens or with
                // large system text.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        tabButton(0, l.tabClocks),
                        const SizedBox(width: 6),
                        tabButton(1, l.tabSkills),
                      ],
                    ),
                  ),
                ),
                if (tab == 0 && !collapsed) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          amountButton(BuyAmount.one, '×1'),
                          amountButton(BuyAmount.ten, '×10'),
                          amountButton(BuyAmount.hundred, '×100'),
                          amountButton(BuyAmount.max, l.buyAmountMax),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "10.00 = +5,4K": what the next 10.00 pays (PERFECT and the jackpot),
/// with the current combo and mode (docs/04 U-3a).
class _PerfectPrice extends StatelessWidget {
  const _PerfectPrice({required this.controller, required this.f});
  final GameController controller;
  final Fmt f;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pay = controller.engine.nextHitPayout(Tier.perfect);
    return Text(
      l.jackpotPrice(f.n(pay)),
      key: const Key('perfect-price'),
      style: TextStyle(
        fontFamily: Fonts.display,
        fontSize: 13,
        color: Palette.perfectDeep.withValues(alpha: 0.85),
      ),
    );
  }
}
