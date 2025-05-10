-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Test:          expression_is_true
-- Purpose:
--   - Fails the test if the provided expression evaluates to false for any row.
--   - Enables flexible, reusable assertions on arbitrary row-level conditions.
--
-- Notes:
--   - Accepts any valid SQL boolean expression as a string.
--   - Use to enforce data rules that can't be captured by standard dbt tests.
--   - Returns all failing rows to assist with debugging.


{% test expression_is_true(model, expression) %}
select *
from {{ model }}
where not ({{ expression }})
{% endtest %}
