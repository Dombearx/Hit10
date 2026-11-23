import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

import 'app_update_state.dart';

/// Play's update dialog was already shown in this run of the game.
bool _offered = false;

/// [completeAppUpdate] is under way (it is called on both hide and pause).
bool _installing = false;

/// Asks Google Play whether a newer version is out. An update already
/// downloaded (in this run or an earlier one) sets [appUpdateReady].
/// With [offer], a new version not yet downloaded starts a flexible
/// update: Play's own dialog, then the download runs in the background
/// while the game goes on. Play's dialog comes at most once per run, so
/// the check on every return to the game ([offer] false) never nags.
///
/// Silent everywhere it cannot work: not Android, an APK installed outside
/// Google Play (CI builds), no network.
Future<void> checkForAppUpdate({bool offer = true}) async {
  if (!Platform.isAndroid) return;
  try {
    final info = await InAppUpdate.checkForUpdate();
    // First: a version still listed as available may already be on the
    // phone, downloaded and waiting (Play's dialog must not come again).
    if (info.installStatus == InstallStatus.downloaded) {
      appUpdateReady.value = true;
      return;
    }
    if (!offer || _offered) return;
    if (info.updateAvailability == UpdateAvailability.updateAvailable &&
        info.flexibleUpdateAllowed) {
      _offered = true;
      // Completes once the download is done (or the player said no).
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) appUpdateReady.value = true;
    }
  } on Object catch (e) {
    debugPrint('in-app update unavailable: $e');
  }
}

/// Installs the downloaded update. In the foreground Android shows its
/// own screen and restarts the game; with the game hidden it installs
/// silently and the next launch is the new version.
Future<void> completeAppUpdate() async {
  if (!appUpdateReady.value || _installing) return;
  _installing = true;
  try {
    await InAppUpdate.completeFlexibleUpdate();
  } on Object catch (e) {
    _installing = false;
    debugPrint('in-app update install failed: $e');
  }
}
