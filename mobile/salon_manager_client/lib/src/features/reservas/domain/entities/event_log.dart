class EventLog {
  const EventLog({
    required this.id,
    required this.tipo,
    required this.fila,
    required this.payload,
    required this.processadoEm,
  });

  final int id;
  final String tipo;
  final String fila;
  final Map<String, dynamic> payload;
  final DateTime processadoEm;
}
