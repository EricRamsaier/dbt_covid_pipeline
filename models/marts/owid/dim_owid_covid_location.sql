-- Created:       2024-05-10
-- Last Modified: 2025-05-23
-- Creator:       Eric Ramsaier
-- Model:         dim_owid_iso_code
-- Purpose:       Provides a unique list of OWID ISO codes with associated location and continent
-- Notes:
--   - Only includes ISO codes that appear in the source data


{{
  config(
    unique_key='sk_owid_iso_code'
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

