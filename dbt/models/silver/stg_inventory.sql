WITH source AS (
    SELECT * FROM {{ source('bronze', 'inventory') }}
),

cleaned AS (
    SELECT
        inventory_id,
        product_id,
        warehouse_id,
        -- Data Cleansing: Floor negative inventory anomalies at 0
        GREATEST(CAST(stock_quantity AS INT), 0) AS stock_quantity,
        CAST(last_restock_date AS TIMESTAMP) AS last_restock_date
    FROM source
)

SELECT * FROM cleaned