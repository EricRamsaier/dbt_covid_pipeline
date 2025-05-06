# Field Descriptions for OWID COVID Data

This file centralizes all field documentation for the `owid_covid_data` source and its downstream marts. By defining each field’s description once here as a reusable `docs` block, you can:

- **Maintain a single source of truth** for field definitions
- **Reduce duplication** across multiple YAML files
- **Simplify updates** when definitions or wording change
- **Ensure consistency** in your dbt docs site by referencing each field with `{{ doc('owid_<field_name>') }}` in both source and model schema files

_To use these definitions, reference a field’s description in your YAML like so:_

```yaml
columns:
  - name: order_id
    description: "{{ doc('owid_order_id') }}"
```

After updating this file, run `dbt docs generate` to rebuild the documentation site.

---

## Identifiers & Date

{% docs owid_iso_code %}
ISO 3166-1 alpha-3 country code
{% enddocs %}

{% docs owid_continent %}
Continent name or OWID region
{% enddocs %}

{% docs owid_location %}
Country or region name
{% enddocs %}

{% docs owid_date %}
Observation date (YYYY-MM-DD)
{% enddocs %}

## Case Counts

{% docs owid_total_cases %}
Cumulative confirmed cases
{% enddocs %}

{% docs owid_new_cases %}
Daily new cases
{% enddocs %}

{% docs owid_new_cases_smoothed %}
7-day smoothed new cases
{% enddocs %}

## Death Counts

{% docs owid_total_deaths %}
Cumulative confirmed deaths
{% enddocs %}

{% docs owid_new_deaths %}
Daily new deaths
{% enddocs %}

{% docs owid_new_deaths_smoothed %}
7-day smoothed new deaths
{% enddocs %}

## Per-Million Rates

{% docs owid_total_cases_per_million %}
Cumulative cases per million
{% enddocs %}

{% docs owid_new_cases_per_million %}
Daily new cases per million
{% enddocs %}

{% docs owid_new_cases_smoothed_per_million %}
7-day smoothed new cases per million
{% enddocs %}

{% docs owid_total_deaths_per_million %}
Cumulative deaths per million
{% enddocs %}

{% docs owid_new_deaths_per_million %}
Daily new deaths per million
{% enddocs %}

{% docs owid_new_deaths_smoothed_per_million %}
7-day smoothed new deaths per million
{% enddocs %}

## Reproduction & Hospital

{% docs owid_reproduction_rate %}
Effective reproduction number (Rₑ)
{% enddocs %}

{% docs owid_icu_patients %}
Patients in intensive care units
{% enddocs %}

{% docs owid_icu_patients_per_million %}
ICU patients per million
{% enddocs %}

{% docs owid_hosp_patients %}
Patients in hospital (reported)
{% enddocs %}

{% docs owid_hosp_patients_per_million %}
Hospital patients per million
{% enddocs %}

## Weekly Admissions

{% docs owid_weekly_icu_admissions %}
Weekly new ICU admissions
{% enddocs %}

{% docs owid_weekly_icu_admissions_per_million %}
Weekly ICU admissions per million
{% enddocs %}

{% docs owid_weekly_hosp_admissions %}
Weekly new hospital admissions
{% enddocs %}

{% docs owid_weekly_hosp_admissions_per_million %}
Weekly hospital admissions per million
{% enddocs %}

## Testing Metrics

{% docs owid_total_tests %}
Cumulative tests conducted
{% enddocs %}

{% docs owid_new_tests %}
Daily new tests
{% enddocs %}

{% docs owid_total_tests_per_thousand %}
Total tests per thousand
{% enddocs %}

{% docs owid_new_tests_per_thousand %}
Daily new tests per thousand
{% enddocs %}

{% docs owid_new_tests_smoothed %}
7-day smoothed new tests
{% enddocs %}

{% docs owid_new_tests_smoothed_per_thousand %}
7-day smoothed new tests per thousand
{% enddocs %}

{% docs owid_positive_rate %}
Positive test rate (new_cases / new_tests)
{% enddocs %}

{% docs owid_tests_per_case %}
Tests per confirmed case
{% enddocs %}

{% docs owid_tests_units %}
Units for tests reporting
{% enddocs %}

## Vaccination Metrics

{% docs owid_total_vaccinations %}
Cumulative vaccine doses administered
{% enddocs %}

{% docs owid_people_vaccinated %}
Individuals with ≥1 dose
{% enddocs %}

{% docs owid_people_fully_vaccinated %}
Individuals fully vaccinated
{% enddocs %}

{% docs owid_total_boosters %}
Additional/booster doses administered
{% enddocs %}

{% docs owid_new_vaccinations %}
Daily new vaccinations
{% enddocs %}

{% docs owid_new_vaccinations_smoothed %}
7-day smoothed new vaccinations
{% enddocs %}

{% docs owid_total_vaccinations_per_hundred %}
Total vaccinations per 100 people
{% enddocs %}

{% docs owid_people_vaccinated_per_hundred %}
People vaccinated per 100 people
{% enddocs %}

{% docs owid_people_fully_vaccinated_per_hundred %}
People fully vaccinated per 100 people
{% enddocs %}

{% docs owid_total_boosters_per_hundred %}
Booster doses per 100 people
{% enddocs %}

{% docs owid_new_vaccinations_smoothed_per_million %}
7-day smoothed vaccinations per million
{% enddocs %}

{% docs owid_new_people_vaccinated_smoothed %}
7-day smoothed individuals first vaccinated
{% enddocs %}

{% docs owid_new_people_vaccinated_smoothed_per_hundred %}
7-day smoothed people vaccinated per 100
{% enddocs %}

## Socio-Economic Indicators

{% docs owid_stringency_index %}
Oxford Government Stringency Index
{% enddocs %}

{% docs owid_population_density %}
People per square kilometre
{% enddocs %}

{% docs owid_median_age %}
Median age of population
{% enddocs %}

{% docs owid_aged_65_older %}
% population ≥ 65 years
{% enddocs %}

{% docs owid_aged_70_older %}
% population ≥ 70 years
{% enddocs %}

{% docs owid_gdp_per_capita %}
GDP per person (USD)
{% enddocs %}

{% docs owid_extreme_poverty %}
% population in extreme poverty
{% enddocs %}

{% docs owid_cardiovascular_death_rate %}
Annual CVD deaths per 100 k
{% enddocs %}

{% docs owid_diabetes_prevalence %}
% adults with diabetes
{% enddocs %}

{% docs owid_female_smokers %}
% female smokers
{% enddocs %}

{% docs owid_male_smokers %}
% male smokers
{% enddocs %}

{% docs owid_handwashing_facilities %}
% with basic handwashing facilities
{% enddocs %}

{% docs owid_hospital_beds_per_thousand %}
Hospital beds per 1 000 people
{% enddocs %}

{% docs owid_life_expectancy %}
Life expectancy at birth (years)
{% enddocs %}

{% docs owid_human_development_index %}
UN HDI index (0–1)
{% enddocs %}

{% docs owid_population %}
Total population
{% enddocs %}

{% docs owid_excess_mortality_cumulative_absolute %}
Cumulative excess deaths count
{% enddocs %}

{% docs owid_excess_mortality_cumulative %}
Cumulative excess mortality fraction
{% enddocs %}

{% docs owid_excess_mortality %}
Excess mortality this period
{% enddocs %}

{% docs owid_excess_mortality_cumulative_per_million %}
Excess mortality per million
{% enddocs %}
