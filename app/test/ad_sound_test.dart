import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/ui/audio.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

class _RecordingSfx extends Sfx {
  final mutes = <bool>[];

  @override
  void mute(bool on) => mutes.add(on);
}

/// The ad has its own sound: the game stays quiet while it plays.
void main() {
  test('music and effects are muted for the ad, back after it', () async {
    final sfx = _RecordingSfx();
    final c = GameController(
      balance: loadBalance(),
      state: GameState()
        ..tutorialDone = true
        ..playSeconds = 1000,
      sfx: sfx,
    );
    final ads = FakeRewardedAds(delay: const Duration(milliseconds: 10));
    final watching = c.watchAd(AdOffer.turbo, ads);
    expect(sfx.mutes, [true]); // while the ad plays
    expect(await watching, isTrue);
    expect(sfx.mutes, [true, false]);

    // An interrupted ad unmutes too.
    ads.grant = false;
    c.state.adCooldownUntil.clear();
    expect(await c.watchAd(AdOffer.golden, ads), isFalse);
    expect(sfx.mutes, [true, false, true, false]);
  });
}
