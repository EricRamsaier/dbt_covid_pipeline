-- Adds standard audit fields for traceability and debugging across all marts.
-- Usage: include `{{ add_standard_audit_columns() }}` at the end of your SELECT list
-- Recommended in fact and dimension models, especially for incremental builds.

{% macro standard_audit_columns() %}
      '{{ model.name }}'                    AS dbt_model_name
    , '{{ invocation_id }}'                 AS dbt_invocation_id      
    , '{{ run_started_at }}'::TIMESTAMP_LTZ AS dbt_run_ts       
    , CURRENT_TIMESTAMP()::TIMESTAMP_LTZ    AS dbt_record_loaded_ts

{% endmacro %}

