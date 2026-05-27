class Reserva {
  const Reserva({
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

  bool get isPending => status == 'PENDENTE';
  bool get isConfirmed => status == 'CONFIRMADA';
  bool get isRejected => status == 'RECUSADA';
  bool get isDone => status == 'CONCLUIDA';

  String get statusLabel {
    return switch (status) {
      'CONFIRMADA' => 'Confirmada',
      'RECUSADA' => 'Recusada',
      'CONCLUIDA' => 'Concluida',
      _ => 'Aguardando',
    };
  }
}

class ReservaDraft {
  const ReservaDraft({
    required this.salaoId,
    required this.dataReserva,
    required this.clienteNome,
    required this.clienteEmail,
    required this.clienteTelefone,
  });

  final int salaoId;
  final DateTime dataReserva;
  final String clienteNome;
  final String clienteEmail;
  final String clienteTelefone;
}
