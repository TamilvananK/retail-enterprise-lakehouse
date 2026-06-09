{{ config(materialized='table') }}

WITH sales AS (
    SELECT * FROM {{ ref('stg_sales') }}
),

customers AS (
    SELECT * FROM {{ ref('dim_customer') }}
),

products AS (
    SELECT * FROM {{ ref('dim_product') }}
)

SELECT
    s.transaction_id,
    
    -- Foreign Keys (Surrogate Keys) linking to our Dimensions
    c.customer_sk,
    p.product_sk,
    
    -- Degenerate dimensions and metrics
    s.quantity,
    s.total_amount,
    s.transaction_date,
    s.payment_method

FROM sales s

-- Point-in-Time Join for Customer
LEFT JOIN customers c
    ON s.customer_id = c.customer_nk
    AND s.transaction_date >= c.valid_from
    AND s.transaction_date < c.valid_to

-- Point-in-Time Join for Product
LEFT JOIN products p
    ON s.product_id = p.product_nk
    AND s.transaction_date >= p.valid_from
    AND s.transaction_date < p.valid_to