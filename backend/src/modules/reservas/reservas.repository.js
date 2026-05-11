const { pool } = require('../../config/db');

async function findAll() {
  const result = await pool.query(
    `SELECT r.*, c.nome AS cliente_nome, s.nome AS salao_nome
     FROM reservas r
     LEFT JOIN clientes c ON c.id = r.cliente_id
     LEFT JOIN saloes s ON s.id = r.salao_id
     ORDER BY r.id DESC`
  );
  return result.rows;
}

async function findById(id) {
  const result = await pool.query(
    `SELECT r.*, c.nome AS cliente_nome, s.nome AS salao_nome
     FROM reservas r
     LEFT JOIN clientes c ON c.id = r.cliente_id
     LEFT JOIN saloes s ON s.id = r.salao_id
     WHERE r.id = $1`,
    [id]
  );
  return result.rows[0] || null;
}

async function create({ cliente_id, salao_id, data_reserva }) {
  const result = await pool.query(
    `INSERT INTO reservas (cliente_id, salao_id, data_reserva, status)
     VALUES ($1, $2, $3, 'PENDENTE') RETURNING *`,
    [cliente_id, salao_id, data_reserva]
  );
  return result.rows[0];
}

async function updateStatus(id, novo_status) {
  const result = await pool.query(
    'UPDATE reservas SET status = $1 WHERE id = $2 RETURNING *',
    [novo_status, id]
  );
  return result.rows[0] || null;
}

module.exports = { findAll, findById, create, updateStatus };
