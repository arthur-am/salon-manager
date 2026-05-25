const amqp = require('amqplib');
const { pool } = require('../config/db');

const QUEUES = {
  PRESTADOR: 'fila_notificacoes_prestador',
  CLIENTE: 'fila_notificacoes_cliente',
};

const RETRY_DELAY_MS = 5000;

// ─── Persistência do evento processado ──────────────────────────────────────
async function saveEventLog(tipo, fila, payload) {
  await pool.query(
    'INSERT INTO event_log (tipo, fila, payload) VALUES ($1, $2, $3)',
    [tipo, fila, JSON.stringify(payload)]
  );
}

// ─── Processamento de mensagem individual ────────────────────────────────────
async function processMessage(msg, fila) {
  if (!msg) return false;

  let content;
  try {
    content = JSON.parse(msg.content.toString());
  } catch {
    console.error(`[consumer] mensagem malformada em ${fila}, descartando`);
    return false;
  }

  const { tipo, payload } = content;
  const ts = new Date().toISOString();

  console.log(`\n[consumer] ──────────────────────────────────────`);
  console.log(`[consumer] ${ts}`);
  console.log(`[consumer] fila    : ${fila}`);
  console.log(`[consumer] evento  : ${tipo}`);
  console.log(`[consumer] payload : ${JSON.stringify(payload)}`);

  try {
    await saveEventLog(tipo, fila, payload);
    console.log(`[consumer] ✔ evento ${tipo} persistido em event_log`);
    return true;
  } catch (err) {
    console.error(`[consumer] ✘ erro ao persistir evento: ${err.message}`);
    return false;
  }
}

// ─── Loop principal com reconexão automática ─────────────────────────────────
async function startConsumer() {
  const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  console.log('[consumer-service] iniciando loop de conexão...');

  // eslint-disable-next-line no-constant-condition
  while (true) {
    try {
      const url = process.env.RABBITMQ_URL || 'amqp://localhost';
      const conn = await amqp.connect(url);
      const channel = await conn.createChannel();

      await channel.assertQueue(QUEUES.PRESTADOR, { durable: true });
      await channel.assertQueue(QUEUES.CLIENTE, { durable: true });
      channel.prefetch(1); // um evento por vez (fair dispatch)

      console.log('[consumer] ✔ conectado ao RabbitMQ, aguardando mensagens...');

      // Consumidor da fila do prestador (nova reserva criada)
      channel.consume(QUEUES.PRESTADOR, async (msg) => {
        const ok = await processMessage(msg, QUEUES.PRESTADOR);
        if (ok) channel.ack(msg);
        else channel.nack(msg, false, false); // descarta sem requeue em caso de erro
      });

      // Consumidor da fila do cliente (status de reserva atualizado)
      channel.consume(QUEUES.CLIENTE, async (msg) => {
        const ok = await processMessage(msg, QUEUES.CLIENTE);
        if (ok) channel.ack(msg);
        else channel.nack(msg, false, false);
      });

      // Aguarda até a conexão fechar para então reconectar
      await new Promise((resolve, reject) => {
        conn.on('error', reject);
        conn.on('close', resolve);
      });

      console.warn('[consumer] conexão encerrada — reconectando...');
    } catch (err) {
      console.error(`[consumer] falha: ${err.message}`);
    }

    console.log(`[consumer] nova tentativa em ${RETRY_DELAY_MS / 1000}s...`);
    await delay(RETRY_DELAY_MS);
  }
}

module.exports = { startConsumer, QUEUES };
