-- Created:       2024-05-10
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Model:         {{ this.identifier }}
-- Purpose:       Extracts unique OWID locations including countries, regions, and aggregates (e.g. "World", "EU")
-- Notes:
--   - Assigns surrogate key (sk_location) to each distinct `location`
--   - Used for joins to fact tables without repeating text labels
--   - Locations may not always map to real countries — validate downstream interpretation


{{
  config(
    unique_key='sk_location',
    tags=['dim','owid']
  )
}}

WITH source_data AS (
    SELECT * FROM {{ ref('int_owid_covid') }}
),

final AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['location']) }} AS sk_location
      , location 
    FROM source_data
    WHERE location IS NOT NULL
)

SELECT * FROM final
