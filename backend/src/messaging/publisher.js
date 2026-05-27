const amqp = require('amqplib');

const QUEUES = {
  PRESTADOR: 'fila_notificacoes_prestador',
  CLIENTE: 'fila_notificacoes_cliente',
};

const RETRY_DELAY_MS = 5000;
let channel = null;
let connected = false;
let lastConnectedAt = null;
let lastError = null;

async function connect() {
  // eslint-disable-next-line no-constant-condition
  while (true) {
    try {
      const url = process.env.RABBITMQ_URL || 'amqp://localhost';
      const conn = await amqp.connect(url);
      channel = await conn.createChannel();
      connected = true;
      lastConnectedAt = new Date().toISOString();
      lastError = null;

      await channel.assertQueue(QUEUES.PRESTADOR, { durable: true });
      await channel.assertQueue(QUEUES.CLIENTE, { durable: true });

      console.log('[MOM] publisher conectado ao RabbitMQ');

      conn.on('error', (err) => {
        console.error('[MOM] erro de conexao:', err.message);
        channel = null;
        connected = false;
        lastError = err.message;
      });

      conn.on('close', () => {
        console.warn('[MOM] conexao encerrada - reconectando publisher...');
        channel = null;
        connected = false;
        setTimeout(connect, RETRY_DELAY_MS);
      });

      return;
    } catch (err) {
      channel = null;
      connected = false;
      lastError = err.message;
      console.warn(`[MOM] publisher indisponivel: ${err.message}`);
      console.log(`[MOM] nova tentativa em ${RETRY_DELAY_MS / 1000}s...`);
      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY_MS));
    }
  }
}

function publish(queue, event) {
  if (!channel) {
    console.warn(`[MOM] canal indisponivel - evento ${event.tipo} nao publicado`);
    return false;
  }

  const message = Buffer.from(JSON.stringify(event));
  channel.sendToQueue(queue, message, { persistent: true });
  console.log(`[MOM] publicado em [${queue}]: ${event.tipo}`);
  return true;
}

function getStatus() {
  return {
    connected: connected && Boolean(channel),
    queues: Object.values(QUEUES),
    lastConnectedAt,
    lastError,
    retryDelayMs: RETRY_DELAY_MS,
  };
}

module.exports = { connect, publish, getStatus, QUEUES };
