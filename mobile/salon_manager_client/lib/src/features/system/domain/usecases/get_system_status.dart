import '../entities/system_status.dart';
import '../repositories/system_repository.dart';

class GetSystemStatus {
  const GetSystemStatus(this._repository);

  final SystemRepository _repository;

  Future<SystemStatus> call() => _repository.getStatus();
}
