# Sprint 3 - Relatorio de Entrega

## Resumo

A Sprint 3 entrega o app Flutter do cliente do SalonManager. O app permite listar saloes, visualizar detalhes, criar uma reserva e acompanhar reservas/eventos com atualizacao assincrona. A implementacao usa o backend REST existente e reaproveita a arquitetura orientada a eventos da Sprint 2.

## Criterios de avaliacao

| Criterio | Evidencia implementada |
|---|---|
| Funcionalidade do app | Fluxo executavel: listar saloes, abrir detalhes, criar cliente, criar reserva, aceitar/recusar/concluir como prestador e acompanhar status. |
| Integracao REST | Consumo de `/api/saloes`, `/api/saloes/:id`, `/api/clientes`, `/api/reservas`, `/api/event-log` e `/api/system/status`. |
| Atualizacao assincrona | Atualizacao automatica em reservas e event log, com mudanca de status refletida sem acao manual do usuario. |
| Clean Architecture | Separacao em `core`, `data`, `domain` e `presentation`, com contratos de repositorio e casos de uso. |
| Interface | Material 3, navegacao por abas, formularios validados, cards de status, modo prestador e tela visual de arquitetura distribuida com explicacoes clicaveis. |

## Como demonstrar

1. Subir os servicos do backend:

```bash
docker compose up --build
```

2. Executar o app no navegador:

```bash
cd mobile/salon_manager_client
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

3. Executar no emulador Android:

```bash
cd mobile/salon_manager_client
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

4. Gerar APK debug:

```bash
cd mobile/salon_manager_client
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Decisoes tecnicas

- Riverpod foi usado para estado reativo e polling periodico.
- `ApiClient` centraliza REST, timeout, retry e serializacao JSON.
- O fluxo de criacao de reserva cria o cliente antes da reserva para evitar depender do seed do banco.
- A tela Sistema consome health detalhado do backend e mostra arquitetura distribuida animada.
- A tela Reservas inclui um modo Prestador para demonstrar aceite, recusa e conclusao de reservas dentro do proprio app.
- Termos tecnicos foram concentrados na tela Sistema para preservar clareza nas telas de uso.
- A tela Sistema documenta a evolucao proposta com Transactional Outbox Pattern, publisher-service desacoplado, idempotencia e Dead Letter Queue.
- O app mantem o backend Express, PostgreSQL e RabbitMQ ja entregues na Sprint 2.

## Resiliencia e escalabilidade

A arquitetura executavel desta sprint usa backend REST publicando eventos no RabbitMQ e consumer separado registrando `event_log`. Para mostrar maturidade em sistemas distribuidos, a entrega tambem documenta a evolucao recomendada com **Transactional Outbox Pattern**.

Com Outbox, o backend gravaria a reserva e o evento pendente em `outbox_events` na mesma transacao do PostgreSQL. Um `publisher-service` separado publicaria esses eventos no RabbitMQ. Isso reduz o risco de a reserva ser salva e o evento se perder caso o broker esteja indisponivel no momento da requisicao.

Pontos de falha unica reconhecidos:

- PostgreSQL pode virar gargalo ou ponto unico de falha;
- RabbitMQ pode virar ponto unico de falha;
- backend unico pode cair;
- publisher unico pode atrasar eventos;
- consumer unico pode atrasar processamento.

Mitigacoes propostas:

- backend com multiplas replicas atras de load balancer;
- publisher com multiplas replicas usando `SELECT ... FOR UPDATE SKIP LOCKED`;
- consumer com multiplas replicas consumindo Work Queue;
- RabbitMQ com cluster ou quorum queues;
- PostgreSQL com backup, replica de leitura ou servico gerenciado;
- eventos com `event_id` unico para idempotencia;
- Dead Letter Queue para mensagens que falham repetidamente.

## Preparacao para Sprint 4

A base criada permite adicionar o app do prestador com baixo acoplamento. O proximo incremento pode reaproveitar `Reserva`, `EventLog`, `ApiClient`, tema visual e parte dos controllers, adicionando telas de solicitacoes pendentes, aceite/recusa e atualizacao de status.
