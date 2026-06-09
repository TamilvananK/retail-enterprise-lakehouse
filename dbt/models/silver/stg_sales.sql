WITH source AS (
    SELECT * FROM {{ source('bronze', 'sales') }}
),

deduplicated_and_cleaned AS (
    SELECT
        transaction_id,
        customer_id,
        product_id,
        CAST(quantity AS INT) AS quantity,
        CAST(total_amount AS DECIMAL(10,2)) AS total_amount,
        CAST(transaction_date AS TIMESTAMP) AS transaction_date,
        payment_method
    FROM source
    -- Data Cleansing: Deduplicate records by keeping the first instance of a transaction
    QUALIFY ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date DESC) = 1
)

SELECT * FROM deduplicated_and_cleaned