-- ========================================================================
-- Macro: log_model_run
-- Description:
--   Logs metadata about each dbt model run to the audit table.
--   Captures model name, run timestamp, invocation ID, row count, and table path.
--   Intended to be called as a post-hook for fact/dimension models in production.
--
-- Usage:
--   Add this to dbt_project.yml under a model path with:
--     +post-hook: "{{ log_model_run() }}"
--
-- Requirements:
--   The target table `dwh.audit.model_run_log` must exist.
-- ========================================================================

{% macro log_model_run() %}
    INSERT INTO dwh.audit.model_run_log (
        model_name,
        run_ts,
        dbt_invocation_id,
        row_count,
        database_name,
        schema_name,
        table_name
    )
    SELECT
        '{{ this.identifier }}',
        '{{ run_started_at }}'::TIMESTAMP_LTZ,
        '{{ invocation_id }}',
        (SELECT COUNT(*) FROM {{ this }}),
        '{{ this.database }}',
        '{{ this.schema }}',
        '{{ this.identifier }}';
{% endmacro %}
