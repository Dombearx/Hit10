import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

String saveWith(double tiki) =>
    saveToJsonString(SaveData(GameState()..tiki = tiki, Settings()));

void main() {
  final b = loadBalance();

  test('fresh install starts empty without a warning', () async {
    final c = await loadGame(b, MemorySaveStore());
    expect(c.state.tiki, 0);
    expect(c.saveWasCorrupt, isFalse);
  });

  test('loads the main save', () async {
    final store = MemorySaveStore()..main = saveWith(42);
    final c = await loadGame(b, store);
    expect(c.state.tiki, 42);
  });

  test('corrupt main save falls back to the backup (T-18)', () async {
    final store = MemorySaveStore()
      ..main = '{broken'
      ..backup = saveWith(7);
    final c = await loadGame(b, store);
    expect(c.state.tiki, 7);
    expect(c.saveWasCorrupt, isFalse);
  });

  test('both unreadable: fresh game and a warning (T-20)', () async {
    final store = MemorySaveStore()
      ..main = 'x'
      ..backup = 'y';
    final c = await loadGame(b, store);
    expect(c.state.tiki, 0);
    expect(c.saveWasCorrupt, isTrue);
  });

  test('save writes lastSeen and survives a reload', () async {
    final store = MemorySaveStore();
    final c = GameController(
      balance: b,
      store: store,
      wallClockMs: () => 123456,
    );
    c.state.owned['grandpa'] = 3;
    await c.save();
    final again = await loadGame(b, store);
    expect(again.state.owned['grandpa'], 3);
    expect(again.state.lastSeenMs, greaterThan(0));
  });

  test('closing the app over the offline summary keeps it (bug)', () async {
    final store = MemorySaveStore();
    var now = 1800000000000;
    GameController open(GameState s) => GameController(
      balance: b,
      state: s,
      store: store,
      wallClockMs: () => now,
    )..checkOffline();
    final first = open(
      GameState()
        ..tutorialDone = true
        ..owned['grandma'] = 1
        ..lastSeenMs = now - 3600 * 1000,
    );
    final shown = first.pendingOffline!.amount;
    first.background(title: (a) => a); // closed without collecting
    await first.save();
    now += 5000; // reopened a few seconds later
    final again = open(saveFromJsonString(store.main!).state);
    expect(again.pendingOffline!.amount, closeTo(shown, 1e-6));
    again.collectOffline();
    expect(again.state.tiki, closeTo(shown, 1e-6));
  });
}
