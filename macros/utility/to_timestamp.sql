-- Created:       2024-04-30
-- Last Modified: 2025-05-12
-- Creator:       Eric Ramsaier
-- Macro:         to_timestamp
-- Purpose:       Casts a column to TIMESTAMP_TZ to enforce UTC standardization.
-- Notes:
--   - Use to normalize timestamp types across sources and models.

{% macro to_timestamp (date_column) %}
    CAST({{ date_column }} AS TIMESTAMP_TZ)
{% endmacro %}
