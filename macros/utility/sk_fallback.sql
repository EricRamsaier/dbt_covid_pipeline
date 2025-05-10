-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Macro:         sk_fallback
-- Purpose:
--   - Returns a COALESCE expression to substitute a default string when a surrogate key is NULL.
--   - Ensures consistent defaulting of surrogate keys across all models.
--
-- Notes:
--   - Use when joining on optional dimensions or where NULL keys must be avoided.
--   - Accepts an optional default argument (defaults to '-1' if not provided).
--   - Intended for use only with string-form surrogate keys (e.g., SHA256-based).

{% macro sk_fallback(column_ref, default='-1') -%}
  -- return column_ref if not null, else default
  coalesce({{ column_ref }}, '{{ default }}')
{%- endmacro %}
