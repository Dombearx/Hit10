/// Google Play's rating window (docs/02 R-OCENA-1): the in-app review API
/// on Android, nothing on the web.
library;

export 'review_stub.dart' if (dart.library.io) 'review_device.dart';
