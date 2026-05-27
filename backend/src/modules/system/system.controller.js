const { pool } = require('../../config/db');
const publisher = require('../../messaging/publisher');

async function status(req, res) {
  const startedAt = new Date(Date.now() - process.uptime() * 1000).toISOString();
  const database = {
    connected: false,
    latencyMs: null,
    error: null,
  };

  const start = Date.now();
  try {
    await pool.query('SELECT 1');
    database.connected = true;
    database.latencyMs = Date.now() - start;
  } catch (err) {
    database.error = err.message;
  }

  const messaging = publisher.getStatus();
  const healthy = database.connected && messaging.connected;

  res.status(healthy ? 200 : 207).json({
    service: 'salon-manager-api',
    status: healthy ? 'ok' : 'degraded',
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.floor(process.uptime()),
    startedAt,
    database,
    messaging,
    resilience: {
      rest: 'timeout + retry no app cliente',
      stateSync: 'polling assincrono das reservas e do event_log',
      mom: 'RabbitMQ durable queues + consumer separado',
      nextSprint: 'Transactional Outbox Pattern + publisher-service + replicas',
    },
  });
}

module.exports = { status };
