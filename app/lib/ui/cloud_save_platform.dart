/// Picks the cloud save for this platform (docs/05 T-35): Play Games on
/// Android builds that carry a Play Games project, nothing elsewhere.
library;

export 'cloud_save_stub.dart' if (dart.library.io) 'cloud_save_device.dart';
