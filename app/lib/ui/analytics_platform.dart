/// Picks the statistics backend for this platform (docs/05 T-30):
/// Firebase Analytics on Android builds that carry a Firebase project,
/// nothing everywhere else.
library;

export 'analytics_stub.dart' if (dart.library.io) 'analytics_device.dart';
