{% test assert_event_data_has_required_fields(model, column_name) %}

WITH validation AS (
    SELECT
        event_id,
        event_type,
        event_data
    FROM {{ model }}
    WHERE event_type = 'purchase'
      AND (
          event_data:price IS NULL
          OR event_data:quantity IS NULL
      )
)

SELECT *
FROM validation

{% endtest %}