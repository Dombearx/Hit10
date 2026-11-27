import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// The mode row with everything unlocked at once (Blind, the second clock,
/// the auto buyer in its longest state, a loop with two rules) on narrow
/// phones, large text and both languages: every chip is wholly on screen,
/// none hidden behind a scroll or cut at the edge, and nothing overflows.
/// It used to be a sideways scroll that cut the auto buyer off.
void main() {
  final balance = loadBalance();

  const chips = ['mode-blind', 'mode-second', 'mode-auto', 'loop-chip'];

  GameState everything({required bool autoOn, required bool forcedBlind}) {
    return GameState()
      ..tutorialDone = true
      ..dailyKey = dateKey(DateTime.now())
      ..tipsSeen.addAll([
        'prologue',
        'modes',
        'notifyAsked',
        ...storyScenesSeen,
      ])
      ..lifetime.perfects =
          1000 // Blind unlocked
      ..modeBlind = true
      ..perks.addAll(['secondClock', 'autoBuyer'])
      ..secondClockOn = true
      // On with no clock picked: "Auto buyer: pick a clock", its longest.
      ..autoBuyerOn = autoOn
      ..loop = 12
      ..loopRules.addAll(
        forcedBlind ? ['blindfold', 'precision'] : ['precision', 'shortFuse'],
      )
      ..tiki = 1.34e7
      ..owned['grandpa'] = 10
      ..owned['grandma'] = 1;
  }

  for (final width in [320.0, 360.0, 412.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      for (final lang in ['pl', 'en']) {
        for (final autoOn in [true, false]) {
          for (final forcedBlind in [false, true]) {
            final name =
                '${width.round()} dp, text ×$scale, $lang, '
                'auto ${autoOn ? 'picking' : 'off'}'
                '${forcedBlind ? ', forced Blind' : ''}';
            testWidgets('mode row fits: $name', (tester) async {
              final c = GameController(
                balance: balance,
                state: everything(autoOn: autoOn, forcedBlind: forcedBlind),
                store: MemorySaveStore(),
              )..checkOffline();
              tester.view.physicalSize = Size(width * 3, 740 * 3);
              tester.view.devicePixelRatio = 3;
              tester.platformDispatcher.textScaleFactorTestValue = scale;
              addTearDown(tester.view.reset);
              addTearDown(
                tester.platformDispatcher.clearTextScaleFactorTestValue,
              );
              await tester.pumpWidget(
                ProviderScope(
                  overrides: [
                    balanceProvider.overrideWithValue(balance),
                    gameControllerProvider.overrideWithValue(c),
                  ],
                  child: Hit5App(locale: Locale(lang)),
                ),
              );
              await tester.pump(const Duration(milliseconds: 500));

              for (final key in chips) {
                // The auto buyer's key says whether it waits for a pick.
                final f = key == 'mode-auto'
                    ? find.byWidgetPredicate(
                        (w) =>
                            w is GestureDetector &&
                            (w.key == const Key('mode-auto') ||
                                w.key == const Key('mode-auto-waiting')),
                      )
                    : find.byKey(Key(key));
                expect(f, findsOneWidget, reason: key);
                final r = tester.getRect(f);
                expect(r.left, greaterThanOrEqualTo(0), reason: '$key $r');
                expect(r.right, lessThanOrEqualTo(width), reason: '$key $r');
                expect(r.bottom, lessThanOrEqualTo(740), reason: '$key $r');
                expect(r.height, greaterThanOrEqualTo(36), reason: '$key $r');
                // Tappable where it is drawn: not under another widget.
                expect(f.hitTestable(), findsOneWidget, reason: key);
              }

              // Nothing on the game screen hides behind a sideways scroll.
              for (final s in tester.stateList<ScrollableState>(
                find.byType(Scrollable),
              )) {
                if (s.position.axis != Axis.horizontal) continue;
                expect(
                  s.position.maxScrollExtent,
                  0,
                  reason: 'content scrolled out of sight: ${s.widget}',
                );
              }
            });
          }
        }
      }
    }
  }
}
