-- dim_owid_location
-- -------------------
-- This dimension model extracts unique location names from the OWID COVID dataset.
-- Each location is a named entity such as a country, region, or aggregate (e.g. "France", "World", "European Union").
-- It assigns a surrogate key (`sk_location`) to each distinct `location`.
-- This model is useful for joining to fact tables without duplicating descriptive text values.
-- NOTE: Locations may not always map to real countries; ensure downstream usage accounts for OWID-defined entities.

{{
  config(
    unique_key='sk_location',
    tags=['dim','owid']
  )
}}

WITH source_data AS (
    SELECT * FROM {{ ref('int_owid_covid_data') }}
),

final AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['owid_iso_code']) }} AS sk_location
      , location 
    FROM {{ ref('int_owid_covid_data') }}
    WHERE location IS NOT NULL
)

SELECT * FROM final
