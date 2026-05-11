const { pool } = require('../../config/db');

async function findAll() {
  const result = await pool.query('SELECT * FROM clientes ORDER BY id');
  return result.rows;
}

async function findById(id) {
  const result = await pool.query('SELECT * FROM clientes WHERE id = $1', [id]);
  return result.rows[0] || null;
}

async function create({ nome, email, telefone }) {
  const result = await pool.query(
    'INSERT INTO clientes (nome, email, telefone) VALUES ($1, $2, $3) RETURNING *',
    [nome, email, telefone]
  );
  return result.rows[0];
}

async function update(id, { nome, email, telefone }) {
  const result = await pool.query(
    `UPDATE clientes
     SET nome = COALESCE($1, nome),
         email = COALESCE($2, email),
         telefone = COALESCE($3, telefone)
     WHERE id = $4 RETURNING *`,
    [nome, email, telefone, id]
  );
  return result.rows[0] || null;
}

async function remove(id) {
  const result = await pool.query('DELETE FROM clientes WHERE id = $1 RETURNING id', [id]);
  return result.rowCount > 0;
}

module.exports = { findAll, findById, create, update, remove };
