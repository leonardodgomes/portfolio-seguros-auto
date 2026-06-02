-- 1. Garante que a tabela destino existe com a estrutura correta
CREATE TABLE IF NOT EXISTS seguros_auto.`01_bronze`.bronze_apolices (
    id_apolice INT,
    id_cliente INT,
    data_inicio_apolice DATE,
    premio_anual FLOAT,
    marca_carro STRING,
    ano_carro INT,
    codigo_postal STRING,
    data_ingestao_bronze TIMESTAMP
) USING DELTA;
	
-- 2. Ingestão explícita mapeando coluna por coluna
INSERT INTO seguros_auto.`01_bronze`.bronze_apolices
SELECT
    id_apolice,
    id_cliente,
    data_inicio_apolice,
    premio_anual,
    marca_carro,
    ano_carro,
    codigo_postal,
    CURRENT_TIMESTAMP() AS data_ingestao_bronze -- Aqui gera a data controlada pela Bronze
FROM seguros_auto.`00_landing`.landing_apolices;

	id_cliente	data_inicio_apolice	codigo_produto	premio_anual	marca_carro	ano_carro	codigo_postal	ingestion_time