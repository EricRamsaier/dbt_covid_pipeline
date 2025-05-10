-- Created:       2024-05-10
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Model:         dim_owid_iso_code
-- Purpose:       Provides a unique list of OWID ISO codes with associated location and continent
-- Notes:
--   - Only includes ISO codes that appear in the source data


{{
  config(
    unique_key='sk_owid_iso_code',
    tags=['dim', 'owid']
  )
}}

WITH 
int_data AS (
    SELECT * FROM {{ ref('int_owid_covid') }}
),

fct_data AS (
    SELECT * FROM {{ ref('fct_owid_covid') }}
),

final AS (
    SELECT DISTINCT
        iso.sk_owid_iso_code
      , int.owid_iso_code
      , int.location
      , int.continent
    FROM int_data AS int
    LEFT JOIN fct_data AS iso
      ON int.owid_iso_code = iso.owid_iso_code
    WHERE int.owid_iso_code IS NOT NULL
)

SELECT * FROM final

