-- Purpose:
--   - Appends standard audit metadata fields to a model's SELECT list.
--   - Includes model name, invocation ID, run start timestamp, and record load timestamp.
--
-- Recommended Usage:
--   - Add to SELECT statements in fact and dimension models.
--   - Supports traceability, auditability, and debugging of data freshness or timing issues.



{% macro standard_audit_columns(include_loaded_ts=true) %}
      '{{ model.name }}'                            AS dbt_model_name
    , '{{ invocation_id }}'                         AS dbt_invocation_id
    , CAST('{{ run_started_at }}' AS TIMESTAMP_TZ)  AS dbt_run_ts
    , CAST(CURRENT_TIMESTAMP()    AS TIMESTAMP_TZ)  AS dbt_record_loaded_ts
{% endmacro %}
