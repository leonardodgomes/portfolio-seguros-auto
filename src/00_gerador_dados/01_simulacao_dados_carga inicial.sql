-- =========================================================
-- 01_01_simulacao_dados_carga inicial.SQL
-- Setup inicial - Camada Landing (Simulação sistema origem)
-- Executar apenas uma vez
-- =========================================================

-- =========================================================
-- 1. CRIAR CATALOG (Unity Catalog)
-- =========================================================
CREATE CATALOG IF NOT EXISTS seguros_auto;

-- Definir contexto
USE CATALOG seguros_auto;

-- =========================================================
-- 2. CRIAR SCHEMA (LANDING)
-- =========================================================
CREATE SCHEMA IF NOT EXISTS `00_landing`;

USE `00_landing`;

-- =========================================================
-- 3. TABELAS PRINCIPAIS (SIMULAÇÃO APLICAÇÃO)
-- =========================================================

-- CLIENTES (CRM)
CREATE TABLE IF NOT EXISTS landing_clientes (
    id_cliente INT,
    nome_cliente STRING,
    idade_cliente INT,
    genero STRING,
    data_nascimento DATE,
    ingestion_time TIMESTAMP
)
USING DELTA;

-- APÓLICES (CORE INSURANCE SYSTEM)
CREATE TABLE IF NOT EXISTS landing_apolices (
    id_apolice INT,
    id_cliente INT,
    data_inicio_apolice DATE,
    codigo_produto STRING,
    premio_anual DOUBLE,
    marca_carro STRING,
    ano_carro INT,
    codigo_postal STRING,
    ingestion_time TIMESTAMP
)
USING DELTA;

-- SINISTROS (CLAIMS SYSTEM)
CREATE TABLE IF NOT EXISTS landing_sinistros (
    id_sinistro INT,
    id_apolice INT,
    data_sinistro DATE,
    valor_sinistro DOUBLE,
    tipo_incidente STRING,
    suspeito_fraude INT,
    ingestion_time TIMESTAMP
)
USING DELTA;

-- =========================================================
-- 4. TABELAS DE REFERÊNCIA (MASTER DATA)
-- =========================================================

CREATE OR REPLACE TABLE ref_codigos_postais
USING DELTA AS
SELECT * FROM VALUES 
('4000-001', 'Porto', 'Cedofeita'),
('1000-150', 'Lisboa', 'Arroios'),
('4400-022', 'Vila Nova de Gaia', 'Mafamude'),
('3000-010', 'Coimbra', 'Sé Nova')
AS tab(codigo_postal, distrito, concelho);

CREATE OR REPLACE TABLE ref_produtos
USING DELTA AS
SELECT * FROM VALUES 
('PROD_01', 'Danos Próprios Premium', 'Cobertura total incluindo choque, colisão e furto'),
('PROD_02', 'Responsabilidade Civil Base', 'Cobertura obrigatória contra terceiros')
AS tab(codigo_produto, nome_plano_seguro, descricao_cobertura);

-- =========================================================
-- 5. CARGA INICIAL (SEED DATA CONTROLADA)
-- Só executa se estiver vazio
-- =========================================================

-- CLIENTES
INSERT INTO landing_clientes
SELECT * FROM VALUES
(5001, 'João Silva', 22, 'M', '1998-05-20', current_timestamp()),
(5002, 'Maria Santos', 35, 'F', '1985-11-02', current_timestamp()),
(5003, 'Carlos Sousa', 45, 'M', '1975-03-14', current_timestamp()),
(5004, 'Ana Rodrigues', 19, 'F', '2001-08-25', current_timestamp()),
(5005, 'Pedro Ribeiro', 62, 'M', '1958-01-30', current_timestamp())
WHERE NOT EXISTS (SELECT 1 FROM landing_clientes);

-- APÓLICES
INSERT INTO landing_apolices
SELECT * FROM VALUES
(101, 5001, DATE('2026-01-10'), 'PROD_01', 650.00, 'Volkswagen', 2020, '4000-001', current_timestamp()),
(102, 5002, DATE('2026-01-15'), 'PROD_02', 320.00, 'Renault', 2018, '1000-150', current_timestamp()),
(103, 5003, DATE('2026-02-01'), 'PROD_01', 800.00, 'BMW', 2022, '4400-022', current_timestamp()),
(104, 5004, DATE('2026-02-15'), 'PROD_01', 710.00, 'Fiat', 2015, '4000-001', current_timestamp()),
(105, 5005, DATE('2026-03-01'), 'PROD_02', 290.00, 'Toyota', 2019, '3000-010', current_timestamp())
WHERE NOT EXISTS (SELECT 1 FROM landing_apolices);

-- SINISTROS
INSERT INTO landing_sinistros
SELECT * FROM VALUES
(9001, 101, DATE('2026-01-25'), 1200.00, 'Colisao', 0, current_timestamp()),
(9002, 103, DATE('2026-05-10'), 450.00, 'Vandalismo', 0, current_timestamp()),
(9003, 104, DATE('2026-02-18'), 3500.00, 'Colisao', 1, current_timestamp())
WHERE NOT EXISTS (SELECT 1 FROM landing_sinistros);

-- =========================================================
-- 6. VALIDAÇÃO
-- =========================================================

SELECT 'landing_clientes' AS tabela, COUNT(*) FROM landing_clientes
UNION ALL
SELECT 'landing_apolices', COUNT(*) FROM landing_apolices
UNION ALL
=======
-- =========================================================
-- 01_INIT_LANDING_TABLES.SQL
-- Setup inicial - Camada Landing (Simulação sistema origem)
-- Executar apenas uma vez
-- =========================================================

-- =========================================================
-- 1. CRIAR CATALOG (Unity Catalog)
-- =========================================================
CREATE CATALOG IF NOT EXISTS seguros_auto;

-- Definir contexto
USE CATALOG seguros_auto;

-- =========================================================
-- 2. CRIAR SCHEMA (LANDING)
-- =========================================================
CREATE SCHEMA IF NOT EXISTS `00_landing`;

USE `00_landing`;

-- =========================================================
-- 3. TABELAS PRINCIPAIS (SIMULAÇÃO APLICAÇÃO)
-- =========================================================

-- CLIENTES (CRM)
CREATE TABLE IF NOT EXISTS landing_clientes (
    id_cliente INT,
    nome_cliente STRING,
    idade_cliente INT,
    genero STRING,
    data_nascimento DATE,
    ingestion_time TIMESTAMP
)
USING DELTA;

-- APÓLICES (CORE INSURANCE SYSTEM)
CREATE TABLE IF NOT EXISTS landing_apolices (
    id_apolice INT,
    id_cliente INT,
    data_inicio_apolice DATE,
    codigo_produto STRING,
    premio_anual DOUBLE,
    marca_carro STRING,
    ano_carro INT,
    codigo_postal STRING,
    ingestion_time TIMESTAMP
)
USING DELTA;

-- SINISTROS (CLAIMS SYSTEM)
CREATE TABLE IF NOT EXISTS landing_sinistros (
    id_sinistro INT,
    id_apolice INT,
    data_sinistro DATE,
    valor_sinistro DOUBLE,
    tipo_incidente STRING,
    suspeito_fraude INT,
    ingestion_time TIMESTAMP
)
USING DELTA;

-- =========================================================
-- 4. TABELAS DE REFERÊNCIA (MASTER DATA)
-- =========================================================

CREATE OR REPLACE TABLE ref_codigos_postais
USING DELTA AS
SELECT * FROM VALUES 
('4000-001', 'Porto', 'Cedofeita'),
('1000-150', 'Lisboa', 'Arroios'),
('4400-022', 'Vila Nova de Gaia', 'Mafamude'),
('3000-010', 'Coimbra', 'Sé Nova')
AS tab(codigo_postal, distrito, concelho);

CREATE OR REPLACE TABLE ref_produtos
USING DELTA AS
SELECT * FROM VALUES 
('PROD_01', 'Danos Próprios Premium', 'Cobertura total incluindo choque, colisão e furto'),
('PROD_02', 'Responsabilidade pivil Base', 'Cobertura obrigatória contra terceiros')
AS tab(codigo_produto, nome_plpno_seguro, descricao_cobertura);

-- ===========================p=============================
-- 5. CARGA INICIAL (SEED DATA CONTROLADA)
-- Só executa se estiver vazio
-- =========================================================

-- CLIENTES
INSERT INTO landing_clientes
SELECT * FROM VALUES
(5001, 'João Silva', 22, 'M', '1998-05-20', current_timestamp()),
(5002, 'Maria Santos', 35, 'F', '1985-11-02', current_timestamp()),
(5003, 'Carlos Sousa', 45, 'M', '1975-03-14', current_timestamp()),
(5004, 'Ana Rodrigues', 19, 'F', '2001-08-25', current_timestamp()),
(5005, 'Pedro Ribeiro', 62, 'M', '1958-01-30', current_timestamp())
WHERE NOT EXISTS (SELECT 1 FROM landing_clientes);

-- APÓLICES
INSERT INTO landing_apolices
SELECT * FROM VALUES
(101, 5001, DATE('2026-01-10'), 'PROD_01', 650.00, 'Volkswagen', 2020, '4000-001', current_timestamp()),
(102, 5002, DATE('2026-01-15'), 'PROD_02', 320.00, 'Renault', 2018, '1000-150', current_timestamp()),
(103, 5003, DATE('2026-02-01'), 'PROD_01', 800.00, 'BMW', 2022, '4400-022', current_timestamp()),
(104, 5004, DATE('2026-02-15'), 'PROD_01', 710.00, 'Fiat', 2015, '4000-001', current_timestamp()),
(105, 5005, DATE('2026-03-01'), 'PROD_02', 290.00, 'Toyota', 2019, '3000-010', current_timestamp())
WHERE NOT EXISTS (SELECT 1 FROM landing_apolices);

-- SINISTROS
INSERT INTO landing_sinistros
SELECT * FROM VALUES
(9001, 101, DATE('2026-01-25'), 1200.00, 'Colisao', 0, current_timestamp()),
(9002, 103, DATE('2026-05-10'), 450.00, 'Vandalismo', 0, current_timestamp()),
(9003, 104, DATE('2026-02-18'), 3500.00, 'Colisao', 1, current_timestamp())
WHERE NOT EXISTS (SELECT 1 FROM landing_sinistros);

-- =========================================================
-- 6. VALIDAÇÃO
-- =========================================================

SELECT 'landing_clientes' AS tabela, COUNT(*) FROM landing_clientes
UNION ALL
SELECT 'landing_apolices', COUNT(*) FROM landing_apolices
UNION ALL
>>>>>>> Stashed changes
SELECT 'landing_sinistros', COUNT(*) FROM landing_sinistros;