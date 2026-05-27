class SystemStatus {
  const SystemStatus({
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

  bool get healthy => status == 'ok';
}

class DatabaseStatus {
  const DatabaseStatus({
    required this.connected,
    required this.latencyMs,
    required this.error,
  });

  final bool connected;
  final int? latencyMs;
  final String? error;
}

class MessagingStatus {
  const MessagingStatus({
    required this.connected,
    required this.queues,
    required this.lastConnectedAt,
    required this.lastError,
    required this.retryDelayMs,
  });

  final bool connected;
  final List<String> queues;
  final DateTime? lastConnectedAt;
  final String? lastError;
  final int retryDelayMs;
}

class ResilienceStatus {
  const ResilienceStatus({
    required this.rest,
    required this.stateSync,
    required this.mom,
    required this.nextSprint,
  });

  final String rest;
  final String stateSync;
  final String mom;
  final String nextSprint;
}
