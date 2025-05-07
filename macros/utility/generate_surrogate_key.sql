/*
  Generates a SHA256 surrogate key from a list of input columns.

  Ensures that all input columns are NOT NULL before generating the key
  to avoid producing hashes based on incomplete data.

  Usage:
      {{ generate_surrogate_key(['order_id', 'product_id']) }} AS order_item_sk

  This macro:
    - Raises a compile-time error if no columns are passed
    - Produces NULL if any input column is NULL
    - Wraps dbt_utils.generate_surrogate_key()
*/
{% macro generate_surrogate_key(columns) %}
    {% if columns | length == 0 %}
        {{ exceptions.raise_compiler_error("generate_surrogate_key requires at least one column") }}
    {% endif %}

    /* Build a condition to ensure no input columns are null */
    {% set not_null_condition = columns | map('string') | join(' IS NOT NULL AND ') ~ ' IS NOT NULL' %}

    /* Use dbt_utils to build the SHA256 hash expression */
    {% set surrogate_expr = dbt_utils.generate_surrogate_key(columns) %}

    /* Return the key only when all input values are present */
    CASE
        WHEN {{ not_null_condition }} THEN {{ surrogate_expr }}
        ELSE NULL
    END
{% endmacro %}
