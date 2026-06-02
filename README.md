# Pipeline de Engenharia de Dados para Seguros Automóveis
> **Stack Tecnológica:** Databricks (Spark SQL), Databricks Workflows, Git Folders e Power BI.

Este projeto de portefólio simula um ambiente real de produção numa seguradora automóvel. O objetivo principal é construir um ecossistema de Lakehouse utilizando a **Arquitetura Medalhão** para processar dados de apólices, sinistros e tabelas auxiliares de suporte ao negócio. O foco final é fornecer dados limpos e agregados para um Dashboard de monitorização do **Loss Ratio (Rácio de Sinistralidade)** e **Deteção de Fraude**.

---

## Arquitetura do Pipeline & Linhagem

O pipeline está totalmente orquestrado através do **Databricks Workflows**, garantindo a execução ordenada e o isolamento de falhas por tarefa.

```mermaid
graph TD
    %% Fontes de Dados (Camada de Ingestão)
    subgraph 📥 Fontes de Dados (Simulação Raw)
        A[Ficheiro Transacional: Apólices]
        B[Ficheiro Transacional: Sinistros]
        C[Tabela Auxiliar: Códigos Postais]
        D[Tabela Auxiliar: Coberturas e Planos]
    end

    %% Camada Bronze
    subgraph 🥉 Databricks - Camada Bronze
        E[(bronze_apolices)]
        F[(bronze_sinistros)]
        G[(bronze_codigos_postais)]
        H[(bronze_planos_produtos)]
    end

    %% Camada Prata
    subgraph 🥈 Databricks - Camada Prata
        I[(prata_dados_seguros)]
    end

    %% Camada Ouro
    subgraph 🥇 Databricks - Camada Ouro
        J[(ouro_analise_risco)]
        K[(ouro_alertas_fraude)]
    end

    %% Visualização
    subgraph 📊 Power BI
        L[Dashboard de Negócio]
    end

    %% Fluxo de Dependências
    A --> E
    B --> F
    C --> G
    D --> H

    E --> I
    F --> I
    G --> I
    H --> I

    I --> J
    I --> K

    J --> L
    K --> L

    %% Estilos Visuais
    style E fill:#cd7f32,stroke:#333,stroke-width:1px,color:#fff
    style F fill:#cd7f32,stroke:#333,stroke-width:1px,color:#fff
    style G fill:#cd7f32,stroke:#333,stroke-width:1px,color:#fff
    style H fill:#cd7f32,stroke:#333,stroke-width:1px,color:#fff
    style I fill:#c0c0c0,stroke:#333,stroke-width:1px,color:#000
    style J fill:#ffd700,stroke:#333,stroke-width:1px,color:#000
    style K fill:#ffd700,stroke:#333,stroke-width:1px,color:#000
    style L fill:#f1c40f,stroke:#333,stroke-width:2px,color:#000
```

---

## 📁 Estrutura de Pastas do Repositório (Git)

O projeto está organizado seguindo as melhores práticas de controlo de versão via **Databricks Git Folders**:

```text
📁 portfolio-seguros-databricks-pbi
│
├── 📁 notebooks
│   ├── 01_simulacao_gerador_dados.sql  <- Notebook utilitário para gerar dados fictícios
│   │
│   ├── 📁 bronze
│   │   ├── 02_ingestao_bronze_apolices.sql
│   │   ├── 03_ingestao_bronze_sinistros.sql
│   │   ├── 04_ingestao_bronze_codigos_postais.sql
│   │   └── 05_ingestao_bronze_planos_produtos.sql
│   │
│   ├── 📁 silver
│   │   └── 06_transformacao_prata_principal.sql <- Ficheiro único de limpeza e enriquecimento
│   │
│   └── 📁 gold
│       ├── 07_agregacao_ouro_risco.sql         <- Cubo de dados para Rácio de Sinistralidade
│       └── 08_agregacao_ouro_fraude.sql        <- Filtros analíticos de potenciais fraudes
│
├── 📁 powerbi
│   ├── dashboard_seguros.pbix                 <- Template do relatório final
│   └── dax_measures.txt                       <- Central de fórmulas DAX (Loss Ratio, YoY, etc.)
│
├── 📁 docs
│   ├── dicionario_dados.md                    <- Metadados e regras de negócio
│   └── screenshot_workflow.png                <- Print screen do DAG do Databricks Workflow
│
└── README.md                                  <- Documentação principal
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