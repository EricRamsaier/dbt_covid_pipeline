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
    SELECT * FROM {{ ref('faker_orders_currency') }}
),
--
--
final AS (
    SELECT
        CAST(currency_id AS INTEGER)         AS currency_id
      , CAST(currency_code AS VARCHAR(3))    AS currency_code
      , CAST(currency_name AS VARCHAR(50))   AS currency_name
      , CAST(currency_symbol AS VARCHAR(5))  AS currency_symbol
    FROM
        source_data
)
--
--
SELECT * FROM final
