/*
Creator: Eric Ramsaier
Generates a time dimension with 1-minute resolution
*/

{{
  config(
    tags = ['shared', 'calendar', 'dim']
  )
}}

WITH time_gen AS (
  SELECT
    seq4()                                   AS minute_of_day
  FROM TABLE(GENERATOR(ROWCOUNT => 1440)) -- 24h * 60min
),
--
final AS (
  SELECT
    TO_TIME(
      TO_CHAR(FLOOR(minute_of_day / 60), '09') || ':' || TO_CHAR(MOD(minute_of_day, 60), '09')
    )                                       AS time_ts
  , FLOOR(minute_of_day / 60)               AS hour
  , MOD(minute_of_day, 60)                  AS minute
  , 0                                       AS second
  , CASE
      WHEN FLOOR(minute_of_day / 60) < 12 THEN 'AM'
      ELSE 'PM'
    END                                     AS am_pm
  , {{ standard_audit_columns() }}
  FROM time_gen
)
--
SELECT * FROM final
