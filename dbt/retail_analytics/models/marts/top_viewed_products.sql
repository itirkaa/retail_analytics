-- models/marts/top_viewed_products.sql
{{
  config(
    materialized = 'table',
    file_format = 'iceberg',
    location_root = 's3://retail-data/processed-data/top_viewed_products'
  )
}}


WITH product_views AS (
  SELECT 
    product_id,
    COUNT(*) as view_count,
    COUNT(DISTINCT user_id) as unique_viewers,
    MAX(timestamp) as last_viewed_at
  FROM {{ ref('stg_user_events') }}
  WHERE event_type = 'page_view'
  GROUP BY product_id
),
product_details AS (
  SELECT 
    pv.*,
    pm.name as product_name,
    pm.category,
    pm.price as current_price,
    DENSE_RANK() OVER (ORDER BY pv.view_count DESC) as view_rank
  FROM product_views pv
  JOIN {{ ref('stg_product_metadata') }} pm ON pv.product_id = pm.product_id
)

SELECT 
  product_id,
  product_name,
  category,
  current_price,
  view_count,
  unique_viewers,
  last_viewed_at,
  CURRENT_TIMESTAMP() as updated_at
FROM product_details
WHERE view_rank <= 3
