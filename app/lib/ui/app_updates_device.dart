import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Asks Google Play whether a newer version is out and, if so, starts a
/// flexible update: Play's own dialog, the download runs in the background
/// while the game goes on. [onDownloaded] fires when it is ready to install.
///
/// Silent everywhere it cannot work: not Android, an APK installed outside
/// Google Play (CI builds), no network.
Future<void> checkForAppUpdate({
  required void Function() onDownloaded,
}) async {
  if (!Platform.isAndroid) return;
  try {
    final info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability == UpdateAvailability.updateAvailable &&
        info.flexibleUpdateAllowed) {
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) onDownloaded();
    } else if (info.installStatus == InstallStatus.downloaded) {
      // Downloaded in an earlier session but never installed.
      onDownloaded();
    }
  } on Object catch (e) {
    debugPrint('in-app update unavailable: $e');
  }
}

/// Installs the downloaded update; Android restarts the game.
Future<void> completeAppUpdate() async {
  try {
    await InAppUpdate.completeFlexibleUpdate();
  } on Object catch (e) {
    debugPrint('in-app update install failed: $e');
  }
}
