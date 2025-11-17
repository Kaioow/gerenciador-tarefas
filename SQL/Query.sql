/* ============================================================
   1) CRIAÇÃO DO BANCO
   ============================================================ */

CREATE DATABASE IF NOT EXISTS gerenciador_tarefas_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE gerenciador_tarefas_db;


/* ============================================================
   2) TABELAS PRINCIPAIS
   ============================================================ */

-- 2.1) GRUPOS DE USUÁRIOS (OBRIGATÓRIA)
CREATE TABLE IF NOT EXISTS grupos_usuarios (
  id_grupo VARCHAR(10) PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  descricao VARCHAR(255)
) ENGINE=InnoDB;

-- 2.2) USUÁRIOS (OBRIGATÓRIA)
CREATE TABLE IF NOT EXISTS usuarios (
  id_usuario VARCHAR(20) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  senha_hash VARCHAR(255) NOT NULL,
  id_grupo VARCHAR(10) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_usuarios_grupos
    FOREIGN KEY (id_grupo) REFERENCES grupos_usuarios(id_grupo)
) ENGINE=InnoDB;

-- 2.3) LISTAS DE TAREFAS (tipo "quadro" ou "projeto")
CREATE TABLE IF NOT EXISTS listas_tarefas (
  id_lista VARCHAR(20) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(255),
  id_usuario_dono VARCHAR(20) NOT NULL,
  CONSTRAINT fk_listas_usuarios
    FOREIGN KEY (id_usuario_dono) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- 2.4) TAREFAS
CREATE TABLE IF NOT EXISTS tarefas (
  id_tarefa VARCHAR(20) PRIMARY KEY,
  titulo VARCHAR(150) NOT NULL,
  descricao TEXT,
  status VARCHAR(20) NOT NULL,     -- PENDENTE, EM_ANDAMENTO, CONCLUIDA
  prioridade VARCHAR(20),          -- BAIXA, MEDIA, ALTA
  data_criacao DATETIME NOT NULL,
  data_limite DATE,
  id_lista VARCHAR(20) NOT NULL,
  id_usuario_responsavel VARCHAR(20),
  CONSTRAINT fk_tarefas_listas
    FOREIGN KEY (id_lista) REFERENCES listas_tarefas(id_lista),
  CONSTRAINT fk_tarefas_usuarios
    FOREIGN KEY (id_usuario_responsavel) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- 2.5) LOG DE STATUS DE TAREFA (usado pela trigger)
CREATE TABLE IF NOT EXISTS log_status_tarefa (
  id_log INT PRIMARY KEY AUTO_INCREMENT,
  id_tarefa VARCHAR(20) NOT NULL,
  status_anterior VARCHAR(20),
  status_novo VARCHAR(20),
  data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


/* ============================================================
   3) TABELAS DE SEQUÊNCIA (PARA GERAR IDs SEM AUTO_INCREMENT)
   ============================================================ */

-- SEQUÊNCIA PARA USUÁRIOS
CREATE TABLE IF NOT EXISTS seq_usuario (
  ano INT PRIMARY KEY,
  ultimo_numero INT NOT NULL
) ENGINE=InnoDB;

-- SEQUÊNCIA PARA TAREFAS
CREATE TABLE IF NOT EXISTS seq_tarefa (
  ano INT PRIMARY KEY,
  ultimo_numero INT NOT NULL
) ENGINE=InnoDB;


/* ============================================================
   4) FUNCTIONS PARA GERAR IDs
   ============================================================ */

DELIMITER $$

-- 4.1) FUNÇÃO PARA GERAR ID DE USUÁRIO
DROP FUNCTION IF EXISTS fn_gerar_id_usuario $$
CREATE FUNCTION fn_gerar_id_usuario()
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
  DECLARE v_ano INT;
  DECLARE v_seq INT;

  SET v_ano = YEAR(CURDATE());

  INSERT INTO seq_usuario (ano, ultimo_numero)
  VALUES (v_ano, 1)
  ON DUPLICATE KEY UPDATE ultimo_numero = ultimo_numero + 1;

  SELECT ultimo_numero INTO v_seq
  FROM seq_usuario
  WHERE ano = v_ano;

  RETURN CONCAT('USR', v_ano, LPAD(v_seq, 5, '0'));
END $$


-- 4.2) FUNÇÃO PARA GERAR ID DE TAREFA
DROP FUNCTION IF EXISTS fn_gerar_id_tarefa $$
CREATE FUNCTION fn_gerar_id_tarefa()
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
  DECLARE v_ano INT;
  DECLARE v_seq INT;

  SET v_ano = YEAR(CURDATE());

  INSERT INTO seq_tarefa (ano, ultimo_numero)
  VALUES (v_ano, 1)
  ON DUPLICATE KEY UPDATE ultimo_numero = ultimo_numero + 1;

  SELECT ultimo_numero INTO v_seq
  FROM seq_tarefa
  WHERE ano = v_ano;

  RETURN CONCAT('TAR', v_ano, LPAD(v_seq, 5, '0'));
END $$

DELIMITER ;


/* ============================================================
   5) PROCEDURES
   ============================================================ */

DELIMITER $$

-- 5.1) PROCEDURE PARA CRIAR USUÁRIO
DROP PROCEDURE IF EXISTS sp_criar_usuario $$
CREATE PROCEDURE sp_criar_usuario (
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(100),
  IN p_senha_hash VARCHAR(255),
  IN p_id_grupo VARCHAR(10)
)
BEGIN
  INSERT INTO usuarios (
    id_usuario, nome, email, senha_hash, id_grupo, ativo
  ) VALUES (
    fn_gerar_id_usuario(),
    p_nome,
    p_email,
    p_senha_hash,
    p_id_grupo,
    1
  );
END $$


-- 5.2) PROCEDURE PARA CRIAR TAREFA
DROP PROCEDURE IF EXISTS sp_criar_tarefa $$
CREATE PROCEDURE sp_criar_tarefa (
  IN p_titulo VARCHAR(150),
  IN p_descricao TEXT,
  IN p_prioridade VARCHAR(20),
  IN p_data_limite DATE,
  IN p_id_lista VARCHAR(20),
  IN p_id_usuario_responsavel VARCHAR(20)
)
BEGIN
  INSERT INTO tarefas (
    id_tarefa,
    titulo,
    descricao,
    status,
    prioridade,
    data_criacao,
    data_limite,
    id_lista,
    id_usuario_responsavel
  ) VALUES (
    fn_gerar_id_tarefa(),
    p_titulo,
    p_descricao,
    'PENDENTE',
    p_prioridade,
    NOW(),
    p_data_limite,
    p_id_lista,
    p_id_usuario_responsavel
  );
END $$

DELIMITER ;


/* ============================================================
   6) TRIGGERS
   ============================================================ */

DELIMITER $$

-- 6.1) TRIGGER: AJUSTA CAMPOS PADRÃO AO INSERIR TAREFA
DROP TRIGGER IF EXISTS trg_tarefa_before_insert $$
CREATE TRIGGER trg_tarefa_before_insert
BEFORE INSERT ON tarefas
FOR EACH ROW
BEGIN
  IF NEW.status IS NULL OR NEW.status = '' THEN
    SET NEW.status = 'PENDENTE';
  END IF;

  IF NEW.data_criacao IS NULL THEN
    SET NEW.data_criacao = NOW();
  END IF;

  -- Se não vier prazo, define 7 dias à frente como default
  IF NEW.data_limite IS NULL THEN
    SET NEW.data_limite = DATE_ADD(CURDATE(), INTERVAL 7 DAY);
  END IF;
END $$


-- 6.2) TRIGGER: LOGA MUDANÇA DE STATUS DE TAREFA
DROP TRIGGER IF EXISTS trg_tarefa_status_update $$
CREATE TRIGGER trg_tarefa_status_update
AFTER UPDATE ON tarefas
FOR EACH ROW
BEGIN
  IF NEW.status <> OLD.status THEN
    INSERT INTO log_status_tarefa (id_tarefa, status_anterior, status_novo)
    VALUES (OLD.id_tarefa, OLD.status, NEW.status);
  END IF;
END $$

DELIMITER ;


/* ============================================================
   7) VIEWS
   ============================================================ */

-- 7.1) VIEW: TAREFAS ATIVAS (NÃO CONCLUÍDAS)
DROP VIEW IF EXISTS vw_tarefas_ativas;
CREATE VIEW vw_tarefas_ativas AS
SELECT
  t.id_tarefa,
  t.titulo,
  t.status,
  t.prioridade,
  t.data_criacao,
  t.data_limite,
  l.nome AS nome_lista,
  u.nome AS responsavel
FROM tarefas t
JOIN listas_tarefas l ON l.id_lista = t.id_lista
LEFT JOIN usuarios u ON u.id_usuario = t.id_usuario_responsavel
WHERE t.status <> 'CONCLUIDA';

-- 7.2) VIEW: RESUMO DE TAREFAS POR STATUS
DROP VIEW IF EXISTS vw_resumo_tarefas_por_status;
CREATE VIEW vw_resumo_tarefas_por_status AS
SELECT
  status,
  COUNT(*) AS quantidade
FROM tarefas
GROUP BY status;


/* ============================================================
   8) ÍNDICES
   ============================================================ */

-- Índice para buscar tarefas por lista e status
CREATE INDEX idx_tarefas_lista_status
  ON tarefas (id_lista, status);

-- Índice para buscar tarefas por responsável
CREATE INDEX idx_tarefas_responsavel
  ON tarefas (id_usuario_responsavel);


/* ============================================================
   9) USUÁRIOS DO BANCO E PERMISSÕES
   (NÃO CONFUNDIR COM A TABELA "usuarios")
   ============================================================ */

-- OBS: ajuste o host ('%') para 'localhost' se quiser restringir.
-- E troque as senhas por valores fortes no seu ambiente.

-- Apaga usuários se já existirem (evita erro em recriação)
DROP USER IF EXISTS 'app_admin'@'%';
DROP USER IF EXISTS 'app_user'@'%';

CREATE USER 'app_admin'@'%' IDENTIFIED BY 'SenhaForteAdmin123!';
CREATE USER 'app_user'@'%' IDENTIFIED BY 'SenhaForteUser123!';

-- ADMIN DA APLICAÇÃO: pode tudo no schema
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON gerenciador_tarefas_db.*
TO 'app_admin'@'%';

-- USUÁRIO NORMAL DA APLICAÇÃO:
-- pode ler e manipular tarefas e listas, mas não mexe em seq_*, triggers etc.
GRANT SELECT, INSERT, UPDATE, DELETE
ON gerenciador_tarefas_db.tarefas
TO 'app_user'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE
ON gerenciador_tarefas_db.listas_tarefas
TO 'app_user'@'%';

GRANT SELECT
ON gerenciador_tarefas_db.usuarios
TO 'app_user'@'%';

GRANT SELECT
ON gerenciador_tarefas_db.grupos_usuarios
TO 'app_user'@'%';

GRANT SELECT
ON gerenciador_tarefas_db.vw_tarefas_ativas
TO 'app_user'@'%';

GRANT SELECT
ON gerenciador_tarefas_db.vw_resumo_tarefas_por_status
TO 'app_user'@'%';

FLUSH PRIVILEGES;


/* ============================================================
   10) DADOS INICIAIS (OPCIONAIS, MAS ÚTEIS PARA TESTE)
   ============================================================ */

-- GRUPOS DE USUÁRIOS
INSERT INTO grupos_usuarios (id_grupo, nome, descricao) VALUES
  ('ADMIN', 'Administrador', 'Usuário com acesso total ao sistema'),
  ('USER',  'Usuário', 'Usuário padrão do sistema')
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

-- EXEMPLO DE USUÁRIO ADMIN (ajuste senha_hash depois)
-- senha_hash aqui é só texto de exemplo.
CALL sp_criar_usuario(
  'Administrador do Sistema',
  'admin@sistema.com',
  'SENHA_HASH_AQUI',   -- troque pelo hash gerado na aplicação
  'ADMIN'
);



