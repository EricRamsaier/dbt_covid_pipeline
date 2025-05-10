-- Adds standard audit metadata fields to the SELECT list of a model.
-- Includes the model name, invocation ID, run start timestamp, and record load timestamp.
--
-- Recommended for use in fact and dimension models to support:
--   • Traceability of model execution
--   • Auditing and lineage tracking
--   • Debugging data freshness and timing issues


{% macro standard_audit_columns(include_loaded_ts=true) %}
      '{{ model.name }}'                    AS dbt_model_name
    , '{{ invocation_id }}'                 AS dbt_invocation_id
    , '{{ run_started_at }}'::TIMESTAMP_LTZ AS dbt_run_ts
    , CURRENT_TIMESTAMP()::TIMESTAMP_LTZ    AS dbt_record_loaded_ts
{% endmacro %}
