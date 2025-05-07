--Data types set correctly at sources layer.

{{
  config(
    tags=['stg', 'owid']
  )
}}

WITH source_data AS (
    SELECT *
    FROM {{ source('owid','owid_covid_data') }}
),

final AS (
    SELECT
      iso_code AS owid_iso_code -- these are not true iso codes
    , continent
    , location
    , date AS observation_dt

    -- Case counts
    , total_cases
    , new_cases
    , new_cases_smoothed

    -- Death counts
    , total_deaths
    , new_deaths
    , new_deaths_smoothed

    -- Per-million rates
    , total_cases_per_million
    , new_cases_per_million
    , new_cases_smoothed_per_million
    , total_deaths_per_million
    , new_deaths_per_million
    , new_deaths_smoothed_per_million

    -- Reproduction & hospital
    , reproduction_rate
    , icu_patients
    , icu_patients_per_million
    , hosp_patients
    , hosp_patients_per_million

    -- Weekly admissions
    , weekly_icu_admissions
    , weekly_icu_admissions_per_million
    , weekly_hosp_admissions
    , weekly_hosp_admissions_per_million

    -- Testing metrics
    , total_tests
    , new_tests
    , total_tests_per_thousand
    , new_tests_per_thousand
    , new_tests_smoothed
    , new_tests_smoothed_per_thousand
    , positive_rate
    , tests_per_case
    , tests_units

    -- Vaccination metrics
    , total_vaccinations
    , people_vaccinated
    , people_fully_vaccinated
    , total_boosters
    , new_vaccinations
    , new_vaccinations_smoothed
    , total_vaccinations_per_hundred
    , people_vaccinated_per_hundred
    , people_fully_vaccinated_per_hundred
    , total_boosters_per_hundred
    , new_vaccinations_smoothed_per_million
    , new_people_vaccinated_smoothed
    , new_people_vaccinated_smoothed_per_hundred

    -- Socio-economic indicators
    , stringency_index
    , population_density
    , median_age
    , aged_65_older
    , aged_70_older
    , gdp_per_capita
    , extreme_poverty
    , cardiovasc_death_rate  AS cardiovascular_death_rate
    , diabetes_prevalence
    , female_smokers
    , male_smokers
    , handwashing_facilities
    , hospital_beds_per_thousand
    , life_expectancy
    , human_development_index
    , population
    , excess_mortality_cumulative_absolute
    , excess_mortality_cumulative
    , excess_mortality
    , excess_mortality_cumulative_per_million

FROM
    source_data
)

SELECT * FROM final