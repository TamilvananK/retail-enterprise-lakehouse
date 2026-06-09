WITH source AS (
    SELECT * FROM {{ source('bronze', 'customers') }}
),

renamed_and_cleaned AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        -- Data Cleansing: Handle those injected null emails
        COALESCE(email, 'UNKNOWN_EMAIL') AS email,
        address,
        country,
        -- Standardization: Cast strings to proper dates
        CAST(join_date AS DATE) AS join_date,
        loyalty_tier
    FROM source
)

SELECT * FROM renamed_and_cleaned