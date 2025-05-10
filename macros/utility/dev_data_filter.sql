-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Macro:         dev_data_filter
-- Purpose:
--   - Injects a WHERE clause to limit rows in the dev environment to the last N days.
--   - Helps reduce query size and execution time in development.
--
-- Parameters:
--   - column_name: Name of the timestamp/date column to filter on.
--   - dev_days_of_data: Number of days to include (default is 3).
--
-- Notes:
--   - Only applies filtering when the active dbt target is 'dev'.
--   - Injects nothing in production or non-dev environments.
--   - Intended to be used inside model CTEs or FROM clauses for conditional row limiting.


{% macro dev_data_filter(column_name, dev_days_of_data=3) %}
  {%- if target.name == 'dev' -%}
    WHERE {{ column_name }}
      >= dateadd('day', -{{ dev_days_of_data }}, current_date)
  {%- endif -%}
{% endmacro %}
