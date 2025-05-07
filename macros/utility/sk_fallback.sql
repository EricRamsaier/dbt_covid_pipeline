/*
Creator: Eric Ramsaier
Macro: sk_fallback
Purpose:
  - Returns a COALESCE expression that falls back to a string default
    when the given surrogate key column is NULL.
  - Ensures consistent handling of missing SKs across all models.
Usage:
  - Use this macro anywhere you need to guard a surrogate key column:
      {{ sk_fallback('dim_customer.customer_sk') }} AS customer_sk
  - Override the default fallback value if desired:
      {{ sk_fallback('dim_currency.currency_sk', default='0') }} AS currency_sk
Example Usage:
    SELECT
      {{ sk_fallback('dim_currency.currency_sk') }} AS currency_sk
    FROM {{ ref('dim_currency') }}
*/
{% macro sk_fallback(column_ref, default='-1') -%}
  -- return column_ref if not null, else default
  coalesce({{ column_ref }}, '{{ default }}')
{%- endmacro %}
