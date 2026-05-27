import '../../domain/entities/cliente.dart';

class ClienteModel {
  const ClienteModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int,
      nome: (json['nome'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      telefone: (json['telefone'] ?? '') as String,
    );
  }

  Cliente toEntity() {
    return Cliente(id: id, nome: nome, email: email, telefone: telefone);
  }
}
