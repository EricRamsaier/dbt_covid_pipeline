-- Created:       2024-05-01
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Model:         {{ this.identifier }}
-- Purpose:       Resolve duplicate records in the OWID COVID dataset by keeping the most complete row per (owid_iso_code, observation_dt)
-- Notes:
--   - Applies a completeness heuristic using row_number over key metrics
--   - Normalizes continent values where missing or inconsistent
--   - Source data may contain multiple rows per day due to OWID updates
--   - See background in: analyses/data_issues/owid_covid_data_duplicates.md


{{
  config(
    tags=['int', 'owid']
  )
}}

WITH stg_data AS (
    SELECT * FROM {{ ref('stg_owid_covid_data') }}
),

final AS (
   SELECT
        -- choosing to use exclude since there are many fields in the source table
        stg_data.* 
        EXCLUDE (continent)

        -- adding clear continents when possible for NULL when the location is a continent
      , CASE
            WHEN continent IS NOT NULL              THEN continent
            -- effectively WHEN IS NULL AND
            WHEN location IN (
            'Africa', 'Asia', 'Europe', 'North America', 'South America', 'Oceania'
            )                                       THEN location
            WHEN location = 'European Union (27)'   THEN 'Europe'
            ELSE 'Unspecified'
        END AS continent

      -- dedup logic
      , ROW_NUMBER() OVER (
            PARTITION BY owid_iso_code, observation_dt
            ORDER BY (
                --sum of non-null numerics as proxy for most complete row
              COALESCE(total_cases, 0)
            + COALESCE(new_cases, 0)
            + COALESCE(new_deaths, 0)
            ) DESC
        ) AS rn
      -- end dedup logic

    FROM
        stg_data
    QUALIFY rn = 1
)

SELECT 
    final.* 
    EXCLUDE (rn)
FROM 
    final