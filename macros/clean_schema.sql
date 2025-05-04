/*
Creator: Eric Ramsaier
Macro: to_timestamp
Purpose: 
    - Programmatic apporach to clearning out a non prod environment
*/


{% macro drop_and_recreate_dev_schema() %}
  {% if target.name == 'prod' %}
    {% set schema = target.schema %}
    {% set sql %}
      drop schema if exists {{ schema }} cascade;
      create schema {{ schema }};
    {% endset %}
    {% do run_query(sql) %}
    {{ log("Dropped and recreated schema: " ~ schema, info=True) }}
  {% endif %}
{% endmacro %}
