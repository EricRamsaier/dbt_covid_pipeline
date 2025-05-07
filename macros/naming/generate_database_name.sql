-- Macro: generate_database_name
-- Purpose: Override the default database selection for models.
--   - In production targets (“prod” or “production”), use the configured custom_database_name.
--   - In all other environments (development, feature branches, staging), fall back to the target.database,
--     ensuring each developer or sandbox environment writes to its own database.
-- Usage:
--   In dbt_project.yml, set your custom database for a model folder:
--     marts:
--       +database: reporting
--   dbt will call this macro under the hood to resolve the actual database.

/*
Custom schemas (overview of how to override database & schema names via macros):
https://docs.getdbt.com/docs/build/custom-schemas

Alternative pattern for generating schema names (the exact example you’re using, which you can adapt for databases):
https://docs.getdbt.com/docs/build/custom-schemas#an-alternative-pattern-for-generating-schema-names
*/

{% macro generate_database_name(custom_database_name, node) -%}
  {%- if target.name in ['prod', 'production'] and custom_database_name is not none -%}
    {{ custom_database_name }}
  {%- else -%}
    {{ target.database }}
  {%- endif -%}
{%- endmacro %}
