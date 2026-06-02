# Pipeline de Engenharia de Dados para Seguros Automóveis
> **Stack Tecnológica:** Databricks (Spark SQL), Databricks Workflows, Git Folders e Power BI.

Este projeto de portefólio simula um ambiente real de produção numa seguradora automóvel. O objetivo principal é construir um ecossistema de Lakehouse utilizando a **Arquitetura Medalhão** para processar dados de apólices, sinistros e tabelas auxiliares de suporte ao negócio. O foco final é fornecer dados limpos e agregados para um Dashboard de monitorização do **Loss Ratio (Rácio de Sinistralidade)** e **Deteção de Fraude**.

---

## Fluxo e Arquitetura do Pipeline

O pipeline está totalmente isolado num catálogo exclusivo via Unity Catalog (`seguros_auto`) e orquestrado através do **Databricks Workflows**, garantindo a execução ordenada e o isolamento de falhas:

1. **Ingestão (Camada Bronze):** Carga paralela e isolada das tabelas transacionais e cadastrais brutas (`bronze.clientes`, `bronze.apolices`, `bronze.sinistros`) e tabelas de suporte (`bronze.codigos_postais`, `bronze.planos_produtos`).
2. **Transformação (Camada Prata):** Um ficheiro unificado consome as fontes da Bronze, executa limpezas de nulos, tratamento de integridade e cruza com os dados externos através de `LEFT JOIN`. O resultado é persistido em `silver.prata_dados_seguros`.
3. **Agregação (Camada Ouro):** Leitura da base Prata para a criação de visões agregadas e otimizadas para consumo do Power BI (`gold.ouro_analise_risco` e `gold.ouro_alertas_fraude`).

---

## Estrutura de Pastas do Repositório (Git)

O projeto está organizado seguindo as melhores práticas de controlo de versão via **Databricks Git Folders**:

```text
📁 portfolio-seguros-databricks-pbi
│
├── 📁 src
│   ├── 📁 00_gerador_dados
│   │   ├── 01_simulacao_dados_carga_inicial.sql   <- Script isolado para testes manuais
│   │   └── 01_simulacao_dados_incremental.sql     <- Injeção de novos dados para validação
│   │
│   ├── 📁 01_bronze                               <- Scripts de Ingestão e Criação Raw
│   │   ├── 02_ingestao_bronze_clientes.sql
│   │   ├── 03_ingestao_bronze_apolices.sql
│   │   ├── 04_ingestao_bronze_sinistros.sql
│   │   ├── 05_ingestao_bronze_codigos_postais.sql
│   │   └── 06_ingestao_bronze_planos_produtos.sql
│   │
│   ├── 📁 02_silver
│   │   └── 07_transformacao_prata_principal.sql   <- Limpeza e enriquecimento unificado
│   │
│   └── 📁 03_gold                                 <- Agregações finais de Negócio
│       ├── 08_agregacao_ouro_risco.sql
│       └── 09_agregacao_ouro_fraude.sql
│
├── 📁 powerbi
│   ├── dashboard_seguros.pbix                     <- Template do relatório final
│   └── dax_measures.txt                           <- Central de fórmulas DAX
│
├── 📁 docs
│   ├── dicionario_dados.md                        <- Metadados e regras de negócio
│   └── screenshot_workflow.png                    <- Print screen do DAG do Databricks Workflow
│
└── README.md                                      <- Documentação principal
```

---

##  Regras de Negócio e Engenharia Aplicadas

### 1. Governança e Performance (Camada Prata Única)
* Mantemos as transformações diretas da entidade principal num **único ficheiro SQL** na camada Prata.
* Utilizamos **CTEs (`WITH`)** para que o processamento ocorra inteiramente em memória (*Lazy Evaluation* do Spark), evitando operações dispendiosas de I/O (escrita/leitura em disco) entre pequenos passos de limpeza.
* Tabelas de suporte externas (como Códigos Postais e Descrição de Planos) possuem ficheiros de ingestão isolados e são integradas à tabela principal via `LEFT JOIN` na etapa final da Prata.

### 2. Idempotência Garantida
* O pipeline foi desenhado para ser executado de forma contínua e agendada (ex: diariamente).
* Para evitar a duplicação de dados, o comando `MERGE INTO` é utilizado na camada Prata e Ouro, atualizando registos existentes (*updates*) e inserindo apenas os novos (*inserts*).

### 3. Regras de Negócio Analíticas
* **Faixas Etárias:** Divisão automática de clientes em subgrupos para deteção de perfis de alto risco.
* **Idade do Veículo:** Calculada dinamicamente a partir do ano de fabrico.
* **Alerta de Fraude Precoce:** Regra Spark SQL que sinaliza com flag `1` qualquer sinistro que ocorra num intervalo inferior ou igual a 30 dias após a ativação da apólice.

---

## Dicionário de Dados Base (`prata_dados_seguros`)


| Nome do Campo | Tipo | Descrição / Regra | Exemplo |
| :--- | :--- | :--- | :--- |
| `id_apolice` | INT | Chave primária do contrato de seguro. | `100234` |
| `idade_cliente` | INT | Idade do condutor (Filtro de limpeza: $\ge 18$). | `22` |
| `faixa_etaria` | STRING | Grupos: '18-24 (Jovem)', '25-50 (Adulto)', '50+ (Sénior)'. | `18-24 (Jovem)` |
| `distrito` | STRING | Enriquecido via tabela externa de Códigos Postais. | `Porto` |
| `nome_plano_seguro` | STRING | Enriquecido via tabela externa de Produtos. | `Danos Próprios Premium` |
| `premio_anual` | DOUBLE | Valor pago pelo cliente à seguradora. | `520.00` |
| `valor_sinistro` | DOUBLE | Custo do acidente para a seguradora (0 se não houver). | `1450.00` |
| `alerta_sinistro_precoce` | INT | Flag (1 ou 0). Ativado se o sinistro ocorrer nos primeiros 30 dias. | `1` |

---