-- Purpose:       Ensure that no records in the test_fct_owid_covid_data_no_future_dates model have dates in the future
-- Notes:
--   - Protects against bad loads or clock-skew that could insert future-dated records

SELECT *
FROM {{ ref('fct_owid_covid') }}
WHERE observation_dt > current_date()