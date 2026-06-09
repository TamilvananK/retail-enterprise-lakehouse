{{ config(materialized='table') }}

WITH daily_sales AS (
    SELECT
        product_sk,
        SUM(quantity) AS total_units_sold,
        SUM(total_amount) AS total_revenue
    FROM {{ ref('fact_sales') }}
    -- Zooming in on recent activity to calculate demand velocity
    WHERE transaction_date >= DATE_SUB(CURRENT_DATE(), 30)
    GROUP BY product_sk
),

current_inventory AS (
    SELECT
        product_sk,
        SUM(stock_quantity) AS total_current_stock
    FROM {{ ref('fact_inventory') }}
    GROUP BY product_sk
),

products AS (
    SELECT 
        product_sk,
        product_name,
        category
    FROM {{ ref('dim_product') }}
    WHERE is_current = TRUE
)

SELECT
    p.product_sk,
    p.product_name,
    p.category,
    COALESCE(i.total_current_stock, 0) AS current_stock,
    COALESCE(s.total_units_sold, 0) AS units_sold_past_30_days,
    COALESCE(s.total_revenue, 0) AS revenue_past_30_days,
    
    -- Stock-to-Sales Velocity Metric
    CASE 
        WHEN COALESCE(s.total_units_sold, 0) = 0 THEN 'Overstocked / No Demand'
        WHEN COALESCE(i.total_current_stock, 0) / s.total_units_sold < 0.2 THEN 'Critical Stockout Risk'
        WHEN COALESCE(i.total_current_stock, 0) / s.total_units_sold BETWEEN 0.2 AND 0.5 THEN 'Low Stock'
        ELSE 'Healthy Stock Level'
    END AS inventory_status

FROM products p
LEFT JOIN daily_sales s ON p.product_sk = s.product_sk
LEFT JOIN current_inventory i ON p.product_sk = i.product_sk