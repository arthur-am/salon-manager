const amqp = require('amqplib');

const QUEUES = {
  PRESTADOR: 'fila_notificacoes_prestador',
  CLIENTE: 'fila_notificacoes_cliente',
};

let channel = null;

async function connect() {
  try {
    const url = process.env.RABBITMQ_URL || 'amqp://localhost';
    const conn = await amqp.connect(url);
    channel = await conn.createChannel();
    await channel.assertQueue(QUEUES.PRESTADOR, { durable: true });
    await channel.assertQueue(QUEUES.CLIENTE, { durable: true });
    console.log('[MOM] conectado ao RabbitMQ');
  } catch (err) {
    console.warn('[MOM] indisponivel, seguindo sem MOM:', err.message);
    channel = null;
  }
}

function publish(queue, event) {
  if (!channel) return false;
  channel.sendToQueue(queue, Buffer.from(JSON.stringify(event)), { persistent: true });
  return true;
}

module.exports = { connect, publish, QUEUES };
