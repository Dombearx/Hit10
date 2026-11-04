import '../analytics/analytics.dart';

/// No statistics on this platform (web QA builds).
Future<Analytics> createAnalytics() async => const NoAnalytics();
