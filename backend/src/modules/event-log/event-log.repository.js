const { pool } = require('../../config/db');

/**
 * Lista os eventos processados pelo consumer, do mais recente ao mais antigo.
 * @param {number} limit - máximo de registros (padrão: 100)
 */
async function findAll({ limit = 100 } = {}) {
  const result = await pool.query(
    'SELECT * FROM event_log ORDER BY processado_em DESC LIMIT $1',
    [limit]
  );
  return result.rows;
}

/**
 * Filtra eventos por tipo (ex.: NOVA_RESERVA_CRIADA).
 */
async function findByTipo(tipo) {
  const result = await pool.query(
    'SELECT * FROM event_log WHERE tipo = $1 ORDER BY processado_em DESC',
    [tipo]
  );
  return result.rows;
}

/**
 * Filtra eventos por fila.
 */
async function findByFila(fila) {
  const result = await pool.query(
    'SELECT * FROM event_log WHERE fila = $1 ORDER BY processado_em DESC',
    [fila]
  );
  return result.rows;
}

module.exports = { findAll, findByTipo, findByFila };
