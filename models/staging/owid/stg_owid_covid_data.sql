-- Created:       2024-05-12
-- Last Modified: 2025-05-23
-- Creator:       Eric Ramsaier
-- Model:         stg_owid_covid_data
-- Purpose:       Staging model for OWID COVID-19 data. Cleans, renames, and casts fields from the raw OWID source table.
-- Notes:
--   - Renames fields for clarity (e.g., iso_code → owid_iso_code, date → observation_dt)
--   - Filters source data in development using dev_data_filter macro
--   - Data types are enforced at the sources layer; this model performs light reshaping only


WITH source_data AS (
    SELECT *
    FROM {{ source('owid','owid_covid_data') }}
    {{ dev_data_filter('date', 7) }}
),

final AS (
    SELECT
      CAST(iso_code AS VARCHAR)                         AS owid_iso_code                         --  1
    , CAST(continent AS VARCHAR)                        AS continent                             --  2
    , CAST(location AS VARCHAR)                         AS location                              --  3
    , CAST(date AS DATE)                                AS observation_dt                        --  4
    -- Case counts
    , CAST(total_cases AS NUMBER(38,0))                 AS total_cases                           --  5
    , CAST(new_cases AS NUMBER(38,0))                   AS new_cases                             --  6
    , CAST(new_cases_smoothed AS NUMBER(38,2))          AS new_cases_smoothed                    --  7
    -- Death counts
    , CAST(total_deaths AS NUMBER(38,0))                AS total_deaths                          --  8
    , CAST(new_deaths AS NUMBER(38,0))                  AS new_deaths                            --  9
    , CAST(new_deaths_smoothed AS NUMBER(38,2))         AS new_deaths_smoothed                   -- 10
    -- Per-million rates
    , CAST(total_cases_per_million AS NUMBER(38,2))     AS total_cases_per_million              -- 11
    , CAST(new_cases_per_million AS NUMBER(38,2))       AS new_cases_per_million                -- 12
    , CAST(new_cases_smoothed_per_million AS NUMBER(38,2)) AS new_cases_smoothed_per_million   -- 13
    , CAST(total_deaths_per_million AS NUMBER(38,2))    AS total_deaths_per_million             -- 14
    , CAST(new_deaths_per_million AS NUMBER(38,2))      AS new_deaths_per_million               -- 15
    , CAST(new_deaths_smoothed_per_million AS NUMBER(38,2)) AS new_deaths_smoothed_per_million -- 16
    -- Reproduction & hospital
    , CAST(reproduction_rate AS NUMBER(38,2))           AS reproduction_rate                    -- 17
    , CAST(icu_patients AS NUMBER(38,0))                AS icu_patients                         -- 18
    , CAST(icu_patients_per_million AS NUMBER(38,2))    AS icu_patients_per_million            -- 19
    , CAST(hosp_patients AS VARCHAR)                    AS hosp_patients                        -- 20
    , CAST(hosp_patients_per_million AS VARCHAR)        AS hosp_patients_per_million           -- 21
    -- Weekly admissions
    , CAST(weekly_icu_admissions AS VARCHAR)            AS weekly_icu_admissions               -- 22
    , CAST(weekly_icu_admissions_per_million AS VARCHAR) AS weekly_icu_admissions_per_million -- 23
    , CAST(weekly_hosp_admissions AS VARCHAR)           AS weekly_hosp_admissions              -- 24
    , CAST(weekly_hosp_admissions_per_million AS VARCHAR) AS weekly_hosp_admissions_per_million -- 25
    -- Testing metrics
    , CAST(total_tests AS NUMBER(38,0))                 AS total_tests                          -- 26
    , CAST(new_tests AS NUMBER(38,0))                   AS new_tests                            -- 27
    , CAST(total_tests_per_thousand AS NUMBER(38,2))    AS total_tests_per_thousand            -- 28
    , CAST(new_tests_per_thousand AS NUMBER(38,2))      AS new_tests_per_thousand              -- 29
    , CAST(new_tests_smoothed AS NUMBER(38,1))          AS new_tests_smoothed                  -- 30
    , CAST(new_tests_smoothed_per_thousand AS NUMBER(38,2)) AS new_tests_smoothed_per_thousand -- 31
    , CAST(positive_rate AS NUMBER(38,2))               AS positive_rate                        -- 32
    , CAST(tests_per_case AS NUMBER(38,1))              AS tests_per_case                       -- 33
    , CAST(tests_units AS VARCHAR)                      AS tests_units                          -- 34
    -- Vaccination metrics
    , CAST(total_vaccinations AS NUMBER(38,0))          AS total_vaccinations                   -- 35
    , CAST(people_vaccinated AS NUMBER(38,0))           AS people_vaccinated                    -- 36
    , CAST(people_fully_vaccinated AS NUMBER(38,0))     AS people_fully_vaccinated              -- 37
    , CAST(total_boosters AS NUMBER(38,0))              AS total_boosters                       -- 38
    , CAST(new_vaccinations AS NUMBER(38,0))            AS new_vaccinations                     -- 39
    , CAST(new_vaccinations_smoothed AS NUMBER(38,1))   AS new_vaccinations_smoothed            -- 40
    , CAST(total_vaccinations_per_hundred AS NUMBER(38,2)) AS total_vaccinations_per_hundred   -- 41
    , CAST(people_vaccinated_per_hundred AS NUMBER(38,2)) AS people_vaccinated_per_hundred     -- 42
    , CAST(people_fully_vaccinated_per_hundred AS NUMBER(38,2)) AS people_fully_vaccinated_per_hundred -- 43
    , CAST(total_boosters_per_hundred AS NUMBER(38,2))  AS total_boosters_per_hundred           -- 44
    , CAST(new_vaccinations_smoothed_per_million AS NUMBER(38,1)) AS new_vaccinations_smoothed_per_million -- 45
    , CAST(new_people_vaccinated_smoothed AS NUMBER(38,1)) AS new_people_vaccinated_smoothed   -- 46
    , CAST(new_people_vaccinated_smoothed_per_hundred AS NUMBER(38,2)) AS new_people_vaccinated_smoothed_per_hundred -- 47
    -- Socio-economic indicators
    , CAST(stringency_index AS NUMBER(38,2))            AS stringency_index                    -- 48
    , CAST(population_density AS NUMBER(38,2))          AS population_density                  -- 49
    , CAST(median_age AS NUMBER(38,1))                  AS median_age                          -- 50
    , CAST(aged_65_older AS NUMBER(38,2))               AS aged_65_older                       -- 51
    , CAST(aged_70_older AS NUMBER(38,2))               AS aged_70_older                       -- 52
    , CAST(gdp_per_capita AS NUMBER(38,2))              AS gdp_per_capita                      -- 53
    , CAST(extreme_poverty AS NUMBER(38,1))             AS extreme_poverty                     -- 54
    , CAST(cardiovasc_death_rate AS NUMBER(38,2))       AS cardiovascular_death_rate           -- 55
    , CAST(diabetes_prevalence AS NUMBER(38,2))         AS diabetes_prevalence                 -- 56
    , CAST(female_smokers AS NUMBER(38,1))              AS female_smokers                      -- 57
    , CAST(male_smokers AS NUMBER(38,1))                AS male_smokers                        -- 58
    , CAST(handwashing_facilities AS NUMBER(38,2))      AS handwashing_facilities              -- 59
    , CAST(hospital_beds_per_thousand AS NUMBER(38,2))  AS hospital_beds_per_thousand          -- 60
    , CAST(life_expectancy AS NUMBER(38,2))             AS life_expectancy                     -- 61
    , CAST(human_development_index AS NUMBER(38,2))     AS human_development_index             -- 62
    , CAST(population AS NUMBER(38,0))                  AS population                          -- 63
    , CAST(excess_mortality_cumulative_absolute AS NUMBER(38,2)) AS excess_mortality_cumulative_absolute -- 64
    , CAST(excess_mortality_cumulative AS NUMBER(38,2)) AS excess_mortality_cumulative         -- 65
    , CAST(excess_mortality AS NUMBER(38,2))            AS excess_mortality                    -- 66
    , CAST(excess_mortality_cumulative_per_million AS NUMBER(38,2)) AS excess_mortality_cumulative_per_million -- 67
    , {{ to_timestamp('loaded_ts') }}                   AS loaded_ts                           -- 68
    FROM source_data
)

SELECT * FROM final
