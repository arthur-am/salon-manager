# Backend (Sprint 1)

Instalação e execução (com Docker Compose):

```bash
docker-compose up --build
```

Isso inicializa os serviços:
- Postgres: `salao_festas_db` (porta 5432)
- RabbitMQ (management UI em `http://localhost:15672`, user/pass padrão guest/guest)
- Backend Node.js na porta 3000

Endpoints principais:

- `GET /api/saloes` -> lista salões
- `GET /api/saloes/:id` -> detalhes do salão
- `POST /api/reservas` -> criar reserva (body: `cliente_id`, `salao_id`, `data_reserva`)
- `GET /api/reservas` -> listar reservas
- `PUT /api/reservas/:id/status` -> atualizar status (body: `novo_status`)

Exemplo cURL para criar reserva:

```bash
curl -X POST http://localhost:3000/api/reservas \
  -H 'Content-Type: application/json' \
  -d '{"cliente_id":1,"salao_id":1,"data_reserva":"2026-05-10T19:00:00"}'
```

Coleção Postman: `postman/SalonManager-Collection.json`
