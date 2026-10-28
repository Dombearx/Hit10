import 'save_store.dart';

/// In-memory store for tests.
class MemorySaveStore implements SaveStore {
  String? main;
  String? backup;
  int writes = 0;

  @override
  Future<String?> read() async => main ?? backup;

  @override
  Future<String?> readBackup() async => backup;

  @override
  Future<void> write(String text) async {
    writes++;
    if (main != null) backup = main;
    main = text;
  }

  @override
  Future<void> clear() async {
    main = null;
    backup = null;
  }
}
