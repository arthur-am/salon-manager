import '../../../../core/network/api_client.dart';
import '../../domain/entities/event_log.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reservas_repository.dart';
import '../models/event_log_model.dart';
import '../models/reserva_model.dart';

class ReservasRepositoryImpl implements ReservasRepository {
  const ReservasRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Reserva>> listReservas() async {
    final json = await _apiClient.get('/api/reservas') as List<dynamic>;
    return json
        .cast<Map<String, dynamic>>()
        .map((item) => ReservaModel.fromJson(item).toEntity())
        .toList();
  }

  @override
  Future<Reserva> createReserva({
    required int clienteId,
    required int salaoId,
    required DateTime dataReserva,
  }) async {
    final json =
        await _apiClient.post('/api/reservas', {
              'cliente_id': clienteId,
              'salao_id': salaoId,
              'data_reserva': dataReserva.toIso8601String(),
            })
            as Map<String, dynamic>;

    return ReservaModel.fromJson(json).toEntity();
  }

  @override
  Future<Reserva> updateStatus({
    required int reservaId,
    required String status,
  }) async {
    final json =
        await _apiClient.put('/api/reservas/$reservaId/status', {
              'novo_status': status,
            })
            as Map<String, dynamic>;

    return ReservaModel.fromJson(json).toEntity();
  }

  @override
  Future<List<EventLog>> listEventLog({int limit = 20}) async {
    final json =
        await _apiClient.get('/api/event-log?limit=$limit') as List<dynamic>;
    return json
        .cast<Map<String, dynamic>>()
        .map((item) => EventLogModel.fromJson(item).toEntity())
        .toList();
  }
}
