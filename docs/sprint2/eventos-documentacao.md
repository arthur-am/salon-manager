# Documentação de Eventos — Sprint 2

> **SalonManager** · Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas (LDAMD)
> PUC Minas — Engenharia de Software · 1º Semestre 2026
> Autor: Arthur Araújo Mendonça

---

## 1. Visão Geral da Arquitetura de Eventos

O sistema adota **Event-Driven Architecture (EDA)** com **RabbitMQ** como broker.
Toda comunicação assíncrona ocorre via protocolo **AMQP 0-9-1**.

```
[App Cliente]                [App Prestador]
     │  HTTP REST                  │  HTTP REST
     ▼                             ▼
┌─────────────────────────────────────────────┐
│           Backend API (Node.js/Express)      │
│   ┌─────────────────────────────────────┐   │
│   │        Publisher (AMQP publish)      │   │
│   └────────────┬────────────────────────┘   │
└────────────────│────────────────────────────┘
                 │ AMQP 0-9-1
                 ▼
┌─────────────────────────────────────────────┐
│              RabbitMQ Broker                 │
│  ┌───────────────────────────────────────┐  │
│  │ fila_notificacoes_prestador (durable)  │  │
│  │ fila_notificacoes_cliente   (durable)  │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                 │ AMQP 0-9-1 (consume / ack)
                 ▼
┌─────────────────────────────────────────────┐
│         Consumer Service (processo isolado)  │
│   ┌──────────────────────────────────────┐  │
│   │  Persiste em event_log (PostgreSQL)   │  │
│   └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

> **Princípio de desacoplamento:** o backend (produtor) e o consumer (consumidor) são
> **processos Docker independentes**. Não existe chamada REST ou referência direta de
> código entre eles — a única ponte é o RabbitMQ.

---

## 2. Tabela de Eventos

### Evento 1 — `NOVA_RESERVA_CRIADA`

| Campo      | Valor |
|------------|-------|
| **Nome**   | `NOVA_RESERVA_CRIADA` |
| **Produtor** | Backend API — `POST /api/reservas` (reservas.controller.js) |
| **Consumidor** | Consumer Service (`consumer.js` / `src/messaging/consumer.js`) |
| **Fila / Tópico** | `fila_notificacoes_prestador` |
| **Persistência** | `event_log` (PostgreSQL) |
| **Gatilho de negócio** | Cliente solicita reserva de salão |
| **Ação esperada** | App do prestador é notificado da nova solicitação pendente |

**Payload JSON de exemplo:**

```json
{
  "tipo": "NOVA_RESERVA_CRIADA",
  "payload": {
    "id": 7,
    "cliente_id": 1,
    "salao_id": 2,
    "data_reserva": "2026-06-15T20:00:00.000Z",
    "status": "PENDENTE",
    "created_at": "2026-05-25T14:32:10.000Z"
  }
}
```

**Linha correspondente em `event_log`:**

```json
{
  "id": 1,
  "tipo": "NOVA_RESERVA_CRIADA",
  "fila": "fila_notificacoes_prestador",
  "payload": {
    "id": 7,
    "cliente_id": 1,
    "salao_id": 2,
    "data_reserva": "2026-06-15T20:00:00.000Z",
    "status": "PENDENTE",
    "created_at": "2026-05-25T14:32:10.000Z"
  },
  "processado_em": "2026-05-25T14:32:10.123Z"
}
```

---

### Evento 2 — `STATUS_RESERVA_ATUALIZADO`

| Campo      | Valor |
|------------|-------|
| **Nome**   | `STATUS_RESERVA_ATUALIZADO` |
| **Produtor** | Backend API — `PUT /api/reservas/:id/status` (reservas.controller.js) |
| **Consumidor** | Consumer Service (`consumer.js` / `src/messaging/consumer.js`) |
| **Fila / Tópico** | `fila_notificacoes_cliente` |
| **Persistência** | `event_log` (PostgreSQL) |
| **Gatilho de negócio** | Prestador aceita, recusa ou conclui uma reserva |
| **Ação esperada** | App do cliente é notificado da mudança de status |

**Payload JSON de exemplo (confirmação):**

```json
{
  "tipo": "STATUS_RESERVA_ATUALIZADO",
  "payload": {
    "id": 7,
    "cliente_id": 1,
    "salao_id": 2,
    "data_reserva": "2026-06-15T20:00:00.000Z",
    "status": "CONFIRMADA",
    "created_at": "2026-05-25T14:32:10.000Z"
  }
}
```

**Linha correspondente em `event_log`:**

```json
{
  "id": 2,
  "tipo": "STATUS_RESERVA_ATUALIZADO",
  "fila": "fila_notificacoes_cliente",
  "payload": {
    "id": 7,
    "cliente_id": 1,
    "salao_id": 2,
    "data_reserva": "2026-06-15T20:00:00.000Z",
    "status": "CONFIRMADA",
    "created_at": "2026-05-25T14:32:10.000Z"
  },
  "processado_em": "2026-05-25T14:35:22.456Z"
}
```

---

## 3. Resumo das Filas

| Fila | Tipo | Durável | Produtor | Consumidor |
|------|------|---------|----------|------------|
| `fila_notificacoes_prestador` | Work Queue | ✅ Sim | Backend API | Consumer Service |
| `fila_notificacoes_cliente`   | Work Queue | ✅ Sim | Backend API | Consumer Service |

> **Durable = true** garante que as mensagens sobrevivem a reinicializações do broker.
> **Persistent = true** nas mensagens garante que não são perdidas em caso de queda do RabbitMQ.

---

## 4. Fluxo Completo de Eventos

```
Cliente (App/Postman)
    │
    │ POST /api/reservas
    ▼
Backend API
    ├── Persiste reserva em PostgreSQL (status = PENDENTE)
    ├── Retorna 201 Created ao chamador
    └── publish(fila_notificacoes_prestador, { tipo: "NOVA_RESERVA_CRIADA", payload: reserva })
                │
                │ AMQP — sem chamada REST
                ▼
         RabbitMQ Broker
                │
                │ consume (ack manual)
                ▼
         Consumer Service
                ├── Loga: [consumer] NOVA_RESERVA_CRIADA
                └── INSERT INTO event_log (...)
                            │
                            │ TCP / SQL
                            ▼
                       PostgreSQL
                       (event_log)

─── Mais tarde: Prestador atualiza status ───────────────────────

Prestador (App/Postman)
    │
    │ PUT /api/reservas/7/status  { "novo_status": "CONFIRMADA" }
    ▼
Backend API
    ├── Atualiza reserva em PostgreSQL
    ├── Retorna 200 OK ao chamador
    └── publish(fila_notificacoes_cliente, { tipo: "STATUS_RESERVA_ATUALIZADO", payload: reserva })
                │
                │ AMQP — sem chamada REST
                ▼
         RabbitMQ Broker
                │
                │ consume (ack manual)
                ▼
         Consumer Service
                ├── Loga: [consumer] STATUS_RESERVA_ATUALIZADO
                └── INSERT INTO event_log (...)
```

---

## 5. Consulta de Evidências via API

```bash
# Todos os eventos processados
GET http://localhost:3000/api/event-log

# Filtrar por tipo
GET http://localhost:3000/api/event-log?tipo=NOVA_RESERVA_CRIADA

# Filtrar por fila
GET http://localhost:3000/api/event-log?fila=fila_notificacoes_prestador

# Limitar quantidade
GET http://localhost:3000/api/event-log?limit=10
```

---

## 6. Referências

- HOHPE, G.; WOOLF, B. *Enterprise Integration Patterns.* Addison-Wesley, 2003.
- RabbitMQ Documentation: https://www.rabbitmq.com/documentation.html
- RICHARDSON, C. *Microservices Patterns.* Manning, 2018.
