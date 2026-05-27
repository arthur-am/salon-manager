import '../../domain/entities/reserva.dart';

class ReservaModel {
  const ReservaModel({
    required this.id,
    required this.clienteId,
    required this.salaoId,
    required this.dataReserva,
    required this.status,
    required this.createdAt,
    required this.clienteNome,
    required this.salaoNome,
  });

  final int id;
  final int? clienteId;
  final int? salaoId;
  final DateTime dataReserva;
  final String status;
  final DateTime createdAt;
  final String clienteNome;
  final String salaoNome;

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] as int,
      clienteId: json['cliente_id'] as int?,
      salaoId: json['salao_id'] as int?,
      dataReserva: DateTime.parse(json['data_reserva'] as String),
      status: (json['status'] ?? 'PENDENTE') as String,
      createdAt: DateTime.tryParse((json['created_at'] ?? '') as String) ??
          DateTime.now(),
      clienteNome: (json['cliente_nome'] ?? 'Cliente') as String,
      salaoNome: (json['salao_nome'] ?? 'Salao') as String,
    );
  }

  Reserva toEntity() {
    return Reserva(
      id: id,
      clienteId: clienteId,
      salaoId: salaoId,
      dataReserva: dataReserva,
      status: status,
      createdAt: createdAt,
      clienteNome: clienteNome,
      salaoNome: salaoNome,
    );
  }
}
