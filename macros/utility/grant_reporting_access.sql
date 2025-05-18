-- Created:       2024-05-18
-- Last Modified: 2025-05-18
-- Creator:       Eric Ramsaier
-- Macro:         grant_reporting_access
-- Purpose:
--   - Grants SELECT privileges on all tables in the reporting.marts.
--   - Ensures downstream tools or analyst roles have access to all newly built models.
--
-- Notes:
--   - Intended for use with `dbt run-operation`.


{% macro grant_reporting_access() %}
  {% set sql %}
    GRANT USAGE ON SCHEMA REPORTING.MARTS TO ROLE analyst_role;
    GRANT SELECT ON ALL TABLES IN SCHEMA REPORTING.MARTS TO ROLE analyst_role;
    GRANT SELECT ON FUTURE TABLES IN SCHEMA REPORTING.MARTS TO ROLE analyst_role;
    GRANT USAGE ON SCHEMA REPORTING.MARTS TO ROLE developer_role;
    GRANT SELECT ON ALL TABLES IN SCHEMA REPORTING.MARTS TO ROLE developer_role;
    GRANT SELECT ON FUTURE TABLES IN SCHEMA REPORTING.MARTS TO ROLE developer_role;
  {% endset %}
  {% do run_query(sql) %}
{% endmacro %}
