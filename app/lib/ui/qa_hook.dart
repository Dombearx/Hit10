/// QA automation hook (web QA builds only): lets the browser test harness
/// tap at an exact game time and read the state. Compiled in only with
/// `--dart-define=QA=true`; release builds never contain it.
library;

export 'qa_hook_stub.dart' if (dart.library.js_interop) 'qa_hook_web.dart';

const qaEnabled = bool.fromEnvironment('QA');
