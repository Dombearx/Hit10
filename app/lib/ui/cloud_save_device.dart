import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

import '../persistence/cloud_save.dart';

/// The Play Games project (docs/05 T-35). Release builds pass it with
/// `--dart-define=PLAY_GAMES_APP_ID=…` (and the same id to Gradle for the
/// manifest); without it the game never calls Play Games.
const _appId = String.fromEnvironment('PLAY_GAMES_APP_ID');

CloudSave createCloudSave() => Platform.isAndroid && _appId.isNotEmpty
    ? PlayGamesCloudSave()
    : const NoCloudSave();

/// Saved Games behind the game's [CloudSave] door: one snapshot, the
/// same text as the save export (T-19). Never throws.
class PlayGamesCloudSave implements CloudSave {
  static const _name = 'hit5-save';

  @override
  bool get available => true;

  @override
  Future<bool> signedIn() async {
    // Play Games signs in by itself at launch; give it a few seconds.
    final c = Completer<bool>();
    StreamSubscription<PlayerData?>? sub;
    final timer = Timer(const Duration(seconds: 8), () {
      if (!c.isCompleted) c.complete(false);
    });
    try {
      sub = GameAuth.player.listen(
        (p) {
          if (p != null && !c.isCompleted) c.complete(true);
        },
        onError: (Object _) {
          if (!c.isCompleted) c.complete(false);
        },
      );
      return await c.future;
    } on Object catch (e) {
      debugPrint('play games: $e');
      return false;
    } finally {
      timer.cancel();
      unawaited(sub?.cancel());
    }
  }

  @override
  Future<bool> signIn() async {
    try {
      await GameAuth.signIn();
      return await GameAuth.isSignedIn;
    } on Object catch (e) {
      debugPrint('play games sign-in: $e');
      return false;
    }
  }

  @override
  Future<String?> load() async {
    try {
      return await SaveGame.loadGame(name: _name);
    } on Object catch (e) {
      // No snapshot yet is an error too.
      debugPrint('cloud load: $e');
      return null;
    }
  }

  @override
  Future<bool> save(
    String data, {
    required Duration played,
    required String description,
  }) async {
    try {
      await SaveGame.saveGame(
        data: data,
        name: _name,
        playedTime: played,
        description: description,
      );
      return true;
    } on Object catch (e) {
      debugPrint('cloud save: $e');
      return false;
    }
  }
}
