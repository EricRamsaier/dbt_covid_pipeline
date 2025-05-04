/*
Creator: Eric Ramsaier
*/

{{ 
  config(
    tags = ['stg', 'faker']
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('faker__orders', 'faker_orders_order_items') }}
    {{ dev_data_filter('order_date', 7) }}
),

final AS (
    SELECT
        order_id    -- No cast, keep as VARCHAR
      , product_id  -- No cast, keep as VARCHAR
      , CAST(quantity AS INTEGER)         AS order_sales_qty
      , {{ to_currency('unit_price') }}   AS order_sales_unit_price
      , {{ to_timestamp('order_date') }}  AS order_ts    -- Use macro to cast to TIMESTAMP_LTZ
      , {{ to_timestamp('created_ts') }}  AS created_ts  -- Use macro
      , {{ to_timestamp('updated_ts') }}  AS updated_ts  -- Use macro
    FROM source_data
)

SELECT * FROM final
