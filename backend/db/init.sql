-- ============================================================
-- Schema do SalonManager — atualizado na Sprint 2
-- ============================================================

-- ── Tabela: saloes ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS saloes (
  id         serial       PRIMARY KEY,
  nome       varchar(255) NOT NULL,
  endereco   varchar(500),
  capacidade integer,
  descricao  text
);

-- ── Tabela: clientes ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clientes (
  id       serial       PRIMARY KEY,
  nome     varchar(255) NOT NULL,
  email    varchar(255),
  telefone varchar(50)
);

-- ── Tabela: reservas ────────────────────────────────────────
-- Ciclo de vida do status: PENDENTE → CONFIRMADA / RECUSADA → CONCLUIDA
CREATE TABLE IF NOT EXISTS reservas (
  id           serial      PRIMARY KEY,
  cliente_id   integer     REFERENCES clientes(id) ON DELETE SET NULL,
  salao_id     integer     REFERENCES saloes(id)   ON DELETE SET NULL,
  data_reserva timestamp   NOT NULL,
  status       varchar(50) NOT NULL DEFAULT 'PENDENTE',
  created_at   timestamp   NOT NULL DEFAULT now()
);

-- ── Tabela: event_log (Sprint 2) ────────────────────────────
-- Persistência dos eventos processados pelo consumer RabbitMQ.
-- Evidencia a comunicação assíncrona sem chamada REST direta.
CREATE TABLE IF NOT EXISTS event_log (
  id            serial      PRIMARY KEY,
  tipo          varchar(100) NOT NULL,
  fila          varchar(255) NOT NULL,
  payload       jsonb        NOT NULL,
  processado_em timestamp    NOT NULL DEFAULT now()
);

-- Índice para filtros por tipo e por fila
CREATE INDEX IF NOT EXISTS idx_event_log_tipo ON event_log (tipo);
CREATE INDEX IF NOT EXISTS idx_event_log_fila ON event_log (fila);

-- ── Seeds de exemplo ────────────────────────────────────────
INSERT INTO saloes (nome, endereco, capacidade, descricao) VALUES
  ('Salão Imperial', 'Av. A, 123', 120, 'Salão amplo com palco e iluminação'),
  ('Espaço Gala',   'Rua B, 45',   80, 'Ideal para festas e eventos sociais')
ON CONFLICT DO NOTHING;

INSERT INTO clientes (nome, email, telefone) VALUES
  ('João Silva', 'joao@example.com', '+55 31 99999-0000')
ON CONFLICT DO NOTHING;
