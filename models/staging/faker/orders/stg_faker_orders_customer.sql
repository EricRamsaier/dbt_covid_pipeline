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
    SELECT * FROM {{ source('faker__orders', 'faker_orders_customer') }}
),
--
--
final AS (
    SELECT
        CAST(customer_id AS VARCHAR(100))      AS customer_id
      , CAST(customer_name AS VARCHAR(100))    AS customer_name
      , CAST(email AS VARCHAR(100))            AS customer_email
      , CAST(country AS VARCHAR(50))           AS customer_country
    FROM
        source_data
)
--
--
SELECT * FROM final