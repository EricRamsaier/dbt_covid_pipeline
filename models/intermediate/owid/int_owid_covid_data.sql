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
        stg_data.*,
        ROW_NUMBER() OVER (
            PARTITION BY iso_code, observation_dt
            ORDER BY (
                /* sum of non-null numerics as proxy for most complete row */
              coalesce(total_cases, 0)
            + coalesce(new_cases, 0)
            + coalesce(new_deaths, 0)
            ) DESC
        ) AS rn
    FROM
        stg_data
    QUALIFY rn = 1
)

SELECT 
    final.* EXCLUDE (rn)
FROM 
    final