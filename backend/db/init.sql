-- Inicialização do esquema para Sprint 1
CREATE TABLE IF NOT EXISTS saloes (
  id serial PRIMARY KEY,
  nome varchar(255) NOT NULL,
  endereco varchar(500),
  capacidade integer,
  descricao text
);

CREATE TABLE IF NOT EXISTS clientes (
  id serial PRIMARY KEY,
  nome varchar(255) NOT NULL,
  email varchar(255),
  telefone varchar(50)
);

CREATE TABLE IF NOT EXISTS reservas (
  id serial PRIMARY KEY,
  cliente_id integer REFERENCES clientes(id) ON DELETE SET NULL,
  salao_id integer REFERENCES saloes(id) ON DELETE SET NULL,
  data_reserva timestamp NOT NULL,
  status varchar(50) NOT NULL DEFAULT 'PENDENTE',
  created_at timestamp NOT NULL DEFAULT now()
);

-- Seeds de exemplo
INSERT INTO saloes (nome, endereco, capacidade, descricao) VALUES
('Salão Imperial', 'Av. A, 123', 120, 'Salão amplo com palco e iluminação'),
('Espaço Gala', 'Rua B, 45', 80, 'Ideal para festas e eventos sociais');

INSERT INTO clientes (nome, email, telefone) VALUES
('João Silva', 'joao@example.com', '+55 31 99999-0000');
