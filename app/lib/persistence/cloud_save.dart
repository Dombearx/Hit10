/// Cloud save through Google Play Games Saved Games (docs/05 T-35): free,
/// no backend, no account of ours. Pure Dart: the device build plugs Play
/// Games in behind [CloudSave], tests use [MemoryCloudSave].
library;

import 'save_codec.dart';

abstract interface class CloudSave {
  /// This build and platform can use it (a Play Games project id was
  /// built in, Android).
  bool get available;

  /// Whether the player is signed in to Play Games; waits a few seconds
  /// for the automatic sign-in at launch.
  Future<bool> signedIn();

  /// Asks the player to sign in (Play Games' own window). True when signed
  /// in afterwards.
  Future<bool> signIn();

  /// The saved text, or null when there is none (or no connection).
  Future<String?> load();

  /// Replaces the cloud save. True when it was written.
  Future<bool> save(
    String data, {
    required Duration played,
    required String description,
  });
}

/// No cloud: web, tests, builds without a Play Games project.
class NoCloudSave implements CloudSave {
  const NoCloudSave();
  @override
  bool get available => false;
  @override
  Future<bool> signedIn() async => false;
  @override
  Future<bool> signIn() async => false;
  @override
  Future<String?> load() async => null;
  @override
  Future<bool> save(
    String data, {
    required Duration played,
    required String description,
  }) async => false;
}

/// A cloud in memory, for tests.
class MemoryCloudSave implements CloudSave {
  MemoryCloudSave({this.data, this.signed = true});
  String? data;
  bool signed;
  int saves = 0;
  @override
  bool get available => true;
  @override
  Future<bool> signedIn() async => signed;
  @override
  Future<bool> signIn() async => signed = true;
  @override
  Future<String?> load() async => signed ? data : null;
  @override
  Future<bool> save(
    String data, {
    required Duration played,
    required String description,
  }) async {
    if (!signed) return false;
    saves++;
    this.data = data;
    return true;
  }
}

/// A cloud save with more progress than this phone's, offered to the
/// player (never loaded without asking).
class CloudOffer {
  CloudOffer(this.text, this.data);

  /// The export text, ready for [importSave].
  final String text;
  final SaveData data;

  double get playSeconds => data.state.lifetime.secondsPlayed;
  double get earnedEver => data.state.lifetime.earnedEver;
}

/// When a cloud save is worth offering instead of this phone's.
abstract final class CloudSync {
  /// The cloud must be ahead by more than this much play.
  static const minLead = 120.0;

  /// Uploads happen at most this often (leaving the app twice in a row
  /// does not write twice).
  static const minUploadGap = Duration(seconds: 60);

  /// [text] as an offer when it holds clearly more play than
  /// [localPlaySeconds] and the player has not turned down a save with
  /// this much play before ([declined]). Null for anything else,
  /// including text that is not a save.
  static CloudOffer? offer(
    String? text,
    double localPlaySeconds, {
    Set<int> declined = const {},
  }) {
    if (text == null || text.isEmpty) return null;
    final SaveData data;
    try {
      data = importSave(text);
    } on SaveFormatException {
      return null;
    }
    final o = CloudOffer(text, data);
    if (o.playSeconds <= localPlaySeconds + minLead) return null;
    if (declined.contains(o.playSeconds.round())) return null;
    return o;
  }
}
