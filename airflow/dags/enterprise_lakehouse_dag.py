from airflow import DAG
from airflow.providers.microsoft.azure.operators.data_factory import AzureDataFactoryRunPipelineOperator
from airflow.providers.databricks.operators.databricks import DatabricksRunNowOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime, timedelta

# 1. Define Default Arguments for Fault Tolerance
default_args = {
    'owner': 'data_engineering_team',
    'depends_on_past': False,
    'email_on_failure': True, # Alerts the team if a critical pipeline fails
    'email_on_retry': False,
    'retries': 2,             # Handles transient cloud API failures
    'retry_delay': timedelta(minutes=3)
}

# 2. Instantiate the DAG
with DAG(
    dag_id='enterprise_retail_lakehouse_pipeline',
    default_args=default_args,
    start_date=datetime(2026, 6, 5),
    schedule_interval='@daily',
    catchup=False,
    tags=['retail', 'medallion', 'production'],
    max_active_runs=1
) as dag:

    # ---------------------------------------------------------
    # TASK 1: Ingest Raw Data to Bronze (Azure Data Factory)
    # ---------------------------------------------------------
    # wait_for_termination=True ensures Airflow doesn't trigger Databricks until the data has actually landed.
    ingest_to_bronze = AzureDataFactoryRunPipelineOperator(
    task_id='trigger_adf_ingestion',
    azure_data_factory_conn_id='azure_data_factory_default',
    pipeline_name='PL_METADATA_INGESTION',
    resource_group_name='Retail_org_RG',
    factory_name='adf-Retail-pro',
    wait_for_termination=True
    )

    # ---------------------------------------------------------
    # TASK 2: Cleanse and Conform to Silver (Databricks + dbt)
    # ---------------------------------------------------------
    # Assumes you have configured a Databricks Job that runs `dbt run --select silver` and `dbt snapshot`
    process_silver_layer = DatabricksRunNowOperator(
        task_id='dbt_silver_and_snapshots',
        databricks_conn_id='databricks_default',
        job_id=543914771448530  # Your specific Databricks Job ID
    )

    # ---------------------------------------------------------
    # TASK 3: Aggregate to Gold Star Schema (Databricks + dbt)
    # ---------------------------------------------------------
    # Assumes a Databricks Job running `dbt run --select gold`
    process_gold_layer = DatabricksRunNowOperator(
        task_id='dbt_gold_star_schema',
        databricks_conn_id='databricks_default',
        job_id=841065987563657
    )

    # ---------------------------------------------------------
    # TASK 4: Load Curated Data into Snowflake Serving Layer
    # ---------------------------------------------------------
    # Triggers a stored procedure or COPY INTO command in Snowflake
    load_snowflake_serving = DatabricksRunNowOperator(
    task_id='load_gold_to_snowflake',
    databricks_conn_id='databricks_default',
    job_id=324188902771662
)

    # ---------------------------------------------------------
    # TASK 5: Final Data Quality Gate
    # ---------------------------------------------------------
    # Ensures no nulls or duplicates made it into the executive reporting layer
    validate_snowflake_data = SQLExecuteQueryOperator(
    task_id='validate_serving_layer',
    conn_id='snowflake_default',
    sql="""
        SELECT 1 / CASE WHEN COUNT(*) = 0 THEN 1 ELSE 0 END
        FROM (
            SELECT transaction_id
            FROM retail_enterprise_db.analytics_gold.fact_sales
            GROUP BY transaction_id
            HAVING COUNT(*) > 1
        );
    """
)

    # 3. Define the Pipeline Dependencies (The DAG Flow)
    ingest_to_bronze >> process_silver_layer >> process_gold_layer >> load_snowflake_serving >> validate_snowflake_data
