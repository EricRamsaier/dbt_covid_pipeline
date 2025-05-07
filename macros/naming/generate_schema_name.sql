--https://docs.getdbt.com/docs/build/custom-schemas#an-alternative-pattern-for-generating-schema-names
--This macro is actively used to modify behavior from default. 
--Essentially, all non prod environments will push all objects into 1 schema, such as dbt_eramsaier
--Do not drop it.

{% macro generate_schema_name(custom_schema_name, node) -%}
  {%- if target.name in ['prod','production'] and custom_schema_name is not none -%}
    {{ custom_schema_name }}
  {%- else -%}
    {{ target.schema }}
  {%- endif -%}
{%- endmacro %}

