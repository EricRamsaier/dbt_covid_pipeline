-- dim_owid_continent
-- -------------------
-- This dimension model extracts unique continent names from the OWID COVID data.
-- It assigns a surrogate key (sk_continent) to each distinct continent.
-- This model is useful for joining to fact tables and simplifying reporting.
-- NOTE: Continent values are taken as-is; data quality depends on upstream staging logic.


{{
  config(
    unique_key='sk_continent',
    tags=['dim','owid']
  )
}}

WITH source_data AS (
    SELECT * FROM {{ ref('int_owid_covid_data') }}
),

final AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['continent']) }} AS sk_continent
      , continent
    FROM {{ ref('int_owid_covid_data') }}
    WHERE continent IS NOT NULL
)

SELECT * FROM final