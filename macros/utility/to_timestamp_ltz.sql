-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Macro:         to_timestamp_ltz
-- Purpose:       Casts a column to TIMESTAMP_LTZ to enforce UTC standardization.
-- Notes:
--   - Use to normalize timestamp types across sources and models.
--   - Avoids inconsistencies with TIMESTAMP_NTZ or TIMESTAMP_TZ.

{% macro to_timestamp_ltz (date_column) %}
    CAST({{ date_column }} AS TIMESTAMP_LTZ)
{% endmacro %}
