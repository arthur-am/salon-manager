import '../entities/event_log.dart';
import '../entities/reserva.dart';
import '../repositories/reservas_repository.dart';

class ReservasSnapshot {
  const ReservasSnapshot({
    required this.reservas,
    required this.events,
    required this.syncedAt,
  });

  final List<Reserva> reservas;
  final List<EventLog> events;
  final DateTime syncedAt;
}

class WatchReservasSnapshot {
  const WatchReservasSnapshot(this._repository);

  final ReservasRepository _repository;

  Future<ReservasSnapshot> call() async {
    final results = await Future.wait<Object>([
      _repository.listReservas(),
      _repository.listEventLog(limit: 24),
    ]);

    return ReservasSnapshot(
      reservas: results[0] as List<Reserva>,
      events: results[1] as List<EventLog>,
      syncedAt: DateTime.now(),
    );
  }
}
