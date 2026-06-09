{{ config(materialized='table') }}

WITH snapshot_data AS (
    SELECT * FROM {{ ref('snp_customers') }}
)

SELECT
    -- Use the dbt-generated surrogate key as our Primary Key for the Gold layer
    dbt_scd_id AS customer_sk, 
    customer_id AS customer_nk, -- nk = Natural Key
    first_name,
    last_name,
    email,
    address,
    country,
    loyalty_tier,
    -- Business-friendly historical tracking columns
    CAST(dbt_valid_from AS TIMESTAMP) AS valid_from,
    COALESCE(CAST(dbt_valid_to AS TIMESTAMP), CAST('9999-12-31' AS TIMESTAMP)) AS valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
FROM snapshot_data