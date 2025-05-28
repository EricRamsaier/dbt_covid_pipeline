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
      , {{ dbt_utils.generate_surrogate_key(['owid_iso_code', 'observation_dt']) }} AS sk_owid_iso_code

    FROM
        stg_data
    QUALIFY rn = 1
)

SELECT 
    final.* 
    EXCLUDE (rn)
FROM 
    final