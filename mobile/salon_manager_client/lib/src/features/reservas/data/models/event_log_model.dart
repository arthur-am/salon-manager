import '../../domain/entities/event_log.dart';

class EventLogModel {
  const EventLogModel({
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

  factory EventLogModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    return EventLogModel(
      id: json['id'] as int,
      tipo: (json['tipo'] ?? '') as String,
      fila: (json['fila'] ?? '') as String,
      payload: rawPayload is Map<String, dynamic> ? rawPayload : {},
      processadoEm:
          DateTime.tryParse((json['processado_em'] ?? '') as String) ??
              DateTime.now(),
    );
  }

  EventLog toEntity() {
    return EventLog(
      id: id,
      tipo: tipo,
      fila: fila,
      payload: payload,
      processadoEm: processadoEm,
    );
  }
}
