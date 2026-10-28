import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'save_store.dart';

SaveStore createSaveStore() => WebSaveStore();

/// localStorage-backed store for the web build (QA); same contract as the
/// file store, including the backup slot.
class WebSaveStore implements SaveStore {
  static const _main = 'hit10.save';
  static const _bak = 'hit10.save.bak';

  JSObject get _storage =>
      globalContext.getProperty<JSObject>('localStorage'.toJS);

  String? _get(String k) =>
      _storage.callMethod<JSString?>('getItem'.toJS, k.toJS)?.toDart;

  void _set(String k, String v) =>
      _storage.callMethod<JSAny?>('setItem'.toJS, k.toJS, v.toJS);

  @override
  Future<String?> read() async => _get(_main) ?? _get(_bak);

  @override
  Future<String?> readBackup() async => _get(_bak);

  @override
  Future<void> write(String text) async {
    final old = _get(_main);
    if (old != null) _set(_bak, old);
    _set(_main, text);
  }

  @override
  Future<void> clear() async {
    for (final k in [_main, _bak]) {
      _storage.callMethod<JSAny?>('removeItem'.toJS, k.toJS);
    }
  }
}
