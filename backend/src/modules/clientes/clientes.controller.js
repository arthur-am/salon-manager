const repo = require('./clientes.repository');

async function list(req, res) {
  try {
    res.json(await repo.findAll());
  } catch (err) {
    console.error('[clientes.list]', err);
    res.status(500).json({ error: 'Erro ao listar clientes' });
  }
}

async function getById(req, res) {
  try {
    const cliente = await repo.findById(req.params.id);
    if (!cliente) return res.status(404).json({ error: 'Cliente nao encontrado' });
    res.json(cliente);
  } catch (err) {
    console.error('[clientes.getById]', err);
    res.status(500).json({ error: 'Erro ao obter cliente' });
  }
}

async function create(req, res) {
  const { nome, email, telefone } = req.body;
  if (!nome) return res.status(400).json({ error: 'Campo obrigatorio: nome' });

  try {
    const novo = await repo.create({ nome, email, telefone });
    res.status(201).json(novo);
  } catch (err) {
    console.error('[clientes.create]', err);
    res.status(500).json({ error: 'Erro ao criar cliente' });
  }
}

async function update(req, res) {
  try {
    const atualizado = await repo.update(req.params.id, req.body);
    if (!atualizado) return res.status(404).json({ error: 'Cliente nao encontrado' });
    res.json(atualizado);
  } catch (err) {
    console.error('[clientes.update]', err);
    res.status(500).json({ error: 'Erro ao atualizar cliente' });
  }
}

async function remove(req, res) {
  try {
    const ok = await repo.remove(req.params.id);
    if (!ok) return res.status(404).json({ error: 'Cliente nao encontrado' });
    res.status(204).end();
  } catch (err) {
    console.error('[clientes.remove]', err);
    res.status(500).json({ error: 'Erro ao remover cliente' });
  }
}

module.exports = { list, getById, create, update, remove };
