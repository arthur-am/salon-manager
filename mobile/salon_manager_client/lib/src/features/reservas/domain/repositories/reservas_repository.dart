import '../entities/event_log.dart';
import '../entities/reserva.dart';

abstract interface class ReservasRepository {
  Future<List<Reserva>> listReservas();
  Future<Reserva> createReserva({
    required int clienteId,
    required int salaoId,
    required DateTime dataReserva,
  });
  Future<Reserva> updateStatus({
    required int reservaId,
    required String status,
  });
  Future<List<EventLog>> listEventLog({int limit = 20});
}
