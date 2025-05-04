/*
Creator: Eric Ramsaier
*/

{{
  config(
    tags = ['stg', 'faker']
  )
}}

WITH
source_data AS (
    SELECT * FROM {{ source('faker__orders', 'faker_orders_product') }}
),
--
--
final AS (
    SELECT
        product_id
      , CAST(product_name AS VARCHAR(100))      AS product_name
      , CAST(category AS VARCHAR(100))          AS product_category
    FROM
        source_data
)
--
--
SELECT * FROM final