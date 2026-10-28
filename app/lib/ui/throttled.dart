import 'dart:async';

import 'package:flutter/foundation.dart';

/// Re-broadcasts [source] at most once per [interval] (trailing edge), for
/// widgets that need not repaint at the 10 Hz economy tick (T-21).
class ThrottledListenable extends ChangeNotifier {
  ThrottledListenable(this.source, this.interval) {
    source.addListener(_onSource);
  }

  final Listenable source;
  final Duration interval;
  Timer? _timer;
  bool _pending = false;

  void _onSource() {
    if (_timer != null) {
      _pending = true;
      return;
    }
    notifyListeners();
    _timer = Timer(interval, () {
      _timer = null;
      if (_pending) {
        _pending = false;
        _onSource();
      }
    });
  }

  @override
  void dispose() {
    source.removeListener(_onSource);
    _timer?.cancel();
    super.dispose();
  }
}
