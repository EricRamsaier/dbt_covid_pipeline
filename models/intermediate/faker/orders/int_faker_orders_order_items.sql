/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Intermediate model for order items
         - Casts types
         - Adds derived fields
         - Prepares clean layer for fct_order_items
*/

{{ config(
    tags = ['int', 'faker']
) }}

WITH base AS (
    SELECT * 
    FROM {{ ref('stg_faker_orders_order_items') }}
),

final AS (
    SELECT
        order_id
      , product_id
      , order_sales_qty
      , order_sales_unit_price
      , (order_sales_qty * order_sales_unit_price) AS order_sales_line_total
      , order_ts
      , DATE(order_ts) AS order_dt
      , created_ts
      , updated_ts
    FROM base
)

SELECT * FROM final
