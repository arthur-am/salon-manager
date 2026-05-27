import '../entities/system_status.dart';

abstract interface class SystemRepository {
  Future<SystemStatus> getStatus();
}
