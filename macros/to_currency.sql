/*
Creator: Eric Ramsaier
Macro: to_currency
Purpose:
    - This macro attempts to convert a varchar column representing a currency value to a `DECIMAL(10, 2)`.
    - It ensures that the values are stored as numeric types, which is important for calculations.

Usage:
    - Use this macro to standardize the way currency values are converted across your dbt models.
    - The `DECIMAL(10, 2)` format allows for up to 10 digits with 2 decimal places (e.g., for values like `1000000000.99`).

Example Usage:
    SELECT
        {{ to_currency('order_total') }} AS order_total_amount
    FROM {{ ref('stg__faker__orders__fact_orders') }}
*/

{% macro to_currency (currency_column) %}
    TRY_CAST({{ currency_column }} AS DECIMAL(10, 2))
{% endmacro %}
