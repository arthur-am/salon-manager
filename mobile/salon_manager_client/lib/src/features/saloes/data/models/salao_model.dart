import '../../domain/entities/salao.dart';

class SalaoModel {
  const SalaoModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.capacidade,
    required this.descricao,
  });

  final int id;
  final String nome;
  final String endereco;
  final int capacidade;
  final String descricao;

  factory SalaoModel.fromJson(Map<String, dynamic> json) {
    return SalaoModel(
      id: json['id'] as int,
      nome: (json['nome'] ?? 'Salao sem nome') as String,
      endereco: (json['endereco'] ?? 'Endereco nao informado') as String,
      capacidade: (json['capacidade'] ?? 0) as int,
      descricao: (json['descricao'] ?? 'Descricao nao informada') as String,
    );
  }

  Salao toEntity() {
    return Salao(
      id: id,
      nome: nome,
      endereco: endereco,
      capacidade: capacidade,
      descricao: descricao,
    );
  }
}
