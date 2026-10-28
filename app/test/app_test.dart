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
  testWidgets('start screen in Polish', (tester) async {
    await tester.pumpWidget(app(const Locale('pl')));
    await tester.pumpAndSettle();
    expect(find.text('Hit10'), findsOneWidget);
    expect(find.text('Dotknij dokładnie w 10.00'), findsOneWidget);
  });

  testWidgets('start screen in English', (tester) async {
    await tester.pumpWidget(app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Tap at exactly 10.00'), findsOneWidget);
  });
}
