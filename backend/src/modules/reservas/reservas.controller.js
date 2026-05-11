const repo = require('./reservas.repository');
const { publish, QUEUES } = require('../../messaging/publisher');

const STATUS_VALIDOS = ['PENDENTE', 'CONFIRMADA', 'RECUSADA', 'CONCLUIDA'];

async function list(req, res) {
  try {
    res.json(await repo.findAll());
  } catch (err) {
    console.error('[reservas.list]', err);
    res.status(500).json({ error: 'Erro ao listar reservas' });
  }
}

async function getById(req, res) {
  try {
    const reserva = await repo.findById(req.params.id);
    if (!reserva) return res.status(404).json({ error: 'Reserva nao encontrada' });
    res.json(reserva);
  } catch (err) {
    console.error('[reservas.getById]', err);
    res.status(500).json({ error: 'Erro ao obter reserva' });
  }
}

async function create(req, res) {
  const { cliente_id, salao_id, data_reserva } = req.body;
  if (!cliente_id || !salao_id || !data_reserva) {
    return res.status(400).json({ error: 'Campos obrigatorios: cliente_id, salao_id, data_reserva' });
  }

  try {
    const nova = await repo.create({ cliente_id, salao_id, data_reserva });
    publish(QUEUES.PRESTADOR, { tipo: 'NOVA_RESERVA_CRIADA', payload: nova });
    res.status(201).json(nova);
  } catch (err) {
    console.error('[reservas.create]', err);
    res.status(500).json({ error: 'Erro ao criar reserva' });
  }
}

async function updateStatus(req, res) {
  const { novo_status } = req.body;
  if (!novo_status) return res.status(400).json({ error: 'Campo obrigatorio: novo_status' });
  if (!STATUS_VALIDOS.includes(novo_status)) {
    return res.status(400).json({
      error: `novo_status invalido. Valores permitidos: ${STATUS_VALIDOS.join(', ')}`,
    });
  }

  try {
    const reserva = await repo.updateStatus(req.params.id, novo_status);
    if (!reserva) return res.status(404).json({ error: 'Reserva nao encontrada' });
    publish(QUEUES.CLIENTE, { tipo: 'STATUS_RESERVA_ATUALIZADO', payload: reserva });
    res.json(reserva);
  } catch (err) {
    console.error('[reservas.updateStatus]', err);
    res.status(500).json({ error: 'Erro ao atualizar reserva' });
  }
}

module.exports = { list, getById, create, updateStatus };
