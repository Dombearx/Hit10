import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/persistence/save_store.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// A store whose writes take a while and that notices overlapping ones.
class SlowStore implements SaveStore {
  final written = <String>[];
  var active = 0;
  var overlapped = false;

  @override
  Future<String?> read() async => written.lastOrNull;

  @override
  Future<String?> readBackup() async => null;

  @override
  Future<void> write(String text) async {
    if (active > 0) overlapped = true;
    active++;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    written.add(text);
    active--;
  }

  @override
  Future<void> clear() async => written.clear();
}

/// T-18: saves never write at the same time.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();

  test('saves asked for at once write one after another', () async {
    final store = SlowStore();
    final c = GameController(balance: balance, store: store);
    final first = c.save();
    c.state.tiki = 1;
    unawaited(c.save());
    c.state.tiki = 2;
    final last = c.save(); // leaving the app: "hidden", then "paused"
    await Future.wait([first, last]);
    expect(store.overlapped, isFalse);
    // The two saves during the first write became one, the newest.
    expect(store.written, hasLength(2));
    expect(saveFromJsonString(store.written.last).state.tiki, 2);
  });

  test('an import waits for a save in progress, which cannot win', () async {
    final store = SlowStore();
    final c = GameController(balance: balance, store: store);
    c.state.tiki = 123;
    unawaited(c.save());
    final other = GameController(balance: balance)..state.tiki = 7;
    await c.importText(other.exportText());
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(store.overlapped, isFalse);
    expect(saveFromJsonString(store.written.last).state.tiki, 7);
  });
}
