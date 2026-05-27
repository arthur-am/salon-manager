import '../entities/salao.dart';
import '../repositories/saloes_repository.dart';

class ListSaloes {
  const ListSaloes(this._repository);

  final SaloesRepository _repository;

  Future<List<Salao>> call() => _repository.listSaloes();
}
