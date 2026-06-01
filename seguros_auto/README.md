```mermaid
graph TD
    %% Fontes de Dados
    subgraph Fontes de Dados (Simulação)
        A[Sistemas Transacionais - Apólices]
        B[Sistemas de Sinistros - Acidentes]
    end

    %% Arquitetura Medalhão no Databricks
    subgraph Databricks Lakehouse (Spark SQL)
        C[(bronze_apolices)]
        D[(bronze_sinistros)]
        
        E[(prata_dados_seguros)]
        
        F[(ouro_analise_risco)]
        G[(ouro_alertas_fraude)]
    end

    %% Camada de Visualização
    subgraph Power BI
        H[Dashboard de Monitorização]
    end

    %% Fluxo de Dados
    A -->|Ingestão Delta| C
    B -->|Ingestão Delta| D
    
    C -->|Limpeza & Join| E
    D -->|Limpeza & Join| E
    
    E -->|Agregação de Risco| F
    E -->|Filtros de Fraude| G
    
    F -->|Conexão DirectQuery / Import| H
    G -->|Conexão DirectQuery / Import| H
    
    %% Estilos
    style C fill:#f9f,stroke:#333,stroke-width:2px
    style D fill:#f9f,stroke:#333,stroke-width:2px
    style E fill:#bbf,stroke:#333,stroke-width:2px
    style F fill:#bfb,stroke:#333,stroke-width:2px
    style G fill:#bfb,stroke:#333,stroke-width:2px
    style H fill:#f96,stroke:#333,stroke-width:2px
```
