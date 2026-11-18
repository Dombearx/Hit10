import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

/// Play's own rating window over the game. Google decides whether it
/// actually appears (it limits how often); the game never learns the
/// answer and never asks again for the same reason.
Future<void> requestReview() async {
  if (!Platform.isAndroid) return;
  try {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  } on Object catch (e) {
    debugPrint('in-app review unavailable: $e');
  }
}
