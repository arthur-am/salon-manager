import '../../domain/entities/system_status.dart';

class SystemStatusModel {
  const SystemStatusModel({
    required this.status,
    required this.timestamp,
    required this.uptimeSeconds,
    required this.database,
    required this.messaging,
    required this.resilience,
  });

  final String status;
  final DateTime timestamp;
  final int uptimeSeconds;
  final DatabaseStatus database;
  final MessagingStatus messaging;
  final ResilienceStatus resilience;

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) {
    final database = (json['database'] ?? {}) as Map<String, dynamic>;
    final messaging = (json['messaging'] ?? {}) as Map<String, dynamic>;
    final resilience = (json['resilience'] ?? {}) as Map<String, dynamic>;

    return SystemStatusModel(
      status: (json['status'] ?? 'degraded') as String,
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '') as String) ??
          DateTime.now(),
      uptimeSeconds: (json['uptimeSeconds'] ?? 0) as int,
      database: DatabaseStatus(
        connected: database['connected'] == true,
        latencyMs: database['latencyMs'] as int?,
        error: database['error'] as String?,
      ),
      messaging: MessagingStatus(
        connected: messaging['connected'] == true,
        queues: (messaging['queues'] as List<dynamic>? ?? const [])
            .map((queue) => queue.toString())
            .toList(),
        lastConnectedAt: DateTime.tryParse(
          (messaging['lastConnectedAt'] ?? '') as String,
        ),
        lastError: messaging['lastError'] as String?,
        retryDelayMs: (messaging['retryDelayMs'] ?? 0) as int,
      ),
      resilience: ResilienceStatus(
        rest: (resilience['rest'] ?? '') as String,
        stateSync: (resilience['stateSync'] ?? '') as String,
        mom: (resilience['mom'] ?? '') as String,
        nextSprint: (resilience['nextSprint'] ?? '') as String,
      ),
    );
  }

  SystemStatus toEntity() {
    return SystemStatus(
      status: status,
      timestamp: timestamp,
      uptimeSeconds: uptimeSeconds,
      database: database,
      messaging: messaging,
      resilience: resilience,
    );
  }
}
