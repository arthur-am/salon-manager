# Relatório de Integração — Sprint 2

> **SalonManager** · Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas (LDAMD)
> PUC Minas — Engenharia de Software · 1º Semestre 2026
> Autor: Arthur Araújo Mendonça
> Data: 25/05/2026

---

## 1. Escolha da Ferramenta MOM: RabbitMQ

A ferramenta escolhida para o Middleware Orientado a Mensagens (MOM) foi o **RabbitMQ 3**,
operando com o protocolo **AMQP 0-9-1** (*Advanced Message Queuing Protocol*).

**Justificativas:**

- **Maturidade e confiabilidade:** RabbitMQ é um dos brokers mais utilizados em produção,
  com mais de uma década de desenvolvimento ativo e ampla adoção em sistemas distribuídos
  corporativos (Pivotal/VMware, 2024).

- **Persistência de mensagens:** suporte nativo a filas duráveis (`durable: true`) e
  mensagens persistentes (`persistent: true`), garantindo que nenhuma solicitação seja
  perdida em caso de reinicialização do broker.

- **Confirmação de entrega (ACK manual):** o modelo de acknowledgment explícito permite
  que o consumer sinalize que processou com sucesso cada mensagem antes de removê-la
  da fila, evitando perda de dados em caso de falha no processamento.

- **Management UI embutida:** a interface web em `http://localhost:15672` oferece
  visibilidade em tempo real do estado das filas, taxas de publicação/consumo e
  mensagens acumuladas — recurso essencial para evidenciar o funcionamento do MOM.

- **Suporte ao padrão Work Queue:** modelo adequado ao domínio, pois garante que cada
  mensagem (evento de reserva) seja processada exatamente uma vez (*at-most-once delivery*
  com ACK manual).

---

## 2. Padrão de Integração Utilizado

O sistema implementa o padrão **Work Queue** (também chamado *Task Queue*), descrito por
Hohpe e Woolf (2003) em *Enterprise Integration Patterns*.

Neste padrão:
- O **produtor** (Backend API) publica eventos nas filas sem conhecer os consumidores.
- O **consumidor** (Consumer Service) subscreve as filas e processa cada mensagem
  de forma independente.
- Múltiplos consumidores poderiam ser adicionados sem qualquer alteração no produtor
  (*horizontal scaling*).

Duas filas foram criadas para separar os destinos semânticos dos eventos:

| Fila | Destino semântico |
|------|-------------------|
| `fila_notificacoes_prestador` | Eventos de interesse do prestador de serviços |
| `fila_notificacoes_cliente`   | Eventos de interesse do cliente final |

Esta separação respeita o princípio do **Single Responsibility** e facilita a evolução
independente dos consumidores nas Sprints 3 e 4 (apps Flutter).

---

## 3. Decisões de Design

### 3.1 Consumer como Processo Docker Separado

O consumer foi implementado como um **serviço Docker independente** (`consumer` no
`docker-compose.yml`), distinto do serviço `backend`. Esta decisão foi deliberada para
demonstrar a **assincronicidade real** do fluxo: os dois processos compartilham apenas
o broker RabbitMQ como ponto de comunicação, sem qualquer chamada de função, importação
de módulo ou requisição HTTP entre si.

### 3.2 Reconexão Automática

Tanto o publisher quanto o consumer implementam **loops de reconexão com backoff fixo**
de 5 segundos. Isso garante resiliência a falhas transitórias do broker e evita que a
aplicação falhe em caso de inicialização fora de ordem dos containers — problema comum
em ambientes Docker onde `depends_on` não espera que o serviço esteja completamente
pronto para aceitar conexões AMQP.

### 3.3 Persistência em `event_log`

Os eventos processados pelo consumer são gravados na tabela `event_log` (PostgreSQL).
Esta decisão serve a dois propósitos:
1. **Evidência auditável** do funcionamento assíncrono — é possível consultar via
   `GET /api/event-log` quais eventos foram processados, quando e com qual payload.
2. **Base para Sprints futuras** — os apps Flutter (Sprints 3 e 4) poderão usar
   polling neste endpoint para refletir mudanças de estado sem depender de conexão
   AMQP direta.

### 3.4 Prefetch Count = 1

O consumer usa `channel.prefetch(1)`, garantindo *fair dispatch*: o broker só envia
a próxima mensagem após o consumer confirmar (`ack`) o processamento da anterior.
Isso evita que um consumer sobrecarregado acumule mensagens sem processá-las.

---

## 4. Desafios Encontrados

### 4.1 Race Condition na Inicialização

**Problema:** O RabbitMQ demora alguns segundos para aceitar conexões AMQP após o
container iniciar. O `depends_on` do Docker Compose verifica apenas se o container
está *rodando*, não se o serviço está *pronto*.

**Solução:** Implementação de `healthcheck` no `docker-compose.yml` usando
`rabbitmq-diagnostics check_port_connectivity`, combinada com `condition: service_healthy`
nos serviços dependentes. Como salvaguarda adicional, o loop de reconexão com delay
de 5 segundos garante que mesmo sem o healthcheck funcionando perfeitamente, o serviço
consegue se conectar eventualmente.

### 4.2 Mensagens Persistidas vs. Perdidas

**Problema:** Sem persistência de mensagens, eventos publicados antes do consumer estar
ativo seriam descartados.

**Solução:** Filas declaradas com `durable: true` e mensagens enviadas com
`persistent: true` garantem que o RabbitMQ persiste as mensagens em disco. O volume
Docker `rabbitmq_data` assegura que essa persistência sobrevive ao ciclo de vida do
container.

---

## 5. Evidência de Funcionamento

O fluxo pode ser verificado pela seguinte sequência:

```bash
# 1. Subir o sistema
docker-compose up --build

# 2. Criar uma reserva (backend publica evento)
curl -X POST http://localhost:3000/api/reservas \
  -H 'Content-Type: application/json' \
  -d '{"cliente_id":1,"salao_id":1,"data_reserva":"2026-06-20T19:00:00"}'

# 3. Consumer processa assincronamente — verificar logs
docker-compose logs consumer

# 4. Verificar evento persistido (sem REST direto ao consumer)
curl http://localhost:3000/api/event-log
```

Nos logs do consumer, é possível observar a mensagem sendo processada de forma
autônoma, em instante posterior à criação da reserva. O `event_log` confirma o
processamento com timestamp distinto do `created_at` da reserva.

---

## 6. Referências

- HOHPE, G.; WOOLF, B. *Enterprise Integration Patterns: designing, building, and deploying messaging solutions.* Boston: Addison-Wesley, 2003.
- RICHARDSON, C. *Microservices Patterns: with examples in Java.* Shelter Island: Manning, 2018.
- COULOURIS, G. et al. *Distributed Systems: concepts and design.* 5. ed. Boston: Addison-Wesley, 2011.
- RabbitMQ. *AMQP 0-9-1 Model Explained.* Disponível em: https://www.rabbitmq.com/tutorials/amqp-concepts. Acesso em: 25 mai. 2026.
