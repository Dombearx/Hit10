import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/balance/balance.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/providers.dart';

Widget app(Locale locale) => ProviderScope(
  overrides: [
    balanceProvider.overrideWithValue(
      Balance.fromJsonString(File('assets/balance.json').readAsStringSync()),
    ),
  ],
  child: Hit10App(locale: locale),
);

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
}
