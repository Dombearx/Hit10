import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/cloud_save.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// docs/05 T-35: Play Games Saved Games, never loaded without asking.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();
  var now = 1800000000000;

  String saveWith(double seconds, {double tiki = 0}) => exportSave(
    SaveData(
      GameState()
        ..lifetime.secondsPlayed = seconds
        ..tiki = tiki,
      Settings(),
    ),
  );

  GameController controller(GameState s, CloudSave cloud, MemorySaveStore st) =>
      GameController(
        balance: balance,
        state: s,
        store: st,
        cloud: cloud,
        wallClockMs: () => now,
      );

  test('only a save clearly ahead is offered, and not twice', () {
    expect(CloudSync.offer(null, 0), isNull);
    expect(CloudSync.offer('not a save', 0), isNull);
    expect(CloudSync.offer(saveWith(100), 0), isNull); // within 2 min
    final o = CloudSync.offer(saveWith(7200), 3600)!;
    expect(o.playSeconds, 7200);
    expect(CloudSync.offer(saveWith(7200), 3600, declined: {7200}), isNull);
  });

  test('a new phone finds the old progress and loads it on a yes', () async {
    final cloud = MemoryCloudSave(data: saveWith(36000, tiki: 1e9));
    final store = MemorySaveStore();
    final c = controller(GameState(), cloud, store);
    await c.checkCloud();
    expect(c.cloudSignedIn, isTrue);
    final offer = c.cloudOffer!;
    // Nothing is uploaded over it while the question is open.
    await c.uploadCloud(force: true);
    expect(cloud.saves, 0);
    expect(await c.answerCloudOffer(offer, load: true), isTrue);
    expect(saveFromJsonString(store.main!).state.tiki, 1e9);
  });

  test('a no keeps this phone and is remembered', () async {
    final cloud = MemoryCloudSave(data: saveWith(36000));
    final c = controller(GameState(), cloud, MemorySaveStore());
    await c.checkCloud();
    expect(await c.answerCloudOffer(c.cloudOffer!, load: false), isFalse);
    await c.checkCloud();
    expect(c.cloudOffer, isNull);
    // From the settings it can still be loaded on purpose.
    expect(await c.checkCloud(manual: true), isNotNull);
    // This phone's progress goes up when the player leaves.
    await c.uploadCloud();
    expect(cloud.saves, 1);
    expect(importSave(cloud.data!).state.lifetime.secondsPlayed, 0);
  });

  test('uploads at most once a minute, only when signed in', () async {
    final cloud = MemoryCloudSave(signed: false);
    final c = controller(
      GameState()..lifetime.secondsPlayed = 50,
      cloud,
      MemorySaveStore(),
    );
    await c.checkCloud();
    await c.uploadCloud();
    expect(cloud.saves, 0);
    await c.signInCloud(); // the settings' "Connect" uploads at once
    expect(cloud.saves, 1);
    await c.uploadCloud();
    expect(cloud.saves, 1);
    now += 61 * 1000;
    await c.uploadCloud();
    expect(cloud.saves, 2);
  });
}
