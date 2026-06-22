# 🛒 Enterprise Retail Lakehouse Platform

## 📖 Project Overview
This project is an end-to-end, production-grade data engineering platform designed to modernize a legacy retail reporting system into a cloud-native Lakehouse architecture. 

It ingests highly fragmented, heterogeneous data (Sales, Inventory, Customers, Products) and processes it through a Medallion Architecture (Bronze, Silver, Gold) to deliver cross-domain analytics. The platform enables near real-time executive dashboarding, Customer 360 reporting, and supply chain health tracking to proactively identify inventory stockouts.

## 🏗️ Architecture & Data Flow

```mermaid
graph TD
    %% Define external sources
    subgraph External Sources
        API[JSON API]
        CSV[Daily CSV Exports]
        DB[Relational DB]
    end

    %% Ingestion Layer
    subgraph Azure Data Factory
        ADF_PL[Metadata-Driven Pipeline]
    end

    %% Databricks Lakehouse
    subgraph Databricks Unity Catalog & dbt
        Bronze[(Bronze Layer / Raw)]
        Silver[(Silver Layer / Conformed)]
        Gold[(Gold Layer / Business)]
        
        Bronze -->|PySpark / dbt| Silver
        Silver -->|dbt Snapshots SCD2| Silver
        Silver -->|dbt Star Schema| Gold
    end

    %% Orchestration
    subgraph Orchestration
        Airflow((Apache Airflow))
    end

    %% Serving Layer
    subgraph Snowflake Data Warehouse
        SF_Landing[silver_landing]
        SF_Analytics[analytics_gold]
        SF_Ops[operations_gold]
        SF_Views[Secure BI Views]
        
        SF_Analytics --> SF_Views
        SF_Ops --> SF_Views
    end

    %% BI Tool
    subgraph Business Intelligence
        PBI[Power BI]
    end

    %% Flow connections
    External Sources -->|Ingest| ADF_PL
    ADF_PL -->|Land| Bronze
    Gold -->|Databricks Lakehouse Federation| SF_Analytics
    Gold -->|Databricks Lakehouse Federation| SF_Ops
    SF_Views --> PBI

    %% Orchestration links
    Airflow -.->|Triggers| ADF_PL
    Airflow -.->|Triggers dbt| Databricks Unity Catalog & dbt
    Airflow -.->|Triggers Federation| Databricks Unity Catalog & dbt
