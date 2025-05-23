-- Created:       2025-05-10
-- Last Modified: 2025-05-23
-- Creator:       Eric Ramsaier
-- Model:         agg_owid_covid_year
-- Purpose:       Aggregates COVID metrics by continent and observation date
-- Notes:
--   - Source is fct_owid_covid, which is contract-enforced and complete
--   - Aggregates key metrics like cases, deaths, and tests at the continent/year grain
--   - Excludes rows where continent is NULL


WITH base AS (
    SELECT *
    FROM {{ ref('fct_owid_covid') }}
),

final AS (
    SELECT
        YEAR(observation_dt)           AS observation_year

      -- Case metrics
      , SUM(new_cases)                 AS new_cases
      , SUM(new_deaths)                AS new_deaths
      , SUM(new_tests)                 AS new_tests
      , SUM(total_cases)               AS total_cases
      , SUM(total_deaths)              AS total_deaths
      , SUM(total_tests)               AS total_tests

      -- Vaccination metrics
      , SUM(new_vaccinations)          AS new_vaccinations
      , SUM(people_vaccinated)         AS people_vaccinated
      , SUM(people_fully_vaccinated)   AS people_fully_vaccinated
      , SUM(total_vaccinations)        AS total_vaccinations

      -- Population (latest per group — should be constant)
      , MAX(population)                AS population

    FROM base
    GROUP BY
        observation_year
)

SELECT * FROM final
