/*
Creator: Eric Ramsaier
Macro: to_timestamp
Purpose: 
    - This macro casts a given date or timestamp column to `TIMESTAMP_LTZ`.
    - `TIMESTAMP_LTZ` ensures that the timestamp is stored in UTC with session-local display for timezone management.
    
Usage:
    - You can use this macro to standardize the casting of timestamp fields across your dbt models.
    - It is especially useful when working with different time zones, as `TIMESTAMP_LTZ` ensures consistent handling of time zones.

Example Usage:
    SELECT
        {{ to_timestamp('order_date') }} AS order_ts
    FROM {{ ref('stg__faker__orders__fact_orders') }}
*/

{% macro to_timestamp (date_column) %}
    CAST({{ date_column }} AS TIMESTAMP_LTZ)
{% endmacro %}
