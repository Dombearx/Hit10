import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/balance/balance.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

Widget app(Locale locale) {
  final balance = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  return ProviderScope(
    overrides: [
      balanceProvider.overrideWithValue(balance),
      gameControllerProvider.overrideWithValue(
        GameController(balance: balance),
      ),
    ],
    child: Hit5App(locale: locale),
  );
}

void main() {
  // The arena runs a game loop, so pump fixed durations instead of settling.
  testWidgets('game screen in Polish', (tester) async {
    await tester.pumpWidget(app(const Locale('pl')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tiki'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.byKey(const Key('arena')), findsOneWidget);
  });

  testWidgets('game screen in English', (tester) async {
    await tester.pumpWidget(app(const Locale('en')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ticks'), findsOneWidget);
  });

  test('tablets scale the phone layout up, phones stay as they are', () {
    expect(TabletScale.scaleFor(const Size(390, 844)), 1.0); // phone
    expect(TabletScale.scaleFor(const Size(412, 915)), 1.0); // large phone
    // 7-inch and 10-inch tablets in portrait: the same ~476×760 layout.
    expect(TabletScale.scaleFor(const Size(600, 960)), closeTo(1.26, 0.01));
    expect(TabletScale.scaleFor(const Size(800, 1280)), closeTo(1.68, 0.01));
    expect(TabletScale.scaleFor(const Size(2000, 3000)), 2.0); // capped
  });

  testWidgets('on a tablet the game fills the screen at a larger scale', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    Future<double> tabHeight(Size physical) async {
      tester.view.physicalSize = physical;
      tester.view.devicePixelRatio = 2;
      await tester.pumpWidget(app(const Locale('pl')));
      await tester.pump(const Duration(milliseconds: 100));
      return tester.getRect(find.text('Zegary')).height;
    }

    final phone = await tabHeight(const Size(780, 1688)); // 390×844
    final tablet = await tabHeight(const Size(1600, 2560)); // 10-inch
    // Drawn ~1.7× bigger (the phone row also shrinks its text a little).
    expect(tablet / phone, greaterThan(1.5));
  });

  testWidgets('screen readers get names for the header icons and the dial', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(app(const Locale('pl')));
    await tester.pump(const Duration(milliseconds: 100));
    for (final label in [
      'Osiągnięcia',
      'Statystyki',
      'Jak grać',
      'Ustawienia',
      'Paradoks czasowy',
      'Stoper. Zatrzymaj go dokładnie na 5.00.',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    semantics.dispose();
  });
}
