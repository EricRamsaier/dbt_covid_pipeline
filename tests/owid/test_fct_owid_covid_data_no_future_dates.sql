-- Created:       2025-05-13
-- Last Modified: 2025-05-13
-- Creator:       Eric Ramsaier
-- Test:          no_future_dates_dim_owid_iso_code
-- Model:         test_fct_owid_covid_data_no_future_dates
-- Purpose:       Ensure that no records in the test_fct_owid_covid_data_no_future_dates model have dates in the future
-- Notes:
--   - Protects against bad loads or clock-skew that could insert future-dated records

SELECT *
FROM {{ ref('fct_owid_covid') }}
WHERE observation_dt > current_date()