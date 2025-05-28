-- Purpose:
--   - Converts a VARCHAR currency string to DECIMAL(10, 2).
--   - Standardizes numeric formatting for financial fields across models.
--
-- Notes:
--   - Apply this macro to any column where currency values are stored as strings.
--   - Avoids casting errors and ensures consistent precision and scale.


{% macro to_currency (currency_column) %}
    TRY_CAST({{ currency_column }} AS DECIMAL(10, 2))
{% endmacro %}
