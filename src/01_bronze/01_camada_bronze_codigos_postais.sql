-- 1. Garante que a tabela destino existe com a estrutura correta
CREATE TABLE IF NOT EXISTS seguros_auto.`01_bronze`.bronze_apolices (
    id_cliente INT,
    nome_cliente STRING,
    idade_cliente INT,
    genero STRING,
    data_nascimento DATE,
    data_ingestao_bronze TIMESTAMP
) USING DELTA;

-- 2. Ingestão explícita mapeando coluna por coluna
INSERT INTO seguros_auto.`01_bronze`.bronze_apolices
SELECT 
    id_cliente,
    nome_cliente,
    idade_cliente,
    genero,
    data_nascimento,
    CURRENT_TIMESTAMP() AS data_ingestao_bronze -- Aqui gera a data controlada pela Bronze
FROM seguros_auto.`00_landing`.landing_apolices;
