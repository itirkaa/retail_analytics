{% macro positive_value(model, column_name) %}
    SELECT
        {{ column_name }} as value
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
      AND {{ column_name }} <= 0
{% endmacro %}