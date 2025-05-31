{{
  config(
    tags = ['dim', 'marts', 'owid', 'covid'],
    contract = {"enforced": true}
  )
}}

WITH 
int_data AS (
    SELECT * FROM {{ ref('int_owid_covid') }}
),

final AS (
    SELECT DISTINCT
        sk_owid_iso_code
      , owid_iso_code
      , location
      , continent
    FROM 
        int_data

)

SELECT * FROM final

