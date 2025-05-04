/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Intermediate model for orders
         - One row per order with cleaned timestamps and derived fields
         - Prepares clean layer for fct_orders
Notes:
  - Data sourced from stg__faker__orders__orders
  - Includes order date and order status flag
  - Excludes order total logic (belongs in marts layer)
*/

{{ config(
    tags = ['int', 'faker']
) }}

WITH orders AS (
    SELECT * 
    FROM {{ ref('stg_faker_orders_orders') }}
),

final AS (
    SELECT
        orders.order_id
      , orders.customer_id
      , orders.currency_id
      , orders.order_ts
      , CAST(orders.order_ts AS DATE) AS order_dt
      , CASE
          WHEN orders.order_ts > CURRENT_TIMESTAMP() - INTERVAL '30 DAYS' THEN 'recent'
          ELSE 'old'
        END AS order_status
      , {{ standard_audit_columns() }}
    FROM orders
)

SELECT * FROM final
