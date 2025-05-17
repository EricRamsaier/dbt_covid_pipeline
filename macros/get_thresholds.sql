-- Macro: get_thresholds
-- Description:
--   Fetches freshness thresholds for a given resource from the seeded
--   `seed_freshness_thresholds` table.  Each threshold column already
--   contains a numeric value + unit (e.g. "7 days").
--
-- Args:
--   resource_name: the name of the resource (e.g. "fct_owid_covid") whose
--                  thresholds you want to look up.
--
-- Returns:
--   A jinja dictionary:
--       "warn_after":  <string>,  -- e.g. "7 days"
--       "error_after": <string>   -- e.g. "14 days"

{% macro get_thresholds(resource_name) %}
  {% set sql %}
    SELECT
      warn_after,
      error_after
    FROM {{ ref('seed_freshness_thresholds') }}
    WHERE resource_name = '{{ resource_name }}'
    LIMIT 1
  {% endset %}

  {% set results = run_query(sql) %}
  {% if execute and results and results.rows %}
    {% set row = results.rows[0] %}
    {{ return({
      "warn_after":  row[0],
      "error_after": row[1]
    }) }}
  {% else %}
    {{ return({}) }}
  {% endif %}
{% endmacro %}
