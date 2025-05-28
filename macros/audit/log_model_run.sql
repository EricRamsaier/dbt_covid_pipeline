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
        CAST('{{ run_started_at }}' AS TIMESTAMP_TZ),
        '{{ invocation_id }}',
        (SELECT COUNT(*) FROM {{ this }}),
        '{{ this.database }}',
        '{{ this.schema }}',
        '{{ this.identifier }}';
{% endmacro %}
