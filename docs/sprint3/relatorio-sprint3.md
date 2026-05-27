# Sprint 3 - Relatorio de Entrega

## Resumo

A Sprint 3 entrega o app Flutter do cliente do SalonManager. O app permite listar saloes, visualizar detalhes, criar uma reserva e acompanhar reservas/eventos com atualizacao assincrona. A implementacao usa o backend REST existente e reaproveita a arquitetura orientada a eventos da Sprint 2.

## Criterios de avaliacao

| Criterio | Evidencia implementada |
|---|---|
| Funcionalidade do app | Fluxo executavel: listar saloes, abrir detalhes, criar cliente, criar reserva e acompanhar status. |
| Integracao REST | Consumo de `/api/saloes`, `/api/saloes/:id`, `/api/clientes`, `/api/reservas`, `/api/event-log` e `/api/system/status`. |
| Atualizacao assincrona | Polling automatico a cada 6 segundos em reservas e event log. |
| Clean Architecture | Separacao em `core`, `data`, `domain` e `presentation`, com contratos de repositorio e casos de uso. |
| Interface | Material 3, navegacao por abas, formularios validados, cards de status e tela visual de arquitetura distribuida. |

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
- O app mantem o backend Express, PostgreSQL e RabbitMQ ja entregues na Sprint 2.

## Preparacao para Sprint 4

A base criada permite adicionar o app do prestador com baixo acoplamento. O proximo incremento pode reaproveitar `Reserva`, `EventLog`, `ApiClient`, tema visual e parte dos controllers, adicionando telas de solicitacoes pendentes, aceite/recusa e atualizacao de status.
