import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/analytics/analytics.dart';
import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// Game statistics (docs/05 T-30, §8a).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();
  const now = 1800000000000;

  GameController controller(
    GameState s,
    RecordingAnalytics a, {
    Settings? st,
  }) => GameController(
    balance: balance,
    state: s,
    settings: st,
    store: MemorySaveStore(),
    analytics: a,
    wallClockMs: () => now,
  );

  test('the tutorial funnel: each step once, then how it ended', () {
    final a = RecordingAnalytics();
    final s = GameState();
    final c = controller(s, a);
    expect(a.last('tutorial_step'), containsPair('step', 'aim'));
    s.tiki = balance.generators.first.baseCost;
    c.buyGenerators('grandpa', 1);
    expect(a.names, contains('generator_first'));
    expect(a.last('tutorial_step'), containsPair('step', 'grandpaInfo'));
    c.nextTutorialStep();
    final done = a.last('tutorial_complete')!;
    expect(done['at_step'], 'grandpaInfo');
    expect(done['run'], 0);
    expect(done.containsKey('play_min'), isTrue);
    expect(a.userProperties['tutorial_done'], 'true');
    expect(a.userProperties['top_clock'], 'grandpa');
    // Finishing again (replay closed) is not a second completion.
    final count = a.names.where((n) => n == 'tutorial_complete').length;
    c.finishTutorial();
    expect(a.names.where((n) => n == 'tutorial_complete').length, count);
  });

  test('a skipped tutorial says where it was skipped', () {
    final a = RecordingAnalytics();
    final c = controller(GameState(), a);
    c.finishTutorial();
    expect(a.last('tutorial_complete'), containsPair('at_step', 'aim'));
  });

  test('rewarded ads: the answer, the reward, and no ad to show', () async {
    final a = RecordingAnalytics();
    final s = GameState()
      ..tutorialDone = true
      ..playSeconds = 1000
      ..owned['grandma'] = 10;
    final c = controller(s, a);
    c.adOfferAnswered(AdOffer.turbo, watch: true);
    expect(a.last('ad_offer'), containsPair('watch', 1));
    final ads = FakeRewardedAds(delay: Duration.zero);
    expect(await c.watchAd(AdOffer.turbo, ads), isTrue);
    expect(a.last('ad_reward'), containsPair('offer', 'turbo'));
    final none = FakeRewardedAds(ready: false, delay: Duration.zero);
    expect(await c.watchAd(AdOffer.bag, none), isFalse);
    expect(a.last('ad_unavailable'), containsPair('offer', 'bag'));
  });

  test('the player can turn statistics off, and the choice is saved', () {
    final a = RecordingAnalytics();
    final c = controller(GameState()..tutorialDone = true, a);
    c.settings.analytics = false;
    c.applySettings();
    expect(a.enabled, isFalse);
    final back = importSave(
      exportSave(SaveData(c.state, c.settings, balanceVersion: 1)),
    );
    expect(back.settings.analytics, isFalse);
    // Old saves have no such field: statistics stay on.
    expect(Settings().analytics, isTrue);
  });

  test('every event fits Firebase limits', () {
    final a = RecordingAnalytics();
    final s = GameState()..tiki = 1e9;
    final c = controller(s, a);
    c.buyGenerators('grandpa', 1);
    c.buySkill(balance.skills.first.id);
    c.finishTutorial();
    c.setMode(blind: true);
    c.replayTutorial();
    final name = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,39}$');
    expect(a.events, isNotEmpty);
    for (final (n, p) in a.events) {
      expect(n, matches(name));
      expect(p.length, lessThanOrEqualTo(25));
      for (final MapEntry(:key, :value) in p.entries) {
        expect(key, matches(name));
        expect(value, anyOf(isA<num>(), isA<String>()));
        if (value is String) expect(value.length, lessThanOrEqualTo(100));
      }
    }
  });
}
