const amqp = require('amqplib');

const QUEUES = {
  PRESTADOR: 'fila_notificacoes_prestador',
  CLIENTE: 'fila_notificacoes_cliente',
};

const RETRY_DELAY_MS = 5000;
let channel = null;

// ─── Conexão com reconexão automática ────────────────────────────────────────
async function connect() {
  // eslint-disable-next-line no-constant-condition
  while (true) {
    try {
      const url = process.env.RABBITMQ_URL || 'amqp://localhost';
      const conn = await amqp.connect(url);
      channel = await conn.createChannel();

      await channel.assertQueue(QUEUES.PRESTADOR, { durable: true });
      await channel.assertQueue(QUEUES.CLIENTE, { durable: true });

      console.log('[MOM] ✔ publisher conectado ao RabbitMQ');

      conn.on('error', (err) => {
        console.error('[MOM] erro de conexão:', err.message);
        channel = null;
      });

      conn.on('close', () => {
        console.warn('[MOM] conexão encerrada — reconectando publisher...');
        channel = null;
        setTimeout(connect, RETRY_DELAY_MS);
      });

      return; // conectou com sucesso, sai do loop
    } catch (err) {
      console.warn(`[MOM] publisher indisponível: ${err.message}`);
      console.log(`[MOM] nova tentativa em ${RETRY_DELAY_MS / 1000}s...`);
      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY_MS));
    }
  }
}

// ─── Publicação de evento ─────────────────────────────────────────────────────
function publish(queue, event) {
  if (!channel) {
    console.warn(`[MOM] canal indisponível — evento ${event.tipo} não publicado`);
    return false;
  }

  const message = Buffer.from(JSON.stringify(event));
  channel.sendToQueue(queue, message, { persistent: true });
  console.log(`[MOM] ✔ publicado em [${queue}]: ${event.tipo}`);
  return true;
}

module.exports = { connect, publish, QUEUES };
