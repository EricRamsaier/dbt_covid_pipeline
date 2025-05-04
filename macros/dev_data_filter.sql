/*
  Macro: dev_data_filter
  Description: Injects a WHERE clause to limit rows in the dev environment
               to only the last N days of data.
  Parameters:
    • column_name      – the timestamp/date column to filter on
    • dev_days_of_data – number of days of data to include (default: 3)
  Usage:
    In any model you can call this macro to conditionally apply the filter:
    
      select *
      from {{ source('my_source', 'my_table') }}
      {{ dev_data_filter('created_at', 7) }}
    
    When run against the “dev” target, this expands to:
    
      select *
      from raw.my_source.my_table
      /* limit to last 7 days in dev */
      where created_at >= dateadd('day', -7, current_timestamp)
    
    On other targets (e.g. prod), it injects nothing.
*/

{% macro dev_data_filter(column_name, dev_days_of_data=3) %}
  {%- if target.name == 'dev' -%}
    /* limit to last {{ dev_days_of_data }} days in dev */
    WHERE {{ column_name }}
      >= dateadd('day', -{{ dev_days_of_data }}, current_date)
  {%- endif -%}
{% endmacro %}
