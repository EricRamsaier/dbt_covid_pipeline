/*
Creator: Eric Ramsaier
Model: fct_order_items
Purpose: Fact table for order items
         - One row per order item
         - Joined to product and order dimension tables
         - Includes surrogate keys and audit metadata
         - Safe against FK mismatches
Notes:
  - Data sourced from int_faker_orders_order_items
  - Source table is INSERT-ONLY (no updates in place)
  - Uses LEFT JOINs and COALESCE for robustness
*/

{{ config(
    materialized = 'incremental',
    unique_key = 'order_item_sk',
    tags = ['fct', 'faker', 'fact'],
    cluster_by = ['order_dt', 'order_sk']
) }}

WITH 
-- Source tables
order_items AS (
    SELECT * 
    FROM {{ ref('int_faker_orders_order_items') }}
    {% if is_incremental() %}
      WHERE order_dt >= DATEADD(day, -2, CURRENT_DATE)
    {% endif %}
),

fct_orders AS (
    SELECT * 
    FROM {{ ref('fct_faker_orders') }}
),

dim_product AS (
    SELECT * 
    FROM {{ ref('dim_faker_product') }}
),
-- End source tables

final AS (
    SELECT
        {{ generate_surrogate_key(['order_items.order_id', 'order_items.product_id']) }} AS order_item_sk
      , order_items.order_id
      , {{ sk_fallback('fct_orders.order_sk') }}    AS order_sk
      , order_items.product_id
      , {{ sk_fallback('dim_product.product_sk') }} AS product_sk
      , order_items.order_sales_qty
      , order_items.order_sales_unit_price
      , order_items.order_sales_line_total
      , order_items.order_ts
      , order_items.order_dt
--      , order_items.created_ts
--      , order_items.updated_ts
      , {{ standard_audit_columns() }}
    FROM 
      order_items
      LEFT JOIN 
      fct_orders
        ON order_items.order_id = fct_orders.order_id
      LEFT JOIN 
      dim_product
        ON order_items.product_id = dim_product.product_id
)

SELECT * FROM final
