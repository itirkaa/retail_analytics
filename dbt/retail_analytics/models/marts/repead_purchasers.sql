{{
  config(
    materialized = 'table',
    file_format = 'iceberg',
    location_root = 's3://retail-data/processed-data/repeat_purchasers'
  )
}}

WITH daily_purchases AS (
  SELECT 
    user_id,
    DATE(timestamp) as purchase_date,
    COUNT(*) as daily_purchase_count,
    SUM(event_data:quantity::INT) as total_items_purchased,
    SUM(event_data:price::FLOAT * event_data:quantity::INT) as total_spent
  FROM {{ ref('stg_user_events') }}
  WHERE event_type = 'purchase'
  GROUP BY user_id, DATE(timestamp)
  HAVING COUNT(*) > 1
)

SELECT 
  user_id,
  purchase_date,
  daily_purchase_count,
  total_items_purchased,
  total_spent,
  CURRENT_TIMESTAMP() as updated_at
FROM daily_purchases
