{{
  config(
    materialized = 'table',
    file_format = 'iceberg',
    location_root = 's3://retail-data/stage-data/stg_product_metadata'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('raw', 'product_metadata') }}
)

SELECT
    event_type,
    user_id,
    product_id,
    name,
    category,
    price::FLOAT as price,
    description,
    created_at,
    modified_at,
    -- Add audit columns
    _loaded_at as loaded_at,
    CURRENT_TIMESTAMP() as transformed_at
FROM source
WHERE product_id IS NOT NULL
  AND category IS NOT NULL
