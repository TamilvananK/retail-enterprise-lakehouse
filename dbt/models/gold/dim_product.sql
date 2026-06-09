{{ config(materialized='table') }}

WITH snapshot_data AS (
    SELECT * FROM {{ ref('snp_products') }}
)

SELECT
    dbt_scd_id AS product_sk,
    product_id AS product_nk,
    product_name,
    category,
    unit_price,
    supplier_id,
    CAST(dbt_valid_from AS TIMESTAMP) AS valid_from,
    COALESCE(CAST(dbt_valid_to AS TIMESTAMP), CAST('9999-12-31' AS TIMESTAMP)) AS valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
FROM snapshot_data