/*
Creator: Eric Ramsaier
Model: fct_orders
Purpose: Fact table for customer orders
         - One row per order
         - Joined to dimension tables via surrogate keys
         - Aggregates order totals from order items
Notes:
  - Joins to dim_customer and dim_currency
  - Aggregates item totals from int_faker_orders_order_items
  - LEFT JOINs with fallback SKs to avoid row loss
  - Incremental model, pulls last 2 days based on order_dt, assuming source table insert-only
*/

{{ config(
    materialized = 'incremental',
    unique_key = 'order_id',
    tags = ['fct', 'faker'],
    cluster_by = ['order_dt', 'customer_sk']
) }}

WITH 
-- Source tables
orders AS (
    SELECT * 
    FROM {{ ref('int_faker_orders_orders') }}
    {% if is_incremental() %}
      WHERE order_dt >= DATEADD(day, -2, CURRENT_DATE)
    {% endif %}
),

order_items AS (
    SELECT * 
    FROM {{ ref('int_faker_orders_order_items') }}
),

dim_customer AS (
    SELECT * 
    FROM {{ ref('dim_faker_customer') }}
),

dim_currency AS (
    SELECT * 
    FROM {{ ref('dim_faker_currency') }}
),
-- End source tables

order_totals AS (
    SELECT
        order_id
      , SUM(order_sales_line_total) AS total_order_amount
      , SUM(order_sales_qty) AS total_order_qty
    FROM order_items
    GROUP BY order_id
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['orders.order_id']) }} AS order_sk
      , orders.order_id
      , {{ sk_fallback('dim_customer.customer_sk') }}   AS customer_sk
      , {{ sk_fallback('dim_currency.currency_sk') }}   AS currency_sk
      , orders.order_ts
      , orders.order_dt
      , COALESCE(order_totals.total_order_amount, 0) AS total_order_amount
      , COALESCE(order_totals.total_order_qty, 0)    AS total_order_qty
      , orders.order_status
      , {{ standard_audit_columns() }}
    FROM 
      orders
      LEFT JOIN 
      order_totals
        ON orders.order_id = order_totals.order_id
      LEFT JOIN 
      dim_customer
        ON orders.customer_id = dim_customer.customer_id
      LEFT JOIN 
      dim_currency
        ON orders.currency_id = dim_currency.currency_id
)

SELECT * FROM final
