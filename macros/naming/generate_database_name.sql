-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Macro:         generate_database_name
-- Purpose:
--   - Overrides default dbt behavior for database selection.
--   - In production targets ("prod" or "production"), uses the configured custom_database_name.
--   - In all other environments (e.g., dev, feature branches), uses target.database to isolate workspaces.
--
-- Usage:
--   - In dbt_project.yml, you can define per-folder database overrides:
--       marts:
--         +database: reporting
--   - dbt automatically calls this macro to resolve the database value.
--
-- Notes:
--   - Actively used in environment-specific resolution logic.
--   - Do not remove — required for controlled multi-env deployments.
--
-- References:
--   https://docs.getdbt.com/docs/build/custom-schemas
--   https://docs.getdbt.com/docs/build/custom-schemas#an-alternative-pattern-for-generating-schema-names


{% macro generate_database_name(custom_database_name, node) -%}
  {%- if target.name in ['prod', 'production'] and custom_database_name is not none -%}
    {{ custom_database_name }}
  {%- else -%}
    {{ target.database }}
  {%- endif -%}
{%- endmacro %}
