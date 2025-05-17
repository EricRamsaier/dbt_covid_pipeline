{% macro get_thresholds_v2(resource_name) %}
  {#– Return a hard-coded Jinja dict for freshness thresholds –#}
  {% if resource_name == 'owid_covid_data' %}
    {{ return({
      "warn_after": "7 days",
      "error_after": "14 days"
    }) }}
  {% else %}
    {{ return({
      "warn_after": "1 days",
      "error_after": "2 days"
    }) }}
  {% endif %}
{% endmacro %}
