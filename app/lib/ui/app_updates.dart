/// Google Play in-app updates: the game itself offers a new version from
/// the store, so testers and players need not wait for the Play Store's
/// own auto-update (playtest: "testers have to update by hand").
library;

export 'app_updates_stub.dart' if (dart.library.io) 'app_updates_device.dart';
