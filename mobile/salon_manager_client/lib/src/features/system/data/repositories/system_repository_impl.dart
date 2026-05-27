import '../../../../core/network/api_client.dart';
import '../../domain/entities/system_status.dart';
import '../../domain/repositories/system_repository.dart';
import '../models/system_status_model.dart';

class SystemRepositoryImpl implements SystemRepository {
  const SystemRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SystemStatus> getStatus() async {
    final json = await _apiClient.get('/api/system/status')
        as Map<String, dynamic>;
    return SystemStatusModel.fromJson(json).toEntity();
  }
}
