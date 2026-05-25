/**
 * consumer.js — Entry point do serviço consumidor (processo separado do HTTP server).
 *
 * Este processo conecta-se ao RabbitMQ e processa mensagens das filas:
 *   • fila_notificacoes_prestador  → evento NOVA_RESERVA_CRIADA
 *   • fila_notificacoes_cliente    → evento STATUS_RESERVA_ATUALIZADO
 *
 * A comunicação é puramente assíncrona: não há chamada REST entre o backend
 * e este consumidor — a única ponte é o RabbitMQ (AMQP 0-9-1).
 */
require('dotenv').config();

const { startConsumer } = require('./src/messaging/consumer');

startConsumer().catch((err) => {
  console.error('[consumer-service] erro fatal:', err.message);
  process.exit(1);
});
