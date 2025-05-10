-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Macro:         log_model_run
-- Purpose:
--   - Logs metadata about each dbt model execution to the audit table.
--   - Captures model name, run timestamp, invocation ID, row count, and table location.
--
-- Usage:
--   - Intended to be used as a post-hook for fact or dimension models.
--   - Configure in dbt_project.yml using a +post-hook reference.
--
-- Requirements:
--   - The target audit table must exist: dwh.audit.model_run_log
--   - Ensure proper permissions are in place for INSERT statements on that table.


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
