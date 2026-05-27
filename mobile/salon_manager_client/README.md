# SALON.OS Cliente

App Flutter do cliente para a Sprint 3 do SalonManager.

## Funcionalidades

- Lista saloes disponiveis pelo backend REST.
- Abre detalhes de um salao.
- Cria cliente e reserva em um fluxo unico.
- Permite aceitar, recusar e concluir reservas no modo Prestador.
- Atualiza reservas e event log automaticamente por polling.
- Mostra painel de sistema com API, PostgreSQL, RabbitMQ, event log e diagrama animado clicavel.

## Executar

Com o backend ativo:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

Android emulator:

```bash
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Build APK debug:

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Organizacao

```text
lib/src
  app/            providers e root app
  core/           api client, tema, widgets e utilitarios
  features/
    client/       entidade e repositorio de cliente
    saloes/       listagem e detalhe dos saloes
    reservas/     reserva, event log e polling assincrono
    system/       health, observabilidade e diagrama
```
