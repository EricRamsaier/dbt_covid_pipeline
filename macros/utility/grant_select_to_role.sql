-- Macro: grant_select_to_role
-- Description:
--   Grants SELECT privileges on all tables in the current dbt target schema to a specified role.
--   Useful for ensuring downstream tools (e.g., BI platforms) or analyst roles have access after builds.
--
-- Usage:
--   dbt run-operation grant_select_to_role --args '{"target_role": "ANALYST_ROLE"}'
--
-- Example:
--   This will run GRANT SELECT ON TABLE ... TO ROLE ANALYST_ROLE; for each dbt model in the schema.

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
