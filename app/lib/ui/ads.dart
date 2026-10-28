/// Picks the rewarded-ads provider for this platform (docs/05 T-25, T-26):
/// AdMob on devices, the stand-in everywhere else (web QA builds).
library;

export 'ads_stub.dart' if (dart.library.io) 'ads_device.dart';
