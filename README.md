# 🛒 Enterprise Retail Lakehouse Platform

## 📖 Project Overview
This project is an end-to-end, production-grade data engineering platform designed to modernize a legacy retail reporting system into a cloud-native Lakehouse architecture. 

It ingests highly fragmented, heterogeneous data (Sales, Inventory, Customers, Products) and processes it through a Medallion Architecture (Bronze, Silver, Gold) to deliver cross-domain analytics. The platform enables near real-time executive dashboarding, Customer 360 reporting, and supply chain health tracking to proactively identify inventory stockouts.

## 🏗️ Architecture & Data Flow

```mermaid
graph TD
    %% Define external sources
    subgraph ExtSources [External Sources]
        API[JSON API]
        CSV[Daily CSV Exports]
        DB[Relational DB]
    end

    %% Ingestion Layer
    subgraph ADF [Azure Data Factory]
        ADF_PL[Metadata-Driven Pipeline]
    end

    %% Databricks Lakehouse
    subgraph Databricks [Databricks Unity Catalog & dbt]
        Bronze[(Bronze Layer / Raw)]
        Silver[(Silver Layer / Conformed)]
        Gold[(Gold Layer / Business)]
        
        Bronze -->|PySpark / dbt| Silver
        Silver -->|dbt Snapshots SCD2| Silver
        Silver -->|dbt Star Schema| Gold
    end

    %% Orchestration
    subgraph Orchestration [Orchestration]
        Airflow((Apache Airflow))
    end

    %% Serving Layer
    subgraph Snowflake [Snowflake Data Warehouse]
        SF_Landing[silver_landing]
        SF_Analytics[analytics_gold]
        SF_Ops[operations_gold]
        SF_Views[Secure BI Views]
        
        SF_Analytics --> SF_Views
        SF_Ops --> SF_Views
    end

    %% BI Tool
    subgraph BI [Business Intelligence]
        PBI[Power BI]
    end

    %% Flow connections
    ExtSources -->|Ingest| ADF_PL
    ADF_PL -->|Land| Bronze
    Gold -->|Databricks Lakehouse Federation| SF_Analytics
    Gold -->|Databricks Lakehouse Federation| SF_Ops
    SF_Views --> PBI

    %% Orchestration links
    Airflow -.->|Triggers| ADF_PL
    Airflow -.->|Triggers processing| Databricks

```


🛠️ Tech Stack
Cloud Infrastructure: Azure (ADLS Gen2)

Ingestion: Azure Data Factory (Metadata-driven parameterized pipelines)

<img width="1439" height="853" alt="Screen Shot 2026-06-22 at 6 17 18 PM" src="https://github.com/user-attachments/assets/65531617-cf0c-4eab-93ce-d4baf71fc314" />



Processing & Compute: Azure Databricks (PySpark, Databricks Lakehouse Federation)

<img width="1439" height="853" alt="Screen Shot 2026-06-22 at 6 16 58 PM" src="https://github.com/user-attachments/assets/049a80a3-8813-4a68-9256-d8d794ba4d37" />

Data Transformation: dbt (Data Build Tool)

<img width="1439" height="769" alt="Screen Shot 2026-06-22 at 6 44 18 PM" src="https://github.com/user-attachments/assets/df29f346-74d7-40ff-9bca-fdd22b45fb80" />


Data Warehouse / Serving Layer: Snowflake (Role-Based Access Control, Secure Views)

Orchestration: Apache Airflow

<img width="1439" height="853" alt="Screen Shot 2026-06-22 at 6 14 57 PM" src="https://github.com/user-attachments/assets/2a786c5c-886a-417b-84c4-7a3bae1711eb" />


Business Intelligence: Power BI

🚀 Key Engineering Implementations
1. Medallion Architecture Integration
Implemented a strict Bronze, Silver, and Gold namespace using dbt, isolating raw data from conformed business logic.

2. Slowly Changing Dimensions (SCD Type 2)
Engineered automated historical tracking for Customer and Product dimension tables using modern YAML-based dbt snapshots. This enables accurate point-in-time financial reporting even as customer tiers or product prices change over time.

3. Cross-Domain Analytical Modeling
Moved beyond standard siloed sales analytics by integrating the Revenue and Supply Chain domains. Built a unified inventory_health mart that cross-references trailing 30-day sales velocity against current warehouse stock to predict and flag critical stockout risks.

4. Databricks Lakehouse Federation
Bypassed intermediate external stages by utilizing Databricks Unity Catalog Federation. Configured the Spark-Snowflake connector to seamlessly push curated Gold models directly from Databricks memory into domain-specific Snowflake schemas (analytics_gold, operations_gold).

5. Decoupled Orchestration
Designed an idempotent Apache Airflow DAG to act purely as the control plane. Compute is strictly delegated to specialized engines: ADF handles IO/Ingestion, Databricks handles transformation, and Snowflake handles BI query concurrency.

## 📁 Repository Structure

```text
enterprise-retail-lakehouse/
│
├── adf/
│   └── Azure Data Factory pipeline JSON definitions
│
├── airflow/
│   └── DAGs, scheduling, and orchestration workflows
│
├── databricks/
│   └── PySpark notebooks, Lakehouse Federation scripts,
│       and cluster configurations
│
├── dbt_retail_dev/
│   ├── models/
│   │   ├── silver/
│   │   │   └── Cleansed and conformed business models
│   │   │
│   │   └── gold/
│   │       └── Star schema facts and dimensions
│   │
│   ├── snapshots/
│   │   └── SCD Type 2 configurations
│   │
│   └── dbt_project.yml
│       └── dbt project configuration
│
├── snowflake/
│   └── DDL scripts for databases, schemas,
│       RBAC roles, and secure views
│
└── README.md
    └── Project documentation
```

## 👨‍💻 Author

**Tamilvanan Kannappan**
Data Engineer



