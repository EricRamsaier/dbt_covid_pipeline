/*
Creator: Eric Ramsaier
*/

{{
  config(
    tags = ['stg', 'faker']
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('faker__orders', 'faker_orders_orders') }}
    {{ dev_data_filter('order_date', 7) }}
),
final AS (
    SELECT
        order_id    -- No cast, keep as VARCHAR
      , customer_id -- No cast, keep as VARCHAR
      , {{ to_timestamp('order_date') }}      AS order_ts
      , CAST(currency_id AS INTEGER)          AS currency_id
    FROM
        source_data
)

SELECT * FROM final
