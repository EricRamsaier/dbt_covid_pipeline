/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Dimension table for products
         - One row per product
         - Pass-through from intermediate layer with audit tracking
Notes:
  - Data sourced from int__faker__orders__product
  - Uses standard_audit_columns() macro for traceability
*/

{{ config(
    tags = ['marts', 'faker', 'dim']
) }}

WITH base AS (
    -- Pulls data from the intermediate model for product
    SELECT * 
    FROM {{ ref('int_faker_orders_product') }}
),

final AS (
    SELECT
        {{ generate_surrogate_key(['product_id']) }} AS product_sk
      , product_id
      , product_name
      , product_category
      , product_category_standardized
      , {{ standard_audit_columns() }}
    FROM base
)

SELECT * FROM final
