const express = require('express');
const cors = require('cors');

const saloesRoutes = require('./modules/saloes/saloes.routes');
const clientesRoutes = require('./modules/clientes/clientes.routes');
const reservasRoutes = require('./modules/reservas/reservas.routes');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

app.use('/api/saloes', saloesRoutes);
app.use('/api/clientes', clientesRoutes);
app.use('/api/reservas', reservasRoutes);

module.exports = app;
