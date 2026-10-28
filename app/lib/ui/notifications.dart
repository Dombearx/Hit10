/// The single "offline limit reached" notification (R-OFF-4, R-OFF-5).
library;

export 'notifications_stub.dart'
    if (dart.library.io) 'notifications_device.dart';

abstract interface class OfflineNotifications {
  /// Asks the OS for permission (Android 13+); true if granted.
  Future<bool> requestPermission();

  /// Replaces any pending notification with one at [at] saying how much
  /// [amount] the clocks will have earned; [title] formats the amount.
  Future<void> scheduleOfflineFull(
    DateTime at,
    double amount,
    String Function(String amount) title,
  );

  Future<void> cancel();
}

class NoNotifications implements OfflineNotifications {
  const NoNotifications();
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> scheduleOfflineFull(
    DateTime at,
    double amount,
    String Function(String amount) title,
  ) async {}
  @override
  Future<void> cancel() async {}
}
