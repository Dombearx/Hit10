import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// R-AD-9: watching an ad (or reading its offer) costs no effect time.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();

  GameController played() => GameController(
    balance: balance,
    state: GameState()
      ..tutorialDone = true
      ..playSeconds = 1000
      ..owned['grandma'] = 10
      ..turboLeft = 600,
    store: MemorySaveStore(),
  );

  Future<void> frames(GameController c, int n) async {
    for (var i = 0; i < n; i++) {
      c.tick();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  test('Frenzy, Hot hand and Turbo wait while an ad plays', () async {
    final c = played();
    c.engine
      ..frenzyLeft = 77
      ..hotHandLeft = 60;
    await frames(c, 2); // the clock is running
    final frenzy = c.engine.frenzyLeft;
    final hot = c.engine.hotHandLeft;
    final turbo = c.state.turboLeft;
    final played0 = c.state.playSeconds;
    final ad = c.watchAd(
      AdOffer.bag,
      FakeRewardedAds(delay: const Duration(milliseconds: 400)),
    );
    await frames(c, 20); // frames keep coming under the ad (Android)
    expect(await ad, isTrue);
    expect(c.engine.frenzyLeft, frenzy);
    expect(c.engine.hotHandLeft, hot);
    expect(c.state.turboLeft, turbo);
    expect(c.state.playSeconds, played0);
    // After the ad, time runs again.
    await frames(c, 5);
    expect(c.engine.frenzyLeft, lessThan(frenzy));
  });

  test('reading an offer does not use up Frenzy', () async {
    final c = played();
    c.engine.frenzyLeft = 77;
    await frames(c, 2);
    final frenzy = c.engine.frenzyLeft;
    c.offerOpen = true;
    await frames(c, 10);
    expect(c.engine.frenzyLeft, frenzy);
    c.offerOpen = false;
    await frames(c, 5);
    expect(c.engine.frenzyLeft, lessThan(frenzy));
  });
}
