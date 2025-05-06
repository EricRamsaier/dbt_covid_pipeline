-- This intermediate model resolves duplicate rows in the OWID COVID dataset
-- by selecting the most complete record per (iso_code, observation_dt).
-- For full background on the duplication issue, see:
-- analyses/data_issues/owid_covid_data_duplicates.md

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
        stg_data.* EXCLUDE (continent)

      , CASE
            WHEN continent IS NOT NULL                                  THEN continent
            WHEN continent IS NULL AND location = 'Africa'              THEN location
            WHEN continent IS NULL AND location = 'Asia'                THEN location
            WHEN continent IS NULL AND location = 'Europe'              THEN location
            WHEN continent IS NULL AND location = 'European Union (27)' THEN location
            WHEN continent IS NULL AND location = 'North America'       THEN location
            WHEN continent IS NULL AND location = 'South America'       THEN location
            ELSE 'Unspecified'
        END AS continent

      -- dedup logic
      , ROW_NUMBER() OVER (
            PARTITION BY iso_code, observation_dt
            ORDER BY (
                /* sum of non-null numerics as proxy for most complete row */
              coalesce(total_cases, 0)
            + coalesce(new_cases, 0)
            + coalesce(new_deaths, 0)
            ) DESC
        ) AS rn
      -- end dedup logic

    FROM
        stg_data
    QUALIFY rn = 1
)

SELECT 
    final.* EXCLUDE (rn)
FROM 
    final