-- Adds standard audit fields for traceability and debugging across all marts.
-- Usage: include `{{ add_standard_audit_columns() }}` at the end of your SELECT list
-- Recommended in fact and dimension models, especially for incremental builds.

{% macro standard_audit_columns() %}
      '{{ model.name }}' AS model_name
    , CURRENT_TIMESTAMP() AS record_loaded_ts
    , '{{ invocation_id }}' AS dbt_invocation_id
    , '{{ run_started_at }}' AS dbt_run_ts 
{% endmacro %}
