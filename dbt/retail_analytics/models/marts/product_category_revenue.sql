-- models/marts/product_category_revenue.sql
{{
  config(
    materialized = 'table',
    file_format = 'iceberg',
    location_root = 's3://retail-data/processed-data/product_category_revenue'
  )
}}

WITH purchase_events AS (
  SELECT 
    product_id,
    event_data:price::FLOAT as price,
    event_data:quantity::INT as quantity,
    price * quantity as revenue
  FROM {{ ref('stg_user_events') }}
  WHERE event_type = 'purchase'
),
product_purchases AS (
  SELECT 
    pe.*,
    pm.category
  FROM purchase_events pe
  JOIN {{ ref('stg_product_metadata') }} pm ON pe.product_id = pm.product_id
)

SELECT 
  category,
  SUM(revenue) as total_revenue,
  COUNT(DISTINCT product_id) as unique_products_sold,
  COUNT(*) as total_purchases,
  CURRENT_TIMESTAMP() as updated_at
FROM product_purchases
GROUP BY category