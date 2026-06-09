{{ config(materialized='table') }}

WITH inventory AS (
    SELECT * FROM {{ ref('stg_inventory') }}
),

products AS (
    SELECT * FROM {{ ref('dim_product') }}
)

SELECT
    i.inventory_id,
    i.warehouse_id,
    
    -- Foreign Key linking to the exact historical product state
    p.product_sk,
    
    i.stock_quantity,
    i.last_restock_date
    
FROM inventory i

LEFT JOIN products p
    ON i.product_id = p.product_nk
    AND i.last_restock_date >= p.valid_from
    AND i.last_restock_date < p.valid_to