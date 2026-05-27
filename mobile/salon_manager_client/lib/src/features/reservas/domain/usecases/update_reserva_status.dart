import '../entities/reserva.dart';
import '../repositories/reservas_repository.dart';

class UpdateReservaStatus {
  const UpdateReservaStatus(this._repository);

  final ReservasRepository _repository;

  Future<Reserva> call({required int reservaId, required String status}) {
    return _repository.updateStatus(reservaId: reservaId, status: status);
  }
}
