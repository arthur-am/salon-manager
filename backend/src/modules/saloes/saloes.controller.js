const repo = require('./saloes.repository');

async function list(req, res) {
  try {
    const saloes = await repo.findAll();
    res.json(saloes);
  } catch (err) {
    console.error('[saloes.list]', err);
    res.status(500).json({ error: 'Erro ao listar saloes' });
  }
}

async function getById(req, res) {
  try {
    const salao = await repo.findById(req.params.id);
    if (!salao) return res.status(404).json({ error: 'Salao nao encontrado' });
    res.json(salao);
  } catch (err) {
    console.error('[saloes.getById]', err);
    res.status(500).json({ error: 'Erro ao obter detalhes do salao' });
  }
}

async function create(req, res) {
  const { nome, endereco, capacidade, descricao } = req.body;
  if (!nome) return res.status(400).json({ error: 'Campo obrigatorio: nome' });

  try {
    const novo = await repo.create({ nome, endereco, capacidade, descricao });
    res.status(201).json(novo);
  } catch (err) {
    console.error('[saloes.create]', err);
    res.status(500).json({ error: 'Erro ao criar salao' });
  }
}

module.exports = { list, getById, create };
