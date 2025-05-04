/*
Creator: Eric Ramsaier
Macro: no_fallback
Purpose:
    - Fails the test if the specified column is NULL or equals the fallback value.
    - Ensures that columns do not contain placeholder values (default '-1') in your models.
Usage:
    - Add this test in your schema.yml under any column where you want to guard against NULLs or fallbacks.
    - Optionally override the fallback by passing a different `fallback` argument.
Example Usage:
    tests:
      - no_fallback:
          fallback: '-1'
          severity: warn
*/

{% test no_fallback(model, column_name, fallback='-1') %}
select
    {{ column_name }} as invalid_value
from {{ model }}
where coalesce({{ column_name }}, '{{ fallback }}') = '{{ fallback }}'
{% endtest %}
