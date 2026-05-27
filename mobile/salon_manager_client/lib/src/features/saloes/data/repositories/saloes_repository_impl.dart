import '../../../../core/network/api_client.dart';
import '../../domain/entities/salao.dart';
import '../../domain/repositories/saloes_repository.dart';
import '../models/salao_model.dart';

class SaloesRepositoryImpl implements SaloesRepository {
  const SaloesRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Salao>> listSaloes() async {
    final json = await _apiClient.get('/api/saloes') as List<dynamic>;
    return json
        .cast<Map<String, dynamic>>()
        .map((item) => SalaoModel.fromJson(item).toEntity())
        .toList();
  }

  @override
  Future<Salao> getSalao(int id) async {
    final json = await _apiClient.get('/api/saloes/$id') as Map<String, dynamic>;
    return SalaoModel.fromJson(json).toEntity();
  }
}
