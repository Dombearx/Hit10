import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../arena/arena_game.dart';
import '../l10n/gen/app_localizations.dart';
import 'diagnostics_panel.dart';
import 'game_controller.dart';
import 'providers.dart';
import 'qa_hook.dart';
import 'theme.dart';
import 'widgets/animated_counter.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final GameController controller = GameController(
    balance: ref.read(balanceProvider),
  );
  late final ArenaGame arena = ArenaGame(controller, _labels());
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onHide: controller.pause,
    onPause: controller.pause,
  );

  bool _diagnostics = false;
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
      tapToStart: l.tapToStart,
      decimalSeparator: l.decimalSeparator,
    );
  }

  @override
  void initState() {
    super.initState();
    if (qaEnabled) registerQaHook(controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lifecycle; // start listening
    arena.labels = _labels();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    controller.dispose();
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onSecretTap,
                    child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => Column(
                        children: [
                          AnimatedCounter(
                            value: controller.state.tiki,
                            decimalSeparator: l.decimalSeparator,
                          ),
                          Text(
                            l.tikiLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Listener(
                      key: const Key('arena'),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) =>
                          controller.onPointerDown(e.timeStamp),
                      child: GameWidget(game: arena),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
    );
  }
}
