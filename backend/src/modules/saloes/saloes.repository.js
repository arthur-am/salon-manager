const { pool } = require('../../config/db');

async function findAll() {
  const result = await pool.query('SELECT * FROM saloes ORDER BY id');
  return result.rows;
}

async function findById(id) {
  const result = await pool.query('SELECT * FROM saloes WHERE id = $1', [id]);
  return result.rows[0] || null;
}

async function create({ nome, endereco, capacidade, descricao }) {
  const result = await pool.query(
    'INSERT INTO saloes (nome, endereco, capacidade, descricao) VALUES ($1, $2, $3, $4) RETURNING *',
    [nome, endereco, capacidade, descricao]
  );
  return result.rows[0];
}

module.exports = { findAll, findById, create };
