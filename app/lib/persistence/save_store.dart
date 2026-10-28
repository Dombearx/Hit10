/// Where the save lives: a file on devices (atomic write + backup, T-18),
/// localStorage on the web (QA builds).
library;

export 'save_store_io.dart' if (dart.library.js_interop) 'save_store_web.dart';

abstract interface class SaveStore {
  /// The newest readable save text; falls back to the backup copy when the
  /// main one is missing. Null on first launch.
  Future<String?> read();

  /// The backup copy alone (used when the main save fails to parse, T-20).
  Future<String?> readBackup();

  Future<void> write(String text);

  Future<void> clear();
}
