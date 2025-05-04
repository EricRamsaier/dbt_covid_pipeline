/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Dimension table for currencies
         - One row per currency
         - Pass-through from staging with audit tracking
Notes:
  - Data sourced from stg__faker__orders__currency
  - Uses standard_audit_columns() macro for traceability
*/

{{ config(
    tags = ['marts', 'faker', 'dim']
) }}

WITH base AS (
    -- Pulls data from the staging model for currency
    SELECT * 
    FROM {{ ref('stg_faker_orders_currency') }}
),

final AS (
    SELECT
        {{ generate_surrogate_key(['currency_id']) }} AS currency_sk
      , currency_id
      , currency_code
      , currency_name
      , currency_symbol
      , {{ standard_audit_columns() }}
    FROM base
)

SELECT * FROM final
