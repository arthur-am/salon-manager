import '../entities/salao.dart';
import '../repositories/saloes_repository.dart';

class GetSalao {
  const GetSalao(this._repository);

  final SaloesRepository _repository;

  Future<Salao> call(int id) => _repository.getSalao(id);
}
