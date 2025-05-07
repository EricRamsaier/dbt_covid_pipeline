-- Macro: test_freshness_threshold
-- Description:
--   A reusable dbt test macro to validate that records in a model are fresh.
--   It checks if the difference between a specified timestamp column and the current timestamp exceeds a threshold.
--
-- Custom freshness test:
-- Fails (or warns) if any record's timestamp in the specified column is older than X hours.
--
-- Args:
--   model:         the dbt model being tested
--   column_name:   the timestamp field to compare (e.g. "loaded_ts")
--   threshold_hours: maximum allowed age in hours
--   warn_if:       if true, logs warning only instead of error

{% test test_freshness_threshold(model, column_name, threshold_hours) %}
SELECT *
FROM {{ model }}
WHERE DATEDIFF('hour', {{ column_name }}, CURRENT_TIMESTAMP()) > {{ threshold_hours }}
{% endtest %}
