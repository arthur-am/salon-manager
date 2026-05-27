import '../entities/cliente.dart';

abstract interface class ClientesRepository {
  Future<Cliente> createCliente(ClienteDraft draft);
}
