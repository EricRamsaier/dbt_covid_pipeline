-- Purpose:
--   - Overrides default dbt behavior for schema naming.
--   - Forces all non-prod environments to write to a shared schema (e.g., dbt_eramsaier).
--
-- Notes:
--   - This macro is actively used to control environment-specific schema resolution.
--   - Do not delete or rename — removal may break deployments in dev or staging.
--
-- Source: https://docs.getdbt.com/docs/build/custom-schemas#an-alternative-pattern-for-generating-schema-names

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if target.name in ['prod','production'] and custom_schema_name is not none -%}
        
    {{ custom_schema_name }}
  
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}
