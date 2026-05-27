import '../entities/salao.dart';

abstract interface class SaloesRepository {
  Future<List<Salao>> listSaloes();
  Future<Salao> getSalao(int id);
}
