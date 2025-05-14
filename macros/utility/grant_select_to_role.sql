-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Macro:         grant_select_to_role
-- Purpose:
--   - Grants SELECT privileges on all tables in the current dbt target schema to a specified role.
--   - Ensures downstream tools or analyst roles have access to all newly built models.
--
-- Notes:
--   - Intended for use with `dbt run-operation`.
--   - Requires a `target_role` argument specifying the role to receive privileges.
--   - Useful for enabling BI access in production or staging environments.

-- macros/grants.sql

{% macro grant_select_to_role(target_role) %}
  {#–
    Grant SELECT on ALL TABLE and VIEW objects in the target schema
    to the given Snowflake role.
  –#}

  {% set db = target.database %}
  {% set schema = target.schema %}

  {% do run_query(
      "GRANT USAGE ON DATABASE " ~ db ~ " TO ROLE " ~ target_role
  ) %}
  {% do run_query(
      "GRANT USAGE ON SCHEMA " ~ db ~ "." ~ schema ~ " TO ROLE " ~ target_role
  ) %}
  {% do run_query(
      "GRANT SELECT ON ALL TABLES IN SCHEMA " ~ db ~ "." ~ schema ~ " TO ROLE " ~ target_role
  ) %}
  {% do run_query(
      "GRANT SELECT ON ALL VIEWS IN SCHEMA " ~ db ~ "." ~ schema ~ " TO ROLE " ~ target_role
  ) %}

{% endmacro %}
