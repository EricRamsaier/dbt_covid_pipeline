-- Created:       2024-05-05
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Model:         fct_owid_covid
-- Purpose:       Fact model for OWID COVID metrics, aggregated by country and observation date
-- Notes:
--   - Uses surrogate key sk_owid_covid from owid_iso_code + observation_dt
--   - Includes case, death, testing, and vaccination metrics plus demographic context
--   - Incremental model using 7-day cutoff for recent updates
--   - Enforced contract with on_schema_change='fail' for pipeline stability


{{
  config(
    materialized='incremental',
    unique_key='sk_owid_covid',
    incremental_strategy='merge',
    cluster_by = ['observation_dt', 'owid_iso_code'],
    contract={'enforced': true},
    on_schema_change='fail',
    tags=['fct','owid']
  )
}}

WITH
owid_data AS (
  SELECT 
    *
  FROM 
    {{ ref('int_owid_covid') }}
  {% if is_incremental() %}
  WHERE
    observation_dt >= DATEADD(DAY, -7, CURRENT_DATE)
{% endif %}
),

final as (
SELECT
      {{ dbt_utils.generate_surrogate_key( ['owid_iso_code', 'observation_dt'] ) }} AS sk_owid_covid
    , owid_iso_code
    , continent
    , location
    , observation_dt
    , total_cases
    , new_cases
    , new_cases_smoothed
    , total_deaths
    , new_deaths
    , new_deaths_smoothed
    , total_cases_per_million
    , new_cases_per_million
    , new_cases_smoothed_per_million
    , total_deaths_per_million
    , new_deaths_per_million
    , new_deaths_smoothed_per_million
    , reproduction_rate
    , icu_patients
    , icu_patients_per_million
    , hosp_patients
    , hosp_patients_per_million
    , weekly_icu_admissions
    , weekly_icu_admissions_per_million
    , weekly_hosp_admissions
    , weekly_hosp_admissions_per_million
    , total_tests
    , new_tests
    , total_tests_per_thousand
    , new_tests_per_thousand
    , new_tests_smoothed
    , new_tests_smoothed_per_thousand
    , positive_rate
    , tests_per_case
    , tests_units
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
    , stringency_index
    , population_density
    , median_age
    , aged_65_older
    , aged_70_older
    , gdp_per_capita
    , extreme_poverty
    , cardiovascular_death_rate
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
    , loaded_ts
    , {{ standard_audit_columns() }}
from 
    owid_data
)

SELECT * FROM final