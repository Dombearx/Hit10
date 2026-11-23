/// Google Play in-app updates: the game itself offers a new version from
/// the store, so testers and players need not wait for the Play Store's
/// own auto-update (playtest: "testers have to update by hand").
///
/// The flexible flow Google recommends: the download runs in the
/// background, [appUpdateReady] turns true when it is done, the game
/// offers a restart, and if the player ignores it the update installs
/// when they leave the game (installed silently while it is hidden).
library;

export 'app_update_state.dart';
export 'app_updates_stub.dart' if (dart.library.io) 'app_updates_device.dart';
