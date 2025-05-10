-- Created:         2024-05-01
-- Last Modified:   2025-05-10
-- Creator:         Eric Ramsaier
-- Model:           {{ this.identifier }}
-- Purpose:         Date dimension table from 2010 to 2030
--   - Adds derived fields such as year, quarter, month, weekday
--   - Includes placeholder `is_holiday` field for future enrichment
-- Notes:
--   - Uses Snowflake GENERATOR for row creation (~21 years)
--   - Aligned to calendar use in reporting and joins
--   - Tagged as shared calendar dimension


{{
  config(
    tags = ['shared', 'calendar', 'dim']
  )
}}

WITH date_range AS (
  SELECT
      DATEADD(DAY, seq4(), DATE '2010-01-01')   AS date_dt
  FROM TABLE(GENERATOR(ROWCOUNT => 7671)) -- ~21 years
),

final AS (
  SELECT
      date_dt                                AS date_dt
    , YEAR(date_dt)                          AS year
    , MONTH(date_dt)                         AS month
    , TO_CHAR(date_dt, 'Month')              AS month_name
    , QUARTER(date_dt)                       AS quarter
    , DAY(date_dt)                           AS day_of_month
    , DAYOFWEEK(date_dt)                     AS day_of_week
    , TO_CHAR(date_dt, 'Day')                AS weekday_name
    , CASE
        WHEN DAYOFWEEK(date_dt) IN (1, 7) THEN TRUE
        ELSE FALSE
      END                                    AS is_weekend
    , FALSE                                  AS is_holiday  -- Placeholder
    , {{ standard_audit_columns() }}
  FROM date_range
)

SELECT * FROM final
