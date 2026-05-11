const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  database: process.env.PGDATABASE || 'salao_festas_db',
  port: process.env.PGPORT ? parseInt(process.env.PGPORT, 10) : 5432,
});

module.exports = { pool };
