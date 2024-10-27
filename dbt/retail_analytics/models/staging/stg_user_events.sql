{{
  config(
    materialized = 'table',
    file_format = 'iceberg',
    location_root = 's3://retail-data/stage-data/stg_user_events'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('raw', 'user_events') }}
)

SELECT
    event_id,
    user_id,
    product_id,
    event_type,
    event_data,
    timestamp as event_timestamp,
    -- Add parsed common fields from event_data
    CASE 
        WHEN event_type = 'purchase' THEN event_data:price::FLOAT
        ELSE NULL
    END as price,
    CASE 
        WHEN event_type = 'purchase' THEN event_data:quantity::INT
        ELSE NULL
    END as quantity,
    -- Add audit columns
    _loaded_at as loaded_at,
    CURRENT_TIMESTAMP() as transformed_at
FROM source
WHERE event_type IS NOT NULL
  AND user_id IS NOT NULL
  AND product_id IS NOT NULL
