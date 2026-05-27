import '../../../client/domain/entities/cliente.dart';
import '../../../client/domain/repositories/clientes_repository.dart';
import '../entities/reserva.dart';
import '../repositories/reservas_repository.dart';

class CreateReservaFlow {
  const CreateReservaFlow(this._clientesRepository, this._reservasRepository);

  final ClientesRepository _clientesRepository;
  final ReservasRepository _reservasRepository;

  Future<Reserva> call(ReservaDraft draft) async {
    final cliente = await _clientesRepository.createCliente(
      ClienteDraft(
        nome: draft.clienteNome,
        email: draft.clienteEmail,
        telefone: draft.clienteTelefone,
      ),
    );

    return _reservasRepository.createReserva(
      clienteId: cliente.id,
      salaoId: draft.salaoId,
      dataReserva: draft.dataReserva,
    );
  }
}
