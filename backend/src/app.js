const express = require('express');
const cors = require('cors');

const saloesRoutes    = require('./modules/saloes/saloes.routes');
const clientesRoutes  = require('./modules/clientes/clientes.routes');
const reservasRoutes  = require('./modules/reservas/reservas.routes');
const eventLogRoutes  = require('./modules/event-log/event-log.routes');

const app = express();
app.use(cors());
app.use(express.json());

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

// ── Recursos de negócio (Sprint 1) ───────────────────────────────────────────
app.use('/api/saloes',   saloesRoutes);
app.use('/api/clientes', clientesRoutes);
app.use('/api/reservas', reservasRoutes);

// ── Evidência de eventos MOM (Sprint 2) ──────────────────────────────────────
// Retorna os eventos processados pelo consumer-service via RabbitMQ.
// GET /api/event-log?tipo=NOVA_RESERVA_CRIADA
// GET /api/event-log?fila=fila_notificacoes_prestador
// GET /api/event-log?limit=20
app.use('/api/event-log', eventLogRoutes);

module.exports = app;
