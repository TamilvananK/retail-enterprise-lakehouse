WITH source AS (
    SELECT * FROM {{ source('bronze', 'products') }}
),

renamed_and_casted AS (
    SELECT
        product_id,
        product_name,
        category,
        -- Ensure prices are handled as decimals, not floats, for accurate math
        CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
        supplier_id
    FROM source
)

SELECT * FROM renamed_and_casted