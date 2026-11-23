import 'package:flutter/foundation.dart';

/// True once a Google Play update is downloaded and waits to be installed.
/// It stays true until the game restarts into the new version, so the
/// game can keep showing it (a dot on the settings icon, a row in the
/// settings) after the message about it is gone.
final ValueNotifier<bool> appUpdateReady = ValueNotifier(false);
