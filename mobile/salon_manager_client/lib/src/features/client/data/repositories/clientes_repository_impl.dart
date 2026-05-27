import '../../../../core/network/api_client.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/clientes_repository.dart';
import '../models/cliente_model.dart';

class ClientesRepositoryImpl implements ClientesRepository {
  const ClientesRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Cliente> createCliente(ClienteDraft draft) async {
    final json =
        await _apiClient.post('/api/clientes', {
              'nome': draft.nome,
              'email': draft.email,
              'telefone': draft.telefone,
            })
            as Map<String, dynamic>;

    return ClienteModel.fromJson(json).toEntity();
  }
}
