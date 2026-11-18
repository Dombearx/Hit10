import '../persistence/cloud_save.dart';

/// No cloud save on this platform (web QA builds).
CloudSave createCloudSave() => const NoCloudSave();
