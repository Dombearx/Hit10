import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'save_store.dart';

SaveStore createSaveStore() => FileSaveStore();

/// `save.json` written via a temp file and rename, so a crash mid-write
/// never leaves a half file; the previous save is kept as `save.bak.json`.
class FileSaveStore implements SaveStore {
  FileSaveStore({Future<Directory> Function()? dir})
    : _dir = dir ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _dir;

  Future<File> _file(String name) async => File('${(await _dir()).path}/$name');

  @override
  Future<String?> read() async {
    final main = await _file('save.json');
    if (await main.exists()) return main.readAsString();
    return readBackup();
  }

  @override
  Future<String?> readBackup() async {
    final bak = await _file('save.bak.json');
    return await bak.exists() ? bak.readAsString() : null;
  }

  @override
  Future<void> write(String text) async {
    final main = await _file('save.json');
    final tmp = await _file('save.tmp');
    await tmp.writeAsString(text, flush: true);
    if (await main.exists()) {
      await main.copy((await _file('save.bak.json')).path);
    }
    await tmp.rename(main.path);
  }

  @override
  Future<void> clear() async {
    for (final n in ['save.json', 'save.bak.json', 'save.tmp']) {
      final f = await _file(n);
      if (await f.exists()) await f.delete();
    }
  }
}
