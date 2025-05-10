-- Created:       2024-05-10
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Model:         {{ this.identifier }}
-- Purpose:       Extracts unique continent names from OWID COVID data for use in joins and reporting
-- Notes:
--   - Assigns surrogate key (sk_continent) to each distinct continent
--   - Continent values are taken as-is from the source data
--   - Data quality depends on upstream staging logic


{{
  config(
    unique_key='sk_continent',
    tags=['dim','owid']
  )
}}

WITH source_data AS (
    SELECT * FROM {{ ref('int_owid_covid') }}
),

final AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['continent']) }} AS sk_continent
      , continent
    FROM source_data
    WHERE continent IS NOT NULL
)

SELECT * FROM final