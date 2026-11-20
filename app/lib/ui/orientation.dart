import 'dart:ui' show PlatformDispatcher, Size;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Phones play upright only (01-wizja); tablets and unfolded foldables may
/// turn (docs/04 §1.1, Google Play's large-screen guidance). Android 16
/// ignores a fixed orientation on large screens anyway, so the manifest
/// declares none and the phone lock is set here, at run time.
class OrientationPolicy with WidgetsBindingObserver {
  OrientationPolicy._();

  static final instance = OrientationPolicy._();

  /// Android's own line between a phone and a large screen: 600 dp on the
  /// display's shorter side.
  static const largeScreenSide = 600.0;

  /// The orientations allowed on a display of [logical] size; empty means
  /// "whatever the system and the sensor want".
  static List<DeviceOrientation> orientationsFor(Size logical) =>
      logical.shortestSide >= largeScreenSide
      ? const []
      : const [DeviceOrientation.portraitUp];

  List<DeviceOrientation>? _applied;

  /// Applies the policy now and again whenever the screen changes (a
  /// foldable opening or closing).
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await _apply();
  }

  @override
  void didChangeMetrics() => _apply();

  Future<void> _apply() async {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) return;
    // The whole display, not the window: a phone in split screen is
    // still a phone.
    final display = views.first.display;
    final want = orientationsFor(display.size / display.devicePixelRatio);
    if (_applied != null && listEquals(_applied, want)) return;
    _applied = want;
    await SystemChrome.setPreferredOrientations(want);
  }
}
