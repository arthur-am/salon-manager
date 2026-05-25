const repo = require('./event-log.repository');

/**
 * GET /api/event-log
 * Query params opcionais:
 *   ?tipo=NOVA_RESERVA_CRIADA
 *   ?fila=fila_notificacoes_prestador
 *   ?limit=50
 *
 * Retorna os eventos que o consumer processou e persistiu no banco,
 * servindo como evidência de comunicação assíncrona via MOM.
 */
async function list(req, res) {
  try {
    const { tipo, fila, limit } = req.query;

    let eventos;
    if (tipo) {
      eventos = await repo.findByTipo(tipo);
    } else if (fila) {
      eventos = await repo.findByFila(fila);
    } else {
      eventos = await repo.findAll({ limit: limit ? parseInt(limit, 10) : 100 });
    }

    res.json(eventos);
  } catch (err) {
    console.error('[event-log.list]', err);
    res.status(500).json({ error: 'Erro ao listar event log' });
  }
}

module.exports = { list };
