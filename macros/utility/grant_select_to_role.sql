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


{% macro grant_select_to_role(target_role) %}
  -- Get the target database and schema for the current dbt environment
  {% set database = target.database %}
  {% set schema = target.schema %}

  -- Fetch a list of all tables in the target schema
  {% set results = run_query("SHOW TABLES IN SCHEMA " ~ database ~ "." ~ schema) %}

  -- Loop through the table list and grant SELECT on each one
  {% for row in results %}
    {% set table_name = row['name'] %}

    -- Construct GRANT statement
    {% set sql %}
      GRANT SELECT ON TABLE {{ database }}.{{ schema }}.{{ table_name }} TO ROLE {{ target_role }};
    {% endset %}

    -- Execute the GRANT and log the action
    {% do run_query(sql) %}
    {% do log("Granted SELECT on " ~ table_name ~ " to role " ~ target_role, info=True) %}
  {% endfor %}
{% endmacro %}
